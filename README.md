# Live VLM WebUI

**A universal web interface for real-time Vision Language Model interaction and benchmarking.**

Stream your webcam to any VLM and get live AI-powered analysis - perfect for testing models, benchmarking performance, and exploring vision AI capabilities across multiple domains and hardware platforms.

![Live VLM WebUI Screenshot](./docs/images/chrome_app_running.png)

---

## 🚀 Quick Start (Easiest Way!)

**Works on PC (x86_64), DGX Spark (ARM64), Jetson Orin, and Jetson Thor** - same simple steps:

```bash
# 1. Clone the repository
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui

# 2. Run the auto-detection script
./start_container.sh
```

That's it! The script will:
- ✅ Auto-detect your platform (PC x86_64, Jetson Orin, or Jetson Thor)
- ✅ Pull the appropriate pre-built image from GitHub Container Registry
- ✅ Configure GPU access automatically
- ✅ Start the container with correct settings

**Access the WebUI:** Open **`https://localhost:8090`** in your browser

> [!NOTE]
> You'll need a VLM backend running (Ollama, vLLM, etc.). See [VLM Backend Setup](#-setting-up-your-vlm-backend) below.

### Available Pre-built Images

| Platform | Image Tag | Pull Command |
|----------|-----------|--------------|
| **PC (x86_64) / DGX Spark** | `latest` | `docker pull ghcr.io/nvidia-ai-iot/live-vlm-webui:latest` |
| **Jetson Orin** | `latest-jetson-orin` | `docker pull ghcr.io/nvidia-ai-iot/live-vlm-webui:latest-jetson-orin` |
| **Jetson Thor** | `latest-jetson-thor` | `docker pull ghcr.io/nvidia-ai-iot/live-vlm-webui:latest-jetson-thor` |

> [!TIP]
> The `latest` tag is a **multi-arch image** that automatically selects the correct architecture:
> - `linux/amd64` for x86_64 PC and DGX systems
> - `linux/arm64` for DGX Spark (ARM64 SBSA server)

---

## 🎥 WebUI Usage

Once the server is running, access the web interface at **`https://localhost:8090`**

### Accepting the SSL Certificate

| 1️⃣ Click **"Advanced"** button | 2️⃣ Click **"Proceed to localhost (unsafe)"** | 3️⃣ Allow camera access when prompted |
|:---:|:---:|:---:|
| ![Chrome Advanced](./docs/images/chrome_advanced.png) | ![Chrome Proceed](./docs/images/chrome_proceed.png) | ![Chrome Webcam Access](./docs/images/chrome_webcam_access.png) |

### Interface Overview

**Left Sidebar Controls:**

<img src="./docs/images/usage_left_pane.png" align="left" width="180px" style="margin-right: 50px; margin-bottom: 10px;">

#### **🌐 VLM API Configuration**
  - Set **API Base URL**, API Key, and **Model**
    - 🔄 Refresh models button - Auto-detect available models
    - ➕ Download button (coming soon)

#### **📹 Camera Control**
  - Dropdown menu lists all detected cameras
  - Switch cameras on-the-fly without restarting
  - **START/STOP** buttons for analysis control
  - **Frame Interval**: Process every N frames (1-3600)
    - Lower (5-30) = more frequent, higher GPU usage
    - Higher (60-300) = less frequent, power saving

#### **✍️ Prompt Editor**
  - 10+ preset prompts (scene description, object detection, safety, OCR, etc.)
  - Write custom prompts
  - Adjust **Max Tokens** for response length (1-4096)

<br clear="left">

<img src="./docs/images/usage_main_pane.png" align="right" width="240px" style="margin-left: 50px; margin-bottom: 10px;">

**Main Content Area:**

- **VLM Output Card** - Real-time analysis results:
  - Model name and inference latency metrics
  - Current prompt display (gray box with green accent)
  - Generated text output
- **Video Feed** - Live webcam with 🔄 mirror toggle button
- **System Stats Card** - Live monitoring:
  - System info: hostname (CPU model) with GPU name
  - GPU utilization and VRAM with progress bars
  - CPU and RAM stats
  - Sparkline graphs (60-second history)

<br clear="right">

