# Setting Up Continue (VS Code Extension) with Ollama on Arch Linux

This guide walks you through installing Ollama on Arch Linux and configuring the Continue VS Code extension to use local Ollama models, including running multiple models and selecting between them.

---

## Prerequisites

- Arch Linux with KDE Plasma
- VS Code installed
- Continue extension installed in VS Code

---

## Step 1: Install Ollama

### Option 1: Install via Official Script

Ollama provides an installation script that detects your system architecture and installs the appropriate version.

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This script will:
- Download the latest Ollama release
- Install the binary to `/usr/bin/ollama`
- Set up a systemd service to run `ollama serve` on startup

After installation, verify that Ollama is installed:

```bash
ollama --version
```

### Option 2: Install via Pacman (Arch Repository)

If available, you can install from the AUR or repository:

For CPU-only usage:

```bash
sudo pacman -S ollama
```

For NVIDIA GPU support:

```bash
sudo pacman -S ollama-cuda
```

For AMD GPU support:

```bash
sudo pacman -S ollama-rocm
```

Note: Ensure that you have the appropriate GPU drivers installed.

---

## Step 2: Start and Enable Ollama Service

Start the Ollama service:

```bash
sudo systemctl start ollama
```

Enable the service to start on boot:

```bash
sudo systemctl enable ollama
```

Check the status of the service:

```bash
sudo systemctl status ollama
```

You should see that the service is active and running.

---

## Step 3: Verify Ollama is Running

Check that Ollama is responding:

```bash
curl http://localhost:11434
```

Expected output:

```Text
Ollama is running!
```

List loaded models:

```bash
curl http://localhost:11434/api/tags
```

---

## Step 4: Pull Required Models

Pull the models you intend to use:

```bash
ollama pull qwen2.5-coder:14b
ollama pull qwen2.5-coder:1.5b
ollama pull nomic-embed-text:latest
```

These models will provide capabilities for chat, autocompletions, and embeddings.

---

## Step 5: Configure Continue

Edit or create your **global** Continue config at `~/.continue/config.yaml`:

Example `~/.continue/config.yaml`:

```yaml
name: Local Ollama Setup
version: 1.0.0
schema: v1

models:
  - name: Qwen Coder 1.5B
    provider: ollama
    model: qwen2.5-coder:1.5b
    apiBase: http://127.0.0.1:11434
    roles:
      - autocomplete

  - name: Qwen Coder 14B
    provider: ollama
    model: qwen2.5-coder:14b
    apiBase: http://127.0.0.1:11434
    capabilities:
      - tool_use
    roles:
      - chat

  - name: Nomic Embed Text
    provider: ollama
    model: nomic-embed-text:latest
    apiBase: http://127.0.0.1:11434
    roles:
      - embed
```

Mandatory keys at the top:
- `name:`
- `version:`
- `schema:`

**If you miss these keys, you will get:**

```
Fatal Error: Failed to parse assistant: name: Required version: Required
```

---

## Step 6: Testing the Setup

Test direct API access:

```bash
curl -X POST http://127.0.0.1:11434/api/generate \
     -d '{"model":"qwen2.5-coder:1.5b","prompt":"Write a function to add two numbers."}'
```

If you get streaming tokens, it's working.

Test Continue inside VS Code:
- Open Command Palette
- Select `Continue: Select Model`
- Choose from your defined models

---

## Step 7: Managing Ollama Models

Check currently loaded models:

```bash
ollama ps
```

Manually unload a model:

```bash
curl -X POST http://localhost:11434/api/generate \
     -d '{"model":"qwen2.5-coder:1.5b","prompt":"","keep_alive":0}'
```

Preload a model indefinitely:

```bash
curl -X POST http://localhost:11434/api/generate \
     -d '{"model":"qwen2.5-coder:1.5b","prompt":"","keep_alive":-1}'
```

---

## TL;DR

- Install Ollama via the official script or Pacman.
- Use systemd to manage the Ollama daemon.
- Pull the models: `qwen2.5-coder:14b`, `qwen2.5-coder:1.5b`, and `nomic-embed-text`.
- Always edit `~/.continue/config.yaml`, not the project folder.
- List every model you want to use.
- Select models easily through the VS Code Command Palette.
- Use `/api/ps` and `keep_alive` to control model memory management.

---

**Now you're fully set up to install Ollama, pull models, and run multiple local models with Continue and Ollama, based on your custom setup!**

