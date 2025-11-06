#!/bin/bash
# Auto-detect platform and start the appropriate Live-VLM-WebUI Docker container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    Live-VLM-WebUI Docker Container Starter${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Detect architecture
ARCH=$(uname -m)
echo -e "${YELLOW}🔍 Detecting platform...${NC}"
echo -e "   Architecture: ${GREEN}${ARCH}${NC}"

# Detect platform type
PLATFORM="unknown"
IMAGE_TAG="latest"
GPU_FLAG=""
RUNTIME_FLAG=""

if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="x86"
    IMAGE_TAG="latest-x86"
    GPU_FLAG="--gpus all"
    echo -e "   Platform: ${GREEN}PC (x86_64)${NC}"

elif [ "$ARCH" = "aarch64" ]; then
    # Check if it's a Jetson
    if [ -f /etc/nv_tegra_release ]; then
        # Read L4T version
        L4T_VERSION=$(head -n 1 /etc/nv_tegra_release | grep -oP 'R\K[0-9]+')

        # Check for Thor (L4T R38+) vs Orin (L4T R36)
        if [ "$L4T_VERSION" -ge 38 ]; then
            PLATFORM="jetson-thor"
            IMAGE_TAG="latest-jetson-thor"
            GPU_FLAG="--gpus all"
            echo -e "   Platform: ${GREEN}NVIDIA Jetson Thor${NC} (L4T R${L4T_VERSION})"
        else
            PLATFORM="jetson-orin"
            IMAGE_TAG="latest-jetson-orin"
            RUNTIME_FLAG="--runtime nvidia"
            echo -e "   Platform: ${GREEN}NVIDIA Jetson Orin${NC} (L4T R${L4T_VERSION})"
        fi
    else
        echo -e "${RED}❌ ARM64 platform detected but not a Jetson${NC}"
        echo -e "${RED}   This script is designed for x86_64 PC or NVIDIA Jetson platforms${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Unsupported architecture: ${ARCH}${NC}"
    exit 1
fi

# Container name
CONTAINER_NAME="live-vlm-webui"
IMAGE_NAME="ghcr.io/nvidia-ai-iot/live-vlm-webui:${IMAGE_TAG}"

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠️  Container '${CONTAINER_NAME}' already exists${NC}"
    read -p "   Stop and remove it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🛑 Stopping and removing existing container...${NC}"
        docker stop ${CONTAINER_NAME} 2>/dev/null || true
        docker rm ${CONTAINER_NAME} 2>/dev/null || true
    else
        echo -e "${RED}❌ Aborted${NC}"
        exit 1
    fi
fi

# Pull latest image (optional)
read -p "Pull latest image from registry? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📥 Pulling ${IMAGE_NAME}...${NC}"
    docker pull ${IMAGE_NAME} || {
        echo -e "${YELLOW}⚠️  Failed to pull from registry, will use local image${NC}"
    }
fi

# Build run command based on platform
echo -e "${BLUE}🚀 Starting container...${NC}"

DOCKER_CMD="docker run -d \
  --name ${CONTAINER_NAME} \
  --network host \
  --privileged"

# Add GPU/runtime flags
if [ -n "$GPU_FLAG" ]; then
    DOCKER_CMD="$DOCKER_CMD $GPU_FLAG"
fi
if [ -n "$RUNTIME_FLAG" ]; then
    DOCKER_CMD="$DOCKER_CMD $RUNTIME_FLAG"
fi

# Add Jetson-specific mounts
if [[ "$PLATFORM" == "jetson-"* ]]; then
    DOCKER_CMD="$DOCKER_CMD -v /run/jtop.sock:/run/jtop.sock:ro"
fi

# Add image name
DOCKER_CMD="$DOCKER_CMD ${IMAGE_NAME}"

# Execute
echo -e "${YELLOW}   Command: ${DOCKER_CMD}${NC}"
eval $DOCKER_CMD

# Wait a moment for container to start
sleep 2

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}✅ Container started successfully!${NC}"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🌐 Access the Web UI at:${NC}"

    # Get IP addresses
    if command -v hostname &> /dev/null; then
        HOSTNAME=$(hostname)
        echo -e "   Local:   ${GREEN}https://localhost:8090${NC}"

        # Try to get network IP
        if command -v hostname &> /dev/null; then
            NETWORK_IP=$(hostname -I | awk '{print $1}')
            if [ -n "$NETWORK_IP" ]; then
                echo -e "   Network: ${GREEN}https://${NETWORK_IP}:8090${NC}"
            fi
        fi
    fi

    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📋 Useful commands:${NC}"
    echo -e "   View logs:        ${GREEN}docker logs -f ${CONTAINER_NAME}${NC}"
    echo -e "   Stop container:   ${GREEN}docker stop ${CONTAINER_NAME}${NC}"
    echo -e "   Remove container: ${GREEN}docker rm ${CONTAINER_NAME}${NC}"
    echo ""
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo -e "${YELLOW}📋 Check logs with: docker logs ${CONTAINER_NAME}${NC}"
    exit 1
fi

