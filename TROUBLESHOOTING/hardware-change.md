# Repair Guide: Chroot, Update, and Clear KDE Configurations

This guide will help you:
- Mount your drives and decrypt your root partition (if encrypted)
- Chroot into your Manjaro installation
- Update your system to support new hardware changes (e.g., Ryzen 5600G iGPU)
- Regenerate your initramfs
- Clear KDE screen configuration to fix display issues

---

## Step 1: Boot into a Live Environment

1. Boot from your Manjaro live USB.
2. Open a terminal.

---

## Step 2: Mount and Decrypt Your Partitions

### a. Identify Your Partitions
Run:

```bash
lsblk -f
```
Identify:

- **Root Partition:** (e.g., `/dev/nvme1n1p2`)
- **EFI Partition:** (e.g., `/dev/nvme1n1p1`) if applicable

### b. Decrypt Your LUKS Partition (if needed)
If your root partition is encrypted, open it:

```bash
sudo cryptsetup open /dev/nvme1n1p2 myroot
```

This creates a mapped device at `/dev/mapper/myroot`.

### c. Mount the Root Partition

```bash
sudo mkdir -p /mnt
sudo mount /dev/mapper/myroot /mnt
```

### d. Mount the EFI Partition (if applicable)

```bash
sudo mkdir -p /mnt/boot/efi
sudo mount /dev/nvme1n1p1 /mnt/boot/efi
```

### e. Bind System Directories
This makes sure your chroot environment works correctly:

```bash
sudo mount -t proc /proc /mnt/proc
sudo mount --rbind /sys /mnt/sys
sudo mount --rbind /dev /mnt/dev
sudo mount --rbind /run /mnt/run
```

---

## Step 3: Chroot into Your System

Enter your installed system:

```bash
sudo chroot /mnt
```

---

## Step 4: Update System and Regenerate initramfs

### a. Update Your System

```bash
pacman -Syu
```

### b. Install New Hardware Drivers (for AMD iGPU)

```bash
pacman -S mesa xf86-video-amdgpu amd-ucode
```

### c. Regenerate the initramfs

```bash
mkinitcpio -P
```

---

## Step 5: Exit chroot and Unmount

### a. Exit the chroot

```bash
exit
```

### b. Unmount All Partitions

```bash
sudo umount -R /mnt
```

### c. Close the LUKS Mapping (if applicable)

```bash
sudo cryptsetup close myroot
```

---

## Step 6: Reboot

Remove the live USB and reboot:

```bash
sudo reboot
```

---

## Step 7: Clear KDE Screen Configuration

Once you’ve logged back into your system, if you still experience display issues (like a black screen with a blinking cursor), clear KDE’s stored screen configuration:

```bash
rm -rf ~/.local/share/kscreen 2>/dev/null
```

This forces KDE Plasma to regenerate a fresh screen configuration on your next login.

---

## Summary Checklist

- **Boot from Live USB**
- **Mount & Decrypt Partitions:**
  - Decrypt LUKS (if needed)
  - Mount root (`/mnt`)
  - Mount EFI (`/mnt/boot/efi`)
  - Bind `/proc`, `/sys`, `/dev`, `/run`
- **Chroot into System:** `sudo chroot /mnt`
- **Update & Install Drivers:** `pacman -Syu` and `pacman -S mesa xf86-video-amdgpu amd-ucode`
- **Regenerate initramfs:** `mkinitcpio -P`
- **Exit & Unmount:** `exit` then `sudo umount -R /mnt` (and close LUKS if needed)
- **Reboot:** `sudo reboot`
- **Clear KDE Screen Config:** `rm -rf ~/.local/share/kscreen 2>/dev/null`