**Header:**
- **🎥 Live VLM WebUI** - Logo and title
- **Connection Status** - WebSocket connectivity indicator
- **⚙️ Settings** - Advanced configuration modal (WebRTC, latency thresholds, debugging)
- **🌙/☀️ Theme Toggle** - Switch between Light/Dark modes

![](./docs/images/usage_header.png)

---

## 💻 Local Installation (Versatile, Works on Mac)

**For developers who want full control and customization:**

```bash
# 1. Clone the repository
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui

# 2. Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Generate SSL certificates
./generate_cert.sh

# 5. Start the server
./start_server.sh
```

**Access the WebUI:** Open **`https://localhost:8090`**

**Platforms supported:**
- ✅ Linux (x86_64, ARM64) - fully tested
- ✅ macOS (Intel, Apple Silicon) - fully tested
- ⚠️ Windows - WSL2 recommended, native Windows possible but requires additional setup (FFmpeg, build tools)

---

## 🤖 Setting Up Your VLM Backend

Choose the VLM backend that fits your needs:

### Quick Comparison

| Backend | Setup Difficulty | Speed | Quality | GPU Required |
|---------|-----------------|-------|---------|--------------|
| **Ollama** | ⭐ Easy | 🟢 Fast | 🟢 Good | Yes (local) |
| **vLLM** | ⭐⭐ Medium | 🟢🟢 Fastest | 🟢🟢 Excellent | Yes (local) |
| **SGLang** | ⭐⭐ Medium | 🟢 Fast | 🟢🟢 Excellent | Yes (local) |
| **NVIDIA API Catalog** | ⭐ Easy | 🟡 Medium | 🟢🟢🟢 Best | No |

### Option A: Ollama (Recommended for Beginners)

```bash
# Install from https://ollama.ai/download
# Pull a vision model
ollama pull llama3.2-vision:11b

# Start server
ollama serve
```

**Best for:** Quick start, easy model management

### Option B: vLLM (Recommended for Performance)

```bash
# Install vLLM
pip install vllm

# Start server
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.2-11B-Vision-Instruct \
  --port 8000
```

**Best for:** Production deployments, high throughput

### Option C: NVIDIA API Catalog (No GPU Required)

1. Visit [NVIDIA API Catalog](https://build.nvidia.com/)
2. Get API key from a vision model page
3. Configure in WebUI:
   - API Base: `https://ai.api.nvidia.com/v1/gr`
   - API Key: `nvapi-YOUR_KEY`
   - Model: `meta/llama-3.2-90b-vision-instruct`

**Best for:** Cloud-based inference, instant access

**📗 Detailed Guide:** [VLM Backend Setup](./docs/setup/vlm-backends.md)

---

## 🐳 Quick Deploy: Docker Compose with VLM Backend

**For PC and DGX Spark users who want VLM + WebUI in one command:**

> [!TIP]
> `start_docker_compose.sh` automatically detects your platform, checks Docker installation, and selects the correct profile. Just run it!

### With Ollama (Easiest, No API Keys Required)

**Using the launcher script (recommended):**
```bash
./start_docker_compose.sh ollama

# Pull a vision model after startup
docker exec ollama ollama pull llama3.2-vision:11b
```

**Or manually with docker compose:**
```bash
docker compose --profile ollama up

# Pull a vision model
docker exec ollama ollama pull llama3.2-vision:11b
```

> [!TIP]
> Backend-centric profiles make it easy: `--profile ollama`, `--profile vllm` (future), etc.

Includes:
- ✅ Ollama for easy model management
- ✅ Live VLM WebUI for real-time interaction
- ✅ No API keys required

### With NVIDIA NIM + Cosmos-Reason1-7B (Advanced)

> [!TIP]
> Cosmos-Reason1-7B is the default NIM model because it's the only NVIDIA VLM NIM that supports both x86_64 (PC) and ARM64 (DGX Spark, Jetson Thor) architectures. Other NIM models like Llama-3.2-90B-Vision and Nemotron are x86_64-only.

**Using the launcher script (recommended):**
```bash
# Get NGC API Key from https://org.ngc.nvidia.com/setup/api-key
export NGC_API_KEY=<your-key>

./start_docker_compose.sh nim
```

**Or manually with docker compose:**
```bash
export NGC_API_KEY=<your-key>
docker compose --profile nim up
```

Includes:
- ✅ NVIDIA NIM serving Cosmos-Reason1-7B with reasoning capabilities
- ✅ Production-grade inference
- ✅ Advanced VLM with planning and anomaly detection

> [!IMPORTANT]
> NIM requires NGC API Key and downloads ~10-15GB on first run. Requires NVIDIA driver 565+ (CUDA 12.9 support).

**📗 Detailed Guide:** [Docker Compose Setup Details](./docs/setup/docker-compose-details.md)

---

## 📚 Documentation

### For Users
- 📖 [VLM Backend Setup](./docs/setup/vlm-backends.md) - Detailed guide for Ollama, vLLM, SGLang, NVIDIA API
- 🐋 [Docker Compose Details](./docs/setup/docker-compose-details.md) - Complete stack setup with Ollama or NIM
- 🛠️ [Manual Docker Deployment](./docs/setup/docker-manual.md) - Advanced Docker configurations
- ⚙️ [Advanced Configuration](./docs/usage/advanced-configuration.md) - Performance tuning, custom prompts, API compatibility

### For Developers
- 🔨 [Building Docker Images](./docs/development/building-images.md) - Build platform-specific images for GHCR
- 🧑‍💻 [Contributing Guide](./CONTRIBUTING.md) - How to contribute to the project

### Help & Support
- 🆘 [Troubleshooting Guide](./docs/troubleshooting.md) - Common issues and solutions
- 💬 [GitHub Issues](https://github.com/nvidia-ai-iot/live-vlm-webui/issues) - Bug reports and feature requests
- 🌐 [NVIDIA Developer Forums](https://forums.developer.nvidia.com/) - Community support

---

## ✨ Key Features

### Core Functionality
- 🎥 **Real-time WebRTC streaming** - Low-latency bidirectional video
- 🔌 **OpenAI-compatible API** - Works with vLLM, SGLang, Ollama, TGI, or any vision API
- 📝 **Interactive prompt editor** - 10+ preset prompts + custom prompts
- ⚡ **Async processing** - Smooth video while VLM processes frames in background
- 🔧 **Flexible deployment** - Local inference or cloud APIs

### UI & Visualization
- 🎨 **Modern NVIDIA-themed UI** - Professional design with NVIDIA green accents
- 🌓 **Light/Dark theme toggle** - Automatic preference persistence
- 📊 **Live system monitoring** - Real-time GPU, VRAM, CPU, RAM stats with sparkline charts
- ⏱️ **Inference metrics** - Live latency tracking (last, average, total count)
- 🪞 **Video mirroring** - Toggle button overlay on camera view
- 📱 **Compact layout** - Single-screen design

### Platform Support
- 💻 **Cross-platform monitoring** - Auto-detects NVIDIA GPUs (NVML), Apple Silicon, AMD (coming soon)
- 🖥️ **Dynamic system detection** - CPU model name and hostname
- 🔒 **HTTPS support** - Self-signed certificates for secure webcam access
- 🌐 **Universal compatibility** - PC (x86_64), DGX Spark (ARM64 SBSA), Jetson (Orin, Thor), Mac
- 🏗️ **Multi-arch Docker images** - Single image works across x86_64 and ARM64 architectures

---

## 🗺️ Use Cases

- 🎬 **Content Creation** - Live scene analysis for video production
- 🔒 **Security** - Real-time monitoring and alert generation
- ♿ **Accessibility** - Visual assistance for visually impaired users
- 🎮 **Gaming** - AI game master or interactive experiences
- 🏥 **Healthcare** - Activity monitoring, fall detection
- 🏭 **Industrial** - Quality control, safety monitoring
- 📚 **Education** - Interactive learning experiences
- 🤖 **Robotics** - Visual feedback for robot control

---

## 🛠️ Troubleshooting

### Quick Fixes

**Camera not accessible?**
- Use HTTPS (not HTTP): `./start_server.sh` or `--ssl-cert cert.pem --ssl-key key.pem`
- Accept the self-signed certificate warning (Advanced → Proceed)

**Can't connect to VLM?**
- Check VLM is running: `curl http://localhost:8000/v1/models` (vLLM) or `curl http://localhost:11434/v1/models` (Ollama)
- Use `--network host` in Docker for local VLM services

**GPU stats show "N/A"?**
- PC: Add `--gpus all` when running Docker
- Jetson: Add `--privileged -v /run/jtop.sock:/run/jtop.sock:ro`

**Slow performance?**
- Use smaller model (llava:7b instead of llava:34b)
- Increase Frame Processing Interval (60+ frames)
- Reduce Max Tokens (50-100 instead of 512)

## 🔧 Other Ways to Set Up

### Option 1: Docker Compose (Complete Stack)

For launching the WebUI alongside a VLM backend (Ollama or NVIDIA NIM) in a single stack:

**Using the launcher script (recommended):**
```bash
# Ollama (easy, no API keys)
./start_docker_compose.sh ollama

# NVIDIA NIM (advanced, requires NGC API key)
export NGC_API_KEY=<your-key>
./start_docker_compose.sh nim
```

**Manual docker compose:**
```bash
# Ollama
docker compose --profile ollama up

# NVIDIA NIM
export NGC_API_KEY=<your-key>
docker compose --profile nim up
```

**📗 Full Guide:** [Docker Compose Details](./docs/setup/docker-compose-details.md) - Includes NIM model selection, troubleshooting, and platform-specific instructions.

### Option 2: Manual Docker Run

For more control over Docker configurations, see [Manual Docker Setup](./docs/setup/docker-manual.md).

### Option 3: Local Installation (Most Flexible)

For development or custom setups, install directly without Docker:

**Requirements:**
- Python 3.10+
- NVIDIA GPU with CUDA support (for GPU monitoring)
- FFmpeg (for video processing)

**Quick setup:**
```bash
git clone https://github.com/nvidia-ai-iot/live-vlm-webui.git
cd live-vlm-webui
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./generate_cert.sh
./start_server.sh
```

**📗 See:** Full instructions above in [Quick Start → Option 2: Local Installation](#option-2-local-installation-versatile-works-on-mac)

---

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- 🔄 Apple Silicon GPU monitoring
- 🔄 AMD GPU monitoring
- 📹 Recording functionality
- 🎥 Multiple simultaneous camera support
- 🔊 Audio description output (TTS)
- 📱 Mobile app support
- 🏆 Benchmark mode with side-by-side comparison
- 📊 Export analysis results (JSON, CSV)
- ⚡ **Hardware-accelerated video processing on Jetson** - Use NVENC/NVDEC

See [Contributing Guide](./CONTRIBUTING.md) for details.

---

## 📦 Project Structure

```
live-vlm-webui/
├── server.py            # Main WebRTC server with WebSocket support
├── video_processor.py   # Video frame processing and VLM integration
├── gpu_monitor.py       # Cross-platform GPU/system monitoring
├── index.html           # Frontend web UI
├── requirements.txt     # Python dependencies
├── start_server.sh      # Quick start script with SSL
├── start_container.sh   # Auto-detection Docker launcher
├── generate_cert.sh     # SSL certificate generation
├── Dockerfile           # Docker image for x86_64 PC
├── Dockerfile.jetson-orin  # Docker image for Jetson Orin
├── Dockerfile.jetson-thor  # Docker image for Jetson Thor
├── docker-compose.yml      # Unified stack (Ollama + NIM + future backends)
├── docs/                # Detailed documentation
│   ├── setup/           # Setup guides
│   ├── usage/           # Usage guides
│   ├── development/     # Developer guides
│   └── troubleshooting.md
└── README.md           # This file
```

---

## 📄 License

MIT License - Feel free to use and modify for your projects!

---

## 🙏 Acknowledgments

- Built with [aiortc](https://github.com/aiortc/aiortc) - Python WebRTC implementation
- Compatible with [vLLM](https://github.com/vllm-project/vllm), [SGLang](https://github.com/sgl-project/sglang), and [Ollama](https://ollama.ai/)
- Inspired by the growing ecosystem of open-source vision language models, including [NanoVLM](https://dusty-nv.github.io/NanoLLM/)

---

## 📝 Citation

If you use this in your research or project, please cite:

```bibtex
@software{live_vlm_webui,
  title = {Live VLM WebUI: Real-time Vision AI Interaction},
  year = {2025},
  url = {https://github.com/nvidia-ai-iot/live-vlm-webui}
}
```
