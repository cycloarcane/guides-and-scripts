# Useful Scripts

A curated collection of eclectic scripts and guides that I personally find useful. I’m sharing them in the hope that they might be of help to others. Feel free to copy, adapt, or modify any of these guides however you see fit. Credit would be nice but it’s definitely not required.

---

## Table of Contents

1. [Overview](#overview)
2. [Script Topics](#script-topics)
   - [Remote SSH Access to a Home System When Travelling](#remote-ssh-access-to-a-home-system-when-travelling)
   - [Image Generation with Easy-Diffusion & Flux Models using ComfyUI](#image-generation-with-easy-diffusion--flux-models-using-comfyui)
3. [How to Use](#how-to-use)
4. [Contributing](#contributing)
5. [Contact](#contact)
6. [License](#license)

---

## Overview

This repository is a place for me ([@cycloarcane](https://github.com/cycloarcane)) to store and share various scripts and guides that solve common (or uncommon) tasks I encounter. If you spot anything that could be improved or if you have suggestions, feel free to contribute or open an issue.

---

## Script Topics

### Remote SSH Access to a Home System When Travelling

This guide covers:

- Setting up a dynamic DNS (if needed).
- Configuring your router for port forwarding.
- Generating and using SSH keys securely.
- Tips for ensuring secure remote access and mitigating potential vulnerabilities.
- Possible tunneling and proxy strategies for circumventing restrictive networks.

Use Cases:

- Accessing files or running commands on a home server while you’re on the road.
- Remotely administering a desktop or headless machine for quick tasks.
- Maintaining a persistent SSH connection to your home network for development, backups, or other tasks.

### Image Generation with Easy-Diffusion & Flux Models using ComfyUI

This guide covers:

- Installing and configuring Easy-Diffusion.
- Setting up ComfyUI to work with Flux (and other models).
- Best practices for model selection, sampling parameters, and prompt optimization.
- Useful configuration tips and examples of prompt workflows.
- Potential pitfalls and how to avoid them (e.g., GPU memory usage, dependency management).

Use Cases:

- Generating artistic images with minimal setup and overhead.
- Rapid prototyping of AI-generated art without complicated manual installations.
- Experimenting with advanced features of ComfyUI to handle custom pipelines or model merges.

---

## How to Use

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/cycloarcane/useful-scripts.git
