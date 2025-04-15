# 🧠 Dumping and Flashing NVIDIA VBIOS on Arch/CachyOS (with iGPU active)

## 🚀 Overview

This guide walks through using `nvflash` to **dump** and **flash** your GPU’s VBIOS on Arch/CachyOS when the system has an **iGPU and strict kernel memory protections**. You'll boot from the iGPU, disable the NVIDIA driver, and use `nvflash` safely.

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

### 8. **Obtain a new VBIOS**

1. Visit [https://www.techpowerup.com/vgabios/](https://www.techpowerup.com/vgabios/)
2. Search for your exact GPU model (e.g., RTX 3090 Founders Edition)
3. Download the `.rom` file for your card that matches the version, vendor, and subsystem ID

---

### 9. **Flash the new VBIOS**

**IMPORTANT: Double-check that your GPU is a Founders Edition before proceeding.**

With the downloaded VBIOS file in the current directory:

```bash
sudo nvflash --protectoff
sudo nvflash -6 downloaded.rom
```

Type `YES` when prompted to confirm the flash.

---

### 10. **Remove blacklist and restore graphical boot**

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

You’ve now safely dumped and flashed your `.rom` VBIOS file without needing to unload live drivers or risk damage. Great for restoring stock firmware or correcting power telemetry issues on compatible cards.

