# Technical Guides & Scripts Collection

A comprehensive, curated collection of technical guides and scripts covering AI/ML infrastructure, cybersecurity, system administration, and specialized development topics. All content is focused on practical, real-world implementations with a strong emphasis on privacy, security, and open-source solutions.

**Primary Focus:** Linux (Arch/CachyOS/Manjaro) | Privacy-First AI | Security Research | System Administration

---

## Table of Contents

- [Quick Navigation](#quick-navigation)
- [Repository Structure](#repository-structure)
- [Featured Guides](#featured-guides)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Navigation

### 🤖 [AI & Machine Learning](01-AI-AND-MACHINE-LEARNING/)
- **[Local LLM Deployment](01-AI-AND-MACHINE-LEARNING/local-llm-deployment/)** — Ollama, Open WebUI, Android, hardware guides
- **[Image/Video Generation](01-AI-AND-MACHINE-LEARNING/image-video-generation/)** — ComfyUI, Stable Diffusion 3.5, Flux
- **[AI Coding Tools](01-AI-AND-MACHINE-LEARNING/ai-coding-tools/)** — Continue.dev, Void, IDE comparison

### 🔒 [Security](02-SECURITY/)
- **[Cybersecurity](02-SECURITY/cybersecurity/)** — CAI + Ollama, Kali NetHunter, Shadow Brokers research
- **[OSINT](02-SECURITY/osint/)** — Tool catalogue, social media scraping, dark web workflows

### ☁️ [Infrastructure](03-INFRASTRUCTURE/)
- **[Cloud Management](03-INFRASTRUCTURE/cloud-management/)** — AWS full-account nuke script
- **[Virtualization](03-INFRASTRUCTURE/virtualization/)** — Windows-from-bare-metal VM, Android emulator
- **[Networking](03-INFRASTRUCTURE/networking/)** — Remote SSH access, DDNS, port forwarding

### 🛠️ [System Administration](04-SYSTEM-ADMINISTRATION/)
- **[Troubleshooting](04-SYSTEM-ADMINISTRATION/troubleshooting/)** — Hardware change recovery, NVIDIA VBIOS, TV-as-monitor dropouts
- **[File Recovery](04-SYSTEM-ADMINISTRATION/file-recovery/)** — Windows NVMe recovery from Linux
- **[Hardware](04-SYSTEM-ADMINISTRATION/hardware/)** — HP Reverb G2 VR on Arch Linux

### 💻 [Development](05-DEVELOPMENT/)
- **[Robotics](05-DEVELOPMENT/robotics/)** — ABB IRB 1600 with ROS, Gazebo, RViz
- **[Scripting](05-DEVELOPMENT/scripting/)** — Python → TypeScript MCP server conversion

### 🔧 [Tools & Utilities](06-TOOLS-AND-UTILITIES/)
- **yt-dlp** — Download video/audio from any platform

---

## Repository Structure

```
guides-and-scripts/
│
├── 01-AI-AND-MACHINE-LEARNING/
│   ├── local-llm-deployment/        # Ollama, Open WebUI, Android, hardware guides
│   ├── image-video-generation/      # ComfyUI, SD3.5, Flux
│   └── ai-coding-tools/             # Continue.dev, Void, IDE comparison
│
├── 02-SECURITY/
│   ├── cybersecurity/               # CAI, NetHunter, Shadow Brokers research
│   └── osint/                       # Tool catalogue, scraping, dark web
│
├── 03-INFRASTRUCTURE/
│   ├── cloud-management/            # AWS nuke script
│   ├── virtualization/              # Windows-from-disk VM, Android emulator
│   └── networking/                  # SSH remote access, DDNS
│
├── 04-SYSTEM-ADMINISTRATION/
│   ├── troubleshooting/             # Hardware recovery, NVIDIA VBIOS, display dropouts
│   ├── file-recovery/               # Windows NVMe recovery
│   └── hardware/                    # VR headset setup
│
├── 05-DEVELOPMENT/
│   ├── robotics/                    # ROS, Gazebo, ABB simulation
│   └── scripting/                   # Python → TypeScript MCP conversion
│
└── 06-TOOLS-AND-UTILITIES/
    └── yt-dlp.md                    # Video/audio downloader quickstart
```

---

## Featured Guides

### 🌟 Most Comprehensive
- **[Local LLM Comparison & Setup](01-AI-AND-MACHINE-LEARNING/local-llm-deployment/localhosting.md)** - Complete guide to choosing and deploying local AI assistants
- **[Shadow Brokers Tools Research](02-SECURITY/cybersecurity/Shadow-Broker-tools-deepresearch.md)** - In-depth analysis of NSA exploit tools
- **[OSINT Tool Overview](02-SECURITY/osint/tool-overview.md)** - Comprehensive catalog of intelligence gathering tools

### 🚀 Quick Start Guides
- **[Continue.dev + Ollama Setup](01-AI-AND-MACHINE-LEARNING/ai-coding-tools/ContinueOllama.md)** - AI coding assistant in 10 minutes
- **[Android Ollama API](01-AI-AND-MACHINE-LEARNING/local-llm-deployment/Android-ollama-api.md)** - Run AI on your Pixel phone
- **[Remote SSH Access](03-INFRASTRUCTURE/networking/remote-ssh-desktop.md)** - Securely access your home system from anywhere

### 🔧 Advanced Technical
- **[Windows VM from Bare Metal](03-INFRASTRUCTURE/virtualization/WINDOWS-AS-VM.md)** - Advanced raw disk access configuration
- **[HP Reverb G2 on Linux](04-SYSTEM-ADMINISTRATION/hardware/LinuxVR.md)** - Complete VR setup for Arch Linux
- **[Python to TypeScript Migration](05-DEVELOPMENT/scripting/py-to-ts-deepresearch.md)** - Convert OSINT tools to MCP servers

### 💰 Practical Resources
- **[AI Hardware Recommendations](01-AI-AND-MACHINE-LEARNING/local-llm-deployment/)** - Budget & high-end laptop guides
- **[Social Media Scraping](02-SECURITY/osint/social-media-webscraping.md)** - 2025 API access & scraping methods

---

## Getting Started

### Browse by Category
1. Use the **Quick Navigation** section above to jump to your area of interest
2. Each directory contains focused guides on related topics
3. Look for "Featured Guides" if you're not sure where to start

### Search for Specific Topics
```bash
# Clone the repository
git clone https://github.com/cycloarcane/guides-and-scripts.git
cd guides-and-scripts

# Search for specific topics
grep -r "keyword" --include="*.md"

# Browse directory structure
tree -L 3
```

### Common Use Cases

**"I want to run AI models locally"**
→ Start with [Local LLM Deployment](01-AI-AND-MACHINE-LEARNING/local-llm-deployment/localhosting.md)

**"I need OSINT tools for investigations"**
→ Check [OSINT Tool Overview](02-SECURITY/osint/tool-overview.md)

**"I'm learning penetration testing"**
→ Read [CAI Ollama Setup](02-SECURITY/cybersecurity/CAI-Ollama.md) and [Shadow Brokers Research](02-SECURITY/cybersecurity/Shadow-Broker-tools-deepresearch.md)

**"I want to access my home computer remotely"**
→ Follow [Remote SSH Desktop](03-INFRASTRUCTURE/networking/remote-ssh-desktop.md)

**"I need to recover data from a formatted drive"**
→ Use [Windows Recovery Guide](04-SYSTEM-ADMINISTRATION/file-recovery/windowsrecovery.md)


---

## Key Features

✅ **Privacy-First** - Emphasis on local processing and open-source tools
✅ **Linux-Focused** - Primarily Arch/CachyOS/Manjaro, adaptable to other distros
✅ **Production-Ready** - Battle-tested guides from real-world implementations
✅ **Security-Conscious** - Best practices and risk mitigation strategies
✅ **Hardware Recommendations** - Practical buying guides for AI/ML workloads
✅ **Up-to-Date** - Maintained with current software versions and methods (2025)

---

## Technical Specifications

**Primary OS:** Arch Linux, CachyOS, Manjaro
**Desktop Environment:** KDE Plasma
**AI Framework:** Ollama, Open WebUI, ComfyUI
**GPU Support:** NVIDIA CUDA (primary), AMD ROCm (selective)
**Container Runtime:** Podman (userspace), Docker (legacy)
**Languages:** Python, TypeScript, Bash, Markdown

---

## Contributing

Contributions are welcome! Whether you're fixing typos, updating outdated information, or adding new guides:

1. **Fork** this repository
2. **Create a branch** for your changes (`git checkout -b improve-llm-guide`)
3. **Make your changes** - ensure guides are clear, tested, and practical
4. **Commit** with descriptive messages
5. **Push** to your fork
6. **Open a Pull Request** with details about your contribution

### Contribution Guidelines
- Keep guides focused and practical
- Include troubleshooting sections where applicable
- Test commands and procedures before submitting
- Use clear, concise language
- Add references to official documentation
- Update the README if adding new categories

---

## Maintenance Status

🟢 **Actively Maintained** - Repository is regularly updated with new content and fixes

**Last Major Update:** May 2026 - Repository restructure, category rationalisation, new per-category READMEs

---

## Support & Contact

- **Issues:** [GitHub Issues](https://github.com/cycloarcane/guides-and-scripts/issues)
- **Email:** cycloarkane@gmail.com
- **GitHub:** [@cycloarcane](https://github.com/cycloarcane)

---

## License

**MIT License** - Free to use, modify, and distribute for personal or commercial purposes.

See [LICENSE](LICENSE) file for full details.

---

## Acknowledgments

This repository represents years of practical experience with Linux system administration, AI infrastructure, security research, and development. All guides are based on real-world implementations and have been tested in production environments.

Special thanks to the open-source community for the tools and knowledge that made these guides possible.

---

**⭐ Star this repository if you find it useful!**

*Last updated: May 2026*
