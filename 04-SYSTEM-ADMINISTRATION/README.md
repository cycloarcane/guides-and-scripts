# System Administration

Guides for system troubleshooting, hardware fixes, and data recovery on Linux systems.

## 📂 Subcategories

### [Troubleshooting](troubleshooting/)
System recovery, hardware changes, and BIOS/VBIOS management

**Guides:**
- `hardware-change.md` - Manjaro/Arch repair guide for hardware changes
  - Chroot into system from live environment
  - System updates and package reinstallation
  - Initramfs regeneration for new hardware
  - Ryzen 5600G iGPU support
  - KDE configuration recovery

- `dump-nvidia-vbios.md` - NVIDIA VBIOS dumping using nvflash
  - iGPU setup for display during VBIOS dump
  - Disabling NVIDIA drivers temporarily
  - Memory protection handling on Arch/CachyOS

- `flash-nvidia-vbios.md` - NVIDIA VBIOS dumping AND flashing
  - Complete procedure for VBIOS modification
  - Safety precautions and rollback procedures

### [File Recovery](file-recovery/)
Data recovery and forensics for formatted/corrupted drives

**Guides:**
- `windowsrecovery.md` - Windows NVMe data recovery using Arch Linux
  - Drive identification with lsblk
  - Backup imaging using ddrescue
  - Recovery from formatted Windows drives
  - Step-by-step troubleshooting workflow

## 🎯 Quick Start

**System won't boot after hardware change:**
→ Follow [hardware-change.md](troubleshooting/hardware-change.md)

**Need to dump NVIDIA VBIOS:**
→ Use [dump-nvidia-vbios.md](troubleshooting/dump-nvidia-vbios.md)

**Recover data from formatted Windows drive:**
→ Follow [windowsrecovery.md](file-recovery/windowsrecovery.md)

## 🔑 Key Technologies

- **Boot Recovery:** Arch ISO, chroot, mkinitcpio
- **Data Recovery:** ddrescue, TestDisk, PhotoRec
- **BIOS Tools:** nvflash, GPU-Z
- **File Systems:** NTFS, ext4, FAT32
- **Hardware:** NVIDIA GPUs, AMD Ryzen iGPUs, NVMe drives

## ⚠️ Safety Warnings

### Hardware Changes
- Always backup data before major hardware changes
- Keep Arch/Manjaro installation media handy
- Document current configuration before changes
- Test new hardware compatibility first

### VBIOS Flashing
- **CRITICAL:** Wrong VBIOS can brick your GPU
- Always dump current VBIOS before flashing
- Verify VBIOS file is for exact GPU model
- Keep iGPU or secondary GPU for recovery
- Flash at your own risk

### Data Recovery
- NEVER write to the drive you're recovering from
- Always create full disk image first (ddrescue)
- Work from the image, not the original drive
- Additional writes reduce recovery chances

## 📊 Common Scenarios

| Issue | Guide | Time Required |
|-------|-------|---------------|
| Boot failure after CPU/mobo change | [hardware-change.md](troubleshooting/hardware-change.md) | 30-60 min |
| NVIDIA VBIOS backup | [dump-nvidia-vbios.md](troubleshooting/dump-nvidia-vbios.md) | 15-30 min |
| VBIOS flash | [flash-nvidia-vbios.md](troubleshooting/flash-nvidia-vbios.md) | 30-45 min |
| Formatted Windows drive recovery | [windowsrecovery.md](file-recovery/windowsrecovery.md) | 2-8 hours |

## 🛠️ Common Tasks

### System Recovery After Hardware Change

```bash
# Boot from Arch/Manjaro ISO
# Mount your root partition
sudo mount /dev/nvme0n1p2 /mnt

# Mount EFI partition
sudo mount /dev/nvme0n1p1 /mnt/boot/efi

# Chroot into system
sudo arch-chroot /mnt

# Update system
pacman -Syu

# Regenerate initramfs
mkinitcpio -P

# Update GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### NVIDIA VBIOS Dump

```bash
# Install nvflash
yay -S nvflash

# Disable NVIDIA driver
sudo systemctl stop display-manager
sudo modprobe -r nvidia_drm nvidia_modeset nvidia

# Dump VBIOS (using iGPU for display)
sudo nvflash --save vbios_backup.rom

# Re-enable driver
sudo modprobe nvidia
sudo systemctl start display-manager
```

### Data Recovery Workflow

```bash
# Identify target drive
lsblk

# Create full disk image (safe to interrupt and resume)
sudo ddrescue -d /dev/sdX /path/to/image.img /path/to/logfile.log

# Scan image for recoverable files
testdisk /path/to/image.img

# Or use PhotoRec for file carving
photorec /path/to/image.img
```

## 🔧 Troubleshooting Tips

### Boot Issues
- Check `/etc/fstab` for correct UUIDs after hardware change
- Verify kernel modules load correctly: `lsmod | grep nouveau/nvidia`
- Check boot logs: `journalctl -xb`
- Test with fallback kernel from GRUB menu

### GPU Issues
- Verify GPU is detected: `lspci | grep VGA`
- Check driver status: `nvidia-smi` or `glxinfo | grep OpenGL`
- Monitor temperature: `nvidia-smi -q -d TEMPERATURE`
- Test with nouveau driver if NVIDIA driver fails

### Recovery Issues
- If ddrescue is slow, check SMART status: `smartctl -a /dev/sdX`
- Use `-n` flag with ddrescue to avoid reading bad sectors initially
- For NTFS, run `ntfsfix` on recovered partition
- Check recovered files with `file` command to verify integrity

## 📋 Required Tools

### System Recovery
```bash
sudo pacman -S arch-install-scripts  # For arch-chroot
sudo pacman -S grub efibootmgr       # Boot management
sudo pacman -S linux linux-headers   # Kernel
```

### VBIOS Management
```bash
yay -S nvflash                       # NVIDIA VBIOS tool
sudo pacman -S mesa                  # For iGPU support
```

### Data Recovery
```bash
sudo pacman -S ddrescue              # Disk imaging
sudo pacman -S testdisk              # Partition recovery
sudo pacman -S smartmontools         # Drive health check
```

## 🚨 Emergency Procedures

### System Won't Boot
1. Boot from Arch/Manjaro live USB
2. Chroot into system following [hardware-change.md](troubleshooting/hardware-change.md)
3. Check logs: `journalctl -xb -p err`
4. Reinstall critical packages: `pacman -S linux linux-firmware`
5. Rebuild initramfs: `mkinitcpio -P`

### GPU Not Working After VBIOS Flash
1. Boot using iGPU (set in BIOS)
2. Flash original VBIOS backup: `sudo nvflash -6 original_backup.rom`
3. If no backup, download from TechPowerUp VBIOS database
4. Verify exact GPU model before flashing

### Data Recovery Last Resort
1. If ddrescue fails, try `dd_rescue` or `GNU ddrescue` with different options
2. Use PhotoRec for file carving (ignores file system)
3. Try recovery on different system/USB adapter
4. Consider professional data recovery services for critical data

---

[← Back to Main README](../README.md)
