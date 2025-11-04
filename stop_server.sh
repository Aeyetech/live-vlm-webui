#!/bin/bash
# Stop Live VLM WebUI Server

echo "Stopping Live VLM WebUI server..."
pkill -f "python server.py"

# Wait a moment
sleep 1

# Check if stopped
if pgrep -f "python server.py" > /dev/null; then
    echo "❌ Server still running, forcing kill..."
    pkill -9 -f "python server.py"
    sleep 1
fi

if ! pgrep -f "python server.py" > /dev/null; then
    echo "✓ Server stopped successfully"
else
    echo "❌ Failed to stop server"
    exit 1
fi

