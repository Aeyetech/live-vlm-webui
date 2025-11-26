# Aeyetech Vision Engine - Rebranding Summary

## Overview
This document summarizes all changes made to rebrand the NVIDIA Live VLM WebUI to Aeyetech Vision Engine with enhanced security and UI obfuscation.

## Changes Made

### 1. Branding & Visual Identity

#### Logo & Assets
- **New Logo**: Added `logo.png` → `/src/live_vlm_webui/static/images/aeyetech-logo.png`
- **Favicons Generated**:
  - `favicon.svg` - Simple "A" logo with blue background
  - `favicon.ico` - Multi-size ICO file
  - `favicon-96x96.png`
  - `apple-touch-icon.png` (180x180)
  - `web-app-manifest-192x192.png`
  - `web-app-manifest-512x512.png`

#### Color Scheme
Changed from NVIDIA green to Aeyetech blue throughout:
- Primary: `#2563EB` (was `#76B900`)
- Dark: `#1E40AF` (was `#5E9400`)
- Light: `#3B82F6` (was `#8BC919`)

**Files Modified**: `index.html` - CSS variables, gradients, inline styles

#### Text & Copyright
- Page title: "Live VLM WebUI - NVIDIA AI Platform" → **"Aeyetech Vision Engine"**
- Header: "Live VLM WebUI" → **"Aeyetech Vision Engine"**
- Subtitle: "Real-time Vision Language Model Benchmark/Evaluation Tool" → **"Real-time Vision Analysis System"**
- Copyright: "Copyright (c) 2025 NVIDIA CORPORATION" → **"Copyright (c) 2025 Aeyetech"**
- Removed all NVIDIA API Catalog references

### 2. UI Obfuscation (Moderate Level)

#### Terminology Changes
- "VLM API Configuration" → **"Vision API Settings"**
- "Prompt Editor" → **"Query Configuration"**
- "VLM Output Info" → **"Analysis Output"**
- Removed version numbers and identifying metadata
- Generic cloud service references instead of "NVIDIA API Catalog"

#### Visual Changes
- SVG NVIDIA logo → PNG Aeyetech logo
- Blue color scheme instead of green
- Modified gradient definitions

### 3. Security Infrastructure

#### Alarm Service (New)
Created `/src/live_vlm_webui/alarm_service.py`:
- Async alarm queue with retry logic
- Webhook/REST API support
- Bearer token authentication
- Exponential backoff for failed sends
- Recent alarm history tracking
- Configurable via environment variables or command-line args

**Configuration**:
- `ALARM_ENDPOINT` - URL to send alarms
- `ALARM_AUTH_TOKEN` - Bearer token for authentication
- `ALARM_ENABLED` - Enable/disable alarm sending

#### Docker Security
Created `DEPLOYMENT_SECURITY.md` with options:
1. **Localhost binding** (127.0.0.1:8090)
2. **SSH tunneling** for remote access
3. **Custom networks** with firewall rules
4. **VPN-only access**
5. **Manual start/stop** (no auto-restart)

**No application-level login** - Security managed at network/container level

### 4. Files Modified

#### Core Application Files
1. `/src/live_vlm_webui/static/index.html` (~3900 lines)
   - All branding changes
   - Color scheme updates
   - UI terminology
   - Logo replacement

2. `/requirements.txt`
   - Removed authentication libraries (not needed)

3. `/src/live_vlm_webui/static/favicon/` (7 files)
   - All favicons regenerated with Aeyetech branding

4. `/src/live_vlm_webui/static/images/`
   - Added `aeyetech-logo.png`

#### New Files Created
1. `/src/live_vlm_webui/alarm_service.py` - Alarm infrastructure
2. `/DEPLOYMENT_SECURITY.md` - Docker security guide
3. `/AEYETECH_CHANGES.md` - This file
4. `/generate_favicons.py` - Favicon generation script (can be deleted)

### 5. Not Modified (Original NVIDIA Files Kept)

