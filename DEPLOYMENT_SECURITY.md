# Aeyetech Vision Engine - Secure Deployment Guide

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui
```

### Step 2: Set Up Ollama with Qwen3-VL

```bash
# Install Ollama (if not already installed)
# macOS/Linux: https://ollama.ai/download

# Pull the Qwen3-VL vision model
ollama pull qwen3-vl

# Start Ollama (it should auto-start, but if not)
ollama serve
```

### Step 3: Start the Container

#### For macOS:
```bash
# Use the auto-detection script
./scripts/start_container.sh

# The script will automatically detect your platform and start the container
# Access at https://localhost:8090
```

#### For Xavier Nano:
```bash
# Use the auto-detection script
./scripts/start_container.sh

# It will detect Jetson and use the correct image
# Access at https://localhost:8090
```

**Access**: `https://localhost:8090` - Only accessible from the host machine by default.

**Configure the Model**:
1. Open `https://localhost:8090`
2. In "Vision API Settings" panel:
   - API Base URL: `http://localhost:11434/v1` (Ollama default)
   - Model: Select `qwen3-vl` from dropdown
3. Click "START" to begin analysis

## Container Security Options

By default, the container uses `network_mode: host` which means it's accessible on your local network. For additional security:

### Option 1: SSH Tunnel for Remote Access

If you need to access from another machine, use SSH tunneling:

```bash
# From your local machine, create an SSH tunnel to the deployment machine
ssh -L 8090:localhost:8090 user@xavier-nano-ip

# Now access via https://localhost:8090 on your local machine
```

### Option 2: Firewall Rules

Configure firewall to restrict access (example for Ubuntu/Debian):

```bash
# Allow only specific IP addresses
sudo ufw allow from 192.168.1.0/24 to any port 8090
sudo ufw enable
```

### Option 3: VPN Access Only

Deploy on a VPN network (e.g., Tailscale, WireGuard) for remote access.

### Option 4: Manual Start/Stop Only

```bash
# Stop the container when not in use
docker stop live-vlm-webui

# Start when needed
docker start live-vlm-webui
```

## Alarm Endpoint Configuration (Future)

The alarm service infrastructure is ready. When you want to enable it, you'll configure your alarm endpoint URL and token. For now, it's disabled by default.

## Testing

### Test Local Access
```bash
# Should work - open in browser
open https://localhost:8090  # macOS
xdg-open https://localhost:8090  # Linux
```

### Test Ollama Connection
```bash
# Check Ollama is running
ollama list

# Should show qwen3-vl in the list
# In the web UI, select qwen3-vl from the model dropdown
```

## Production Deployment Checklist

- [ ] Container bound to localhost (127.0.0.1) or VPN network only
- [ ] SSH access secured with key-based authentication
- [ ] Firewall configured to block port 8090 from external networks
- [ ] No automatic container restart (manual start only)
- [ ] HTTPS certificates properly configured
- [ ] Alarm endpoint URL configured with authentication token
- [ ] Regular security updates applied to host OS
- [ ] Container logs monitored for suspicious activity

## Security Notes

1. **No Application-Level Authentication**: This deployment does NOT include login authentication. Security relies entirely on network-level controls.

2. **HTTPS Required**: The application uses self-signed certificates. For production, consider using proper SSL certificates.

3. **Alarm Endpoint Security**: Ensure your alarm endpoint uses HTTPS and validates the bearer token.

4. **Physical Security**: Xavier Nano devices should be in secure locations with restricted physical access.

## Quick Commands Reference

```bash
# Start the container (auto-detect platform)
./scripts/start_container.sh

# Stop the container
./scripts/stop_container.sh

# View logs
docker logs -f live-vlm-webui

# Access from remote machine via SSH tunnel
ssh -L 8090:localhost:8090 user@device-ip

# Check Ollama models
ollama list

# Pull a different vision model
ollama pull llama3.2-vision:11b
```

---

For questions or issues, refer to the main README.md or contact your system administrator.
