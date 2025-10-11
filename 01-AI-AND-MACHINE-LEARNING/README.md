# AI & Machine Learning

Comprehensive guides for deploying AI/ML infrastructure with a focus on privacy, local processing, and open-source solutions.

## 📂 Subcategories

### [Local LLM Deployment](local-llm-deployment/)
Run powerful language models locally without cloud dependencies

**Guides:**
- `localhosting.md` - Complete comparison of local LLM solutions (Open WebUI, LoLLMS, Verbi)
- `AI-capable-Laptop-sub-1000.md` - Budget laptop recommendations for AI (under £1000, 8GB+ VRAM)
- `AI-capable-Laptop-no-budget.md` - High-end laptops with 16GB VRAM (RTX 4090)
- `Android-ai-api.md` - Running Qwen3-14B on Pixel 9 Pro
- `Android-ollama-api.md` - Step-by-step Ollama setup on Android (Termux)
- `Open-WebUI-Docker-to-Podman.md` - Migrate from Docker to Podman (userspace containers)
- `OpenWebUI-Google-Calendar.md` - Integrate Google Calendar API with OpenWebUI

### [Image/Video Generation](image-video-generation/)
AI-powered media generation using ComfyUI and diffusion models

**Guides:**
- `comfyui-and-manager-mac.md` - ComfyUI installation for macOS
- `comfy-flux-install.md` - Flux model setup and configuration
- `comfy-sd3-install.md` - Stable Diffusion 3.5 installation guide

### [AI Coding Tools](ai-coding-tools/)
Privacy-focused AI-assisted development environments

**Guides:**
- `osvibecoding.md` - Comparison of privacy-focused AI coding IDEs (Void, Continue.dev, Tabby, Codeium, Zed)
- `ContinueOllama.md` - Setting up Continue.dev extension with Ollama on Arch Linux

## 🎯 Quick Start

**New to local AI?** Start with:
1. [Local LLM Deployment Comparison](local-llm-deployment/localhosting.md)
2. Choose your hardware from [budget](local-llm-deployment/AI-capable-Laptop-sub-1000.md) or [high-end](local-llm-deployment/AI-capable-Laptop-no-budget.md) guides
3. Set up [Continue.dev with Ollama](ai-coding-tools/ContinueOllama.md) for AI coding assistance

**Want to generate images?** Follow:
1. [ComfyUI Setup](image-video-generation/comfyui-and-manager-mac.md)
2. Install [Flux](image-video-generation/comfy-flux-install.md) or [SD3.5](image-video-generation/comfy-sd3-install.md) models

## 🔑 Key Technologies

- **LLM Runtimes:** Ollama, Llama.cpp, LocalAI
- **Frontends:** Open WebUI, LoLLMS Web UI, Verbi
- **Image Generation:** ComfyUI, Stable Diffusion, Flux
- **AI Coding:** Continue.dev, Void IDE, Tabby, Codeium
- **Platforms:** Arch Linux, macOS, Android (Termux)
- **Hardware:** NVIDIA CUDA (RTX 4060/4090), Mobile (Pixel 9 Pro)

## 📊 Hardware Requirements

| Use Case | Minimum VRAM | Recommended Model | Guide |
|----------|--------------|-------------------|-------|
| Code assistance | 4GB | 7B parameter models | [ContinueOllama.md](ai-coding-tools/ContinueOllama.md) |
| Chat/Assistant | 8GB | 13-30B models | [localhosting.md](local-llm-deployment/localhosting.md) |
| Image generation | 8GB | SD3.5/Flux | [comfy-sd3-install.md](image-video-generation/comfy-sd3-install.md) |
| Mobile AI | 4GB+ RAM | Small models (3-14B) | [Android-ollama-api.md](local-llm-deployment/Android-ollama-api.md) |

## 🛠️ Common Tasks

**Deploy Open WebUI locally:**
→ Follow [Open-WebUI-Docker-to-Podman.md](local-llm-deployment/Open-WebUI-Docker-to-Podman.md)

**Add AI to VS Code:**
→ Use [ContinueOllama.md](ai-coding-tools/ContinueOllama.md)

**Run AI on Android:**
→ Install via [Android-ollama-api.md](local-llm-deployment/Android-ollama-api.md)

**Generate images with Flux:**
→ Setup with [comfy-flux-install.md](image-video-generation/comfy-flux-install.md)

---

[← Back to Main README](../README.md)
