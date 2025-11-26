# Aeyetech Vision Engine - Quick Start

## 3-Step Setup

### 1. Get Ollama + Qwen3-VL
```bash
# Install Ollama: https://ollama.ai/download

# Pull the vision model
ollama pull qwen3-vl
```

### 2. Start the Container
```bash
# Clone and start
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui
./scripts/start_container.sh
```

### 3. Configure & Use
1. Open **https://localhost:8090**
2. Accept SSL certificate warning
3. In **"Vision API Settings"**:
   - API Base: `http://localhost:11434/v1`
   - Model: Select **qwen3-vl** from dropdown
4. Point your webcam and click **START**

## That's It!

You now have:
- ✅ Aeyetech branded UI (blue theme)
- ✅ Real-time vision analysis with Qwen3-VL
- ✅ Secure local deployment (localhost only)
- ✅ Alarm infrastructure ready (when you need it)

## Common Commands

```bash
# Stop container
./scripts/stop_container.sh

# View logs
docker logs -f live-vlm-webui

# Try different model
ollama pull llama3.2-vision:11b
# Then select it in the web UI
```

## Need Help?

- **Deployment Security**: See [DEPLOYMENT_SECURITY.md](DEPLOYMENT_SECURITY.md)
- **All Changes**: See [AEYETECH_CHANGES.md](AEYETECH_CHANGES.md)
- **Original Docs**: See [README.md](README.md)

---

**Aeyetech Vision Engine** | Powered by Qwen3-VL
