# 🧠 Dumping NVIDIA VBIOS on Arch/CachyOS (with iGPU active)

## 🚀 Overview

This guide walks through using `nvflash` to dump your GPU’s VBIOS on Arch/CachyOS when the system has an **iGPU and strict kernel memory protections**. You'll boot from the iGPU, disable the NVIDIA driver, and use `nvflash` safely.

---

## ✅ Requirements

- **NVIDIA GPU present** (3090 in this case)
- **iGPU available + enabled** (e.g., Ryzen 5600G)
- **Root access**
- **CachyOS or Arch-based system**
- **systemd-boot (or similar)**

---

## 💪 Steps

### 1. **Install nvflash**

```bash
yay -S nvflash-bin
```

---

### 2. **Enable iGPU in BIOS**

- Set **Primary Display** to **iGPU** or **Integrated Graphics**
- Plug your monitor into the **motherboard** (not the GPU)

---

### 3. **Create blacklist to stop NVIDIA modules from loading**

```bash
sudo nano /etc/modprobe.d/nvidia-disable.conf
```

Add:

```bash
install nvidia /bin/false
install nvidia_drm /bin/false
install nvidia_uvm /bin/false
install nvidia_modeset /bin/false
```

---

### 4. **Rebuild initramfs**

```bash
sudo mkinitcpio -P
```

---

### 5. **Reboot into multi-user.target**

Set boot to text mode:

```bash
sudo systemctl set-default multi-user.target
sudo reboot
```

---

### 6. **Set temporary kernel param at boot**

At the **systemd-boot menu**:

1. Highlight your Arch entry
2. Press `e`
3. Add `iomem=relaxed` to the end of the `options` line
4. Press `Enter` or `Ctrl+x` to boot

---

### 7. **Dump the VBIOS**

After booting to TTY, log in and run:

```bash
lsmod | grep nvidia
```

Confirm **no NVIDIA modules are loaded**, then:

```bash
sudo nvflash --save vbios.rom
```

---

### 8. **Remove blacklist and restore graphical boot**

Delete the NVIDIA module blacklist:

```bash
sudo rm /etc/modprobe.d/nvidia-disable.conf
```

Rebuild initramfs:

```bash
sudo mkinitcpio -P
```

Set system to boot back into GUI:

```bash
sudo systemctl set-default graphical.target
sudo reboot
```

---

## ✅ Done!

You’ve now safely dumped your `.rom` file without needing to unload live drivers or risk damage. Perfect for backups, modding, or checking for tampered firmware.