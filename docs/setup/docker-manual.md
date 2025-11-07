# Manual Docker Deployment

This guide covers manual Docker deployment options for advanced users who want fine-grained control.

## Manual Docker Run Commands

### PC (x86_64)

```bash
docker run -d \
  --name live-vlm-webui \
  --network host \
  --gpus all \
  ghcr.io/nvidia-ai-iot/live-vlm-webui:latest-x86
```

### Jetson Orin

```bash
docker run -d \
  --name live-vlm-webui \
  --network host \
  --runtime nvidia \
  --privileged \
  -v /run/jtop.sock:/run/jtop.sock:ro \
  ghcr.io/nvidia-ai-iot/live-vlm-webui:latest-jetson-orin
```

### Jetson Thor

```bash
docker run -d \
  --name live-vlm-webui \
  --network host \
  --gpus all \
  --privileged \
  -v /run/jtop.sock:/run/jtop.sock:ro \
  ghcr.io/nvidia-ai-iot/live-vlm-webui:latest-jetson-thor
```

## Building Your Own Images

### Build from Source

**For x86_64 PC:**
```bash
docker build -t live-vlm-webui:x86 .
```

**For Jetson Orin:**
```bash
docker build -f Dockerfile.jetson-orin -t live-vlm-webui:jetson-orin .
```

**For Jetson Thor:**
```bash
docker build -f Dockerfile.jetson-thor -t live-vlm-webui:jetson-thor .
```

## Network Modes

### Host Network (Recommended for Local VLM)

Use `--network host` when connecting to services on the same host:

```bash
docker run -d \
  --name live-vlm-webui \
  --network host \
  --gpus all \
  live-vlm-webui:x86
```

**Benefits:**
- ✅ Container can access `localhost:11434` (Ollama)
- ✅ Container can access `localhost:8000` (vLLM, NIM)
- ✅ No port mapping needed

### Bridge Network (For Remote VLM)

Use `-p` port mapping when connecting to remote services:

```bash
docker run -d \
  --name live-vlm-webui \
  -p 8090:8090 \
  --gpus all \
  -e VLM_API_BASE=http://your-vlm-server:8000/v1 \
  -e VLM_MODEL=llama-3.2-11b-vision-instruct \
  live-vlm-webui:x86
```

## Environment Variables

Configure the application using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `VLM_API_BASE` | Auto-detected | VLM API endpoint URL |
| `VLM_MODEL` | Auto-detected | Model name to use |
| `VLM_PROMPT` | "Describe..." | Default prompt |
| `VLM_API_KEY` | - | API key (for cloud services) |
| `PORT` | 8090 | Server port |

## Custom SSL Certificates

For production deployment with your own SSL certificates:

```bash
docker run -d \
  --name live-vlm-webui \
  -p 8090:8090 \
  -v /path/to/your/cert.pem:/app/cert.pem:ro \
  -v /path/to/your/key.pem:/app/key.pem:ro \
  live-vlm-webui:x86
```

## Dockerfile Details

### `Dockerfile` - For x86_64 PC/Workstation

**Base Image:** `nvidia/cuda:12.4.1-runtime-ubuntu22.04`
- Includes NVIDIA CUDA runtime libraries for GPU monitoring via NVML
- Enables `pynvml` to query GPU name, utilization, VRAM, temperature, and power
- Compatible with NVIDIA drivers 545+ (GeForce, Quadro, Tesla, etc.)
- Image size: ~1.5GB (compressed)

### `Dockerfile.jetson-orin` - For NVIDIA Jetson Orin

**Base Image:** `nvcr.io/nvidia/l4t-base:r36.2.0` (L4T r36.2.0, JetPack 6.0)
- Optimized for Jetson Orin platform (AGX Orin, Orin Nano, Orin NX)
- Uses `jtop` (jetson-stats from PyPI) for GPU monitoring
- Supports JetPack 6.x
- Image size: ~1.2GB (compressed)

### `Dockerfile.jetson-thor` - For NVIDIA Jetson Thor

**Base Image:** `nvcr.io/nvidia/cuda:13.0.0-runtime-ubuntu24.04`
- **Jetson Thor is SBSA-compliant** - Uses standard NGC CUDA containers (no L4T-specific images needed!)
- This is a major architectural change from previous Jetsons (Orin, Xavier)
- Uses `jtop` (jetson-stats from GitHub) for latest Thor GPU monitoring support
- Ubuntu 24.04 base (aligned with JetPack 7.x)
- Reference: [Jetson Thor CUDA Setup Guide](https://docs.nvidia.com/jetson/agx-thor-devkit/user-guide/latest/setup_cuda.html)

**Why separate Dockerfiles?**
- **Jetson Orin**: Requires L4T-specific base images (`l4t-base:r36.x`)
- **Jetson Thor**: SBSA-compliant, uses standard CUDA containers
- **Monitoring**: Both use `jtop` for GPU stats (NVML limited on Jetson)
- **jetson-stats source**: Orin uses PyPI (stable), Thor uses GitHub (bleeding-edge support)

