# Open-WebUI with Podman Setup Guide

## Overview
This guide covers migrating from Docker to Podman for running Open-WebUI in userspace, connecting to a locally installed Ollama backend.

## Prerequisites
- Ollama installed locally on the system
- Podman installed (`sudo pacman -S podman`)
- User removed from docker group (`sudo gpasswd -d $USER docker`)

## 1. Purge Docker Installation

### Stop and remove all Docker containers, images, and data:
```bash
# Stop all running containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true

# Remove all containers
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

# Remove all images
sudo docker rmi $(sudo docker images -q) 2>/dev/null || true

# Remove all volumes
sudo docker volume prune -f

# Remove all networks (except defaults)
sudo docker network prune -f

# Complete system prune (removes everything)
sudo docker system prune -a -f --volumes
```

### Optional: Completely remove Docker
```bash
# Stop and disable Docker service
sudo systemctl stop docker
sudo systemctl disable docker

# Remove Docker packages
sudo pacman -Rns docker docker-compose

# Remove Docker data directory
sudo rm -rf /var/lib/docker
```

## 2. Setup Open-WebUI with Podman

### Ensure Ollama is running
```bash
# Check if Ollama is running
systemctl --user status ollama
# or
ps aux | grep ollama

# If not running, start it
ollama serve
```

### Run Open-WebUI container
```bash
podman run -d \
  --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  -v open-webui:/app/backend/data \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main
```

### Access the interface
Open your browser and navigate to: `http://localhost:3000`

## 3. Container Management

### Useful Podman commands
```bash
# Check running containers
podman ps

# View logs
podman logs open-webui

# Stop container
podman stop open-webui

# Start container
podman start open-webui

# Restart container
podman restart open-webui
```

## 4. Updating Open-WebUI

### Update to latest version
```bash
# Stop and remove container
podman stop open-webui
podman rm open-webui

# Pull latest image
podman pull ghcr.io/open-webui/open-webui:main

# Recreate container with same settings
podman run -d \
  --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  -v open-webui:/app/backend/data \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main
```

### Create update script (optional)
Create a file called `update-webui.sh`:
```bash
#!/bin/bash
echo "Updating Open-WebUI..."
podman stop open-webui
podman rm open-webui
podman pull ghcr.io/open-webui/open-webui:main
podman run -d \
  --name open-webui \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  -v open-webui:/app/backend/data \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main
echo "Update complete!"
```

Make it executable:
```bash
chmod +x update-webui.sh
```

## 5. Troubleshooting

### Container can't reach Ollama
- Ensure Ollama is running on port 11434
- Check if `host.containers.internal` resolves correctly
- Alternative: Use your actual IP address instead of `host.containers.internal`

### Check Ollama connectivity
```bash
# From host
curl http://localhost:11434/api/tags

# Test from inside container
podman exec -it open-webui curl http://host.containers.internal:11434/api/tags
```

### View detailed logs
```bash
podman logs -f open-webui
```

## 6. Benefits of This Setup

- **No root privileges**: Podman runs entirely in userspace
- **Better security**: No docker group membership required
- **Native Ollama performance**: Direct installation without containerization overhead
- **Easy updates**: Simple container recreation process
- **Data persistence**: Named volumes preserve your chats and settings

## Notes

- Data is stored in the `open-webui` named volume and persists across updates
- The `--restart unless-stopped` flag ensures the container starts automatically after reboot
- Use `podman` instead of `docker` for all commands - syntax is nearly identical