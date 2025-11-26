# Copyright (c) 2025 Aeyetech. All rights reserved.

"""
Alarm Service for Aeyetech Vision Engine
Sends alerts to a configured endpoint when events are detected
"""

import asyncio
import logging
import json
from typing import Dict, Any, Optional
from datetime import datetime
import aiohttp
from collections import deque

logger = logging.getLogger(__name__)


class AlarmService:
    """
    Service for sending alarms to external endpoints
    Supports webhook/REST API with retry logic
    """

    def __init__(
        self,
        endpoint_url: Optional[str] = None,
        auth_token: Optional[str] = None,
        enabled: bool = False,
        max_retries: int = 3,
        retry_delay: float = 2.0,
    ):
        """
        Initialize the alarm service

        Args:
            endpoint_url: URL to send alarms to
            auth_token: Optional bearer token for authentication
            enabled: Whether alarm sending is enabled
            max_retries: Maximum number of retry attempts
            retry_delay: Initial delay between retries (exponential backoff)
        """
        self.endpoint_url = endpoint_url
        self.auth_token = auth_token
        self.enabled = enabled and endpoint_url is not None
        self.max_retries = max_retries
        self.retry_delay = retry_delay

        # Queue for async delivery
        self.alarm_queue = asyncio.Queue()
        self.processing_task = None

        # Keep track of recent alarms (for deduplication and history)
        self.recent_alarms = deque(maxlen=100)

        if self.enabled:
            logger.info(f"Alarm service initialized - endpoint: {endpoint_url}")
        else:
            logger.info("Alarm service disabled")

    async def start(self):
        """Start the alarm processing task"""
        if self.enabled and self.processing_task is None:
            self.processing_task = asyncio.create_task(self._process_queue())
            logger.info("Alarm service started")

    async def stop(self):
        """Stop the alarm processing task"""
        if self.processing_task:
            self.processing_task.cancel()
            try:
                await self.processing_task
            except asyncio.CancelledError:
                pass
            logger.info("Alarm service stopped")

    async def send_alarm(
        self,
        alarm_type: str,
        message: str,
        severity: str = "info",
        metadata: Optional[Dict[str, Any]] = None
    ):
        """
        Queue an alarm to be sent

        Args:
            alarm_type: Type of alarm (e.g., "detection", "error", "warning")
            message: Human-readable alarm message
            severity: Severity level ("info", "warning", "error", "critical")
            metadata: Additional metadata to include with the alarm
        """
        if not self.enabled:
            logger.debug(f"Alarm not sent (disabled): {alarm_type} - {message}")
            return

        alarm_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "type": alarm_type,
            "severity": severity,
            "message": message,
            "metadata": metadata or {},
            "source": "aeyetech-vision-engine"
        }

        # Add to queue for async processing
        await self.alarm_queue.put(alarm_data)
        logger.debug(f"Alarm queued: {alarm_type} - {message}")

    async def _process_queue(self):
        """Process alarms from the queue with retry logic"""
        while True:
            try:
                alarm_data = await self.alarm_queue.get()
                await self._send_with_retry(alarm_data)
                self.alarm_queue.task_done()
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Error processing alarm queue: {e}")

    async def _send_with_retry(self, alarm_data: Dict[str, Any]):
        """
        Send alarm with exponential backoff retry

        Args:
            alarm_data: Alarm data to send
        """
        headers = {
            "Content-Type": "application/json",
        }

        if self.auth_token:
            headers["Authorization"] = f"Bearer {self.auth_token}"

        for attempt in range(self.max_retries):
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.post(
                        self.endpoint_url,
                        json=alarm_data,
                        headers=headers,
                        timeout=aiohttp.ClientTimeout(total=10)
                    ) as response:
                        if response.status >= 200 and response.status < 300:
                            logger.info(
                                f"Alarm sent successfully: {alarm_data['type']} "
                                f"(status: {response.status})"
                            )
                            self.recent_alarms.append(alarm_data)
                            return
                        else:
                            error_text = await response.text()
                            logger.warning(
                                f"Alarm send failed (attempt {attempt + 1}/{self.max_retries}): "
                                f"HTTP {response.status} - {error_text}"
                            )
            except asyncio.TimeoutError:
                logger.warning(
                    f"Alarm send timeout (attempt {attempt + 1}/{self.max_retries})"
                )
            except Exception as e:
                logger.warning(
                    f"Alarm send error (attempt {attempt + 1}/{self.max_retries}): {e}"
                )

            # Exponential backoff
            if attempt < self.max_retries - 1:
                delay = self.retry_delay * (2 ** attempt)
                await asyncio.sleep(delay)

        logger.error(
            f"Failed to send alarm after {self.max_retries} attempts: "
            f"{alarm_data['type']} - {alarm_data['message']}"
        )

    def get_recent_alarms(self, limit: int = 10) -> list:
        """
        Get recent alarms

        Args:
            limit: Maximum number of recent alarms to return

        Returns:
            List of recent alarm data
        """
        return list(self.recent_alarms)[-limit:]

    def get_stats(self) -> Dict[str, Any]:
        """
        Get alarm service statistics

        Returns:
            Dictionary with service stats
        """
        return {
            "enabled": self.enabled,
            "endpoint": self.endpoint_url if self.enabled else None,
            "queue_size": self.alarm_queue.qsize(),
            "total_sent": len(self.recent_alarms),
        }


# Convenience function for quick alarm sending
_global_alarm_service: Optional[AlarmService] = None


def init_alarm_service(
    endpoint_url: Optional[str] = None,
    auth_token: Optional[str] = None,
    enabled: bool = False,
) -> AlarmService:
    """
    Initialize the global alarm service

    Args:
        endpoint_url: URL to send alarms to
        auth_token: Optional bearer token
        enabled: Whether to enable alarm sending

    Returns:
        Initialized AlarmService instance
    """
    global _global_alarm_service
    _global_alarm_service = AlarmService(
        endpoint_url=endpoint_url,
        auth_token=auth_token,
        enabled=enabled
    )
    return _global_alarm_service


def get_alarm_service() -> Optional[AlarmService]:
    """Get the global alarm service instance"""
    return _global_alarm_service


async def send_alarm(
    alarm_type: str,
    message: str,
    severity: str = "info",
    metadata: Optional[Dict[str, Any]] = None
):
    """
    Convenience function to send an alarm using the global service

    Args:
        alarm_type: Type of alarm
        message: Alarm message
        severity: Severity level
        metadata: Additional metadata
    """
    if _global_alarm_service:
        await _global_alarm_service.send_alarm(
            alarm_type=alarm_type,
            message=message,
            severity=severity,
            metadata=metadata
        )