The following maintain original NVIDIA code structure for easier updates:
- `/src/live_vlm_webui/server.py` - Server logic unchanged
- `/src/live_vlm_webui/video_processor.py` - Processing logic
- `/src/live_vlm_webui/gpu_monitor.py` - Hardware monitoring
- `/src/live_vlm_webui/vlm_service.py` - VLM API integration
- `/docker/*` - Docker configurations (use deployment guide instead)
- `/scripts/*` - Shell scripts

## Usage

### Quick Start - Docker (Recommended)

```bash
# 1. Clone the repo
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui

# 2. Set up Ollama with Qwen3-VL
ollama pull qwen3-vl

# 3. Start the container (auto-detects macOS or Xavier Nano)
./scripts/start_container.sh

# 4. Access at https://localhost:8090
```

### Configure in Web UI
1. Open `https://localhost:8090`
2. In "Vision API Settings":
   - API Base URL: `http://localhost:11434/v1`
   - Model: Select `qwen3-vl`
3. Click "START"

### Running Locally (Development)
```bash
# Install in editable mode
pip install -e .

# Start server
./scripts/start_server.sh

# Access at https://localhost:8090
```

## Alarm Endpoint Format

When alarms are enabled, they will be sent as POST requests:

```json
{
  "timestamp": "2025-01-26T12:34:56.789Z",
  "type": "detection",
  "severity": "warning",
  "message": "Object detected in restricted area",
  "metadata": {
    "confidence": 0.95,
    "location": "Zone A"
  },
  "source": "aeyetech-vision-engine"
}
```

**Headers**:
- `Content-Type: application/json`
- `Authorization: Bearer <your-token>` (if token configured)

## Testing

### Visual Testing
1. Start the application
2. Access `https://localhost:8090`
3. Verify:
   - Aeyetech logo appears in header
   - Blue color scheme (not green)
   - "Aeyetech Vision Engine" title
   - Generic terminology ("Vision API Settings", "Analysis Output")

### Security Testing
```bash
# Should FAIL (not accessible from network)
curl https://<machine-ip>:8090

# Should WORK (localhost only)
curl https://localhost:8090
```

### Alarm Testing
Configure alarm endpoint and trigger test alarm:
```bash
# Check alarm service status via logs
docker logs aeyetech-vision | grep "Alarm"
```

## Maintenance

### Updating Favicon
If you need to update the logo:
```bash
# Replace logo
cp new-logo.png src/live_vlm_webui/static/images/aeyetech-logo.png

# Regenerate favicons
python3 generate_favicons.py
```

### Updating Colors
Edit `/src/live_vlm_webui/static/index.html`:
```css
:root {
    --aeyetech-blue: #2563EB;        /* Change this */
    --aeyetech-blue-dark: #1E40AF;   /* And this */
    --aeyetech-blue-light: #3B82F6;  /* And this */
    --accent-color: #2563EB;         /* And this */
}
```

## Notes

1. **No Login Required**: This version does NOT include application-level authentication. Security is handled via Docker/network configuration.

2. **NVIDIA Code Preserved**: Core server logic remains unchanged to allow easy updates from upstream.

3. **Alarm Service Ready**: Infrastructure is in place, just configure your endpoint URL and token.

4. **Future Enhancements**: If you need application-level login later, the infrastructure can be added without affecting existing branding.

## Deployment Checklist

- [ ] Logo and favicons updated
- [ ] Color scheme changed to blue
- [ ] All text references to NVIDIA removed
- [ ] UI terminology changed
- [ ] Docker container bound to localhost
- [ ] Alarm endpoint configured (if needed)
- [ ] SSL certificates accepted in browser
- [ ] Tested on target platforms (macOS, Xavier Nano)

---

**Product**: Aeyetech Vision Engine
**Version**: Based on NVIDIA Live VLM WebUI
**Copyright**: © 2025 Aeyetech. All rights reserved.
