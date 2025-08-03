# Boot Your Bare‑Metal Windows Installation Inside VirtualBox  
*(Arch Linux host, Windows guest on a separate physical drive)*

> **Goal:** Update, install, or maintain your native Windows install from the comfort of a VM—then reboot and enjoy full bare‑metal gaming performance.

---

## 0  Hard Requirements & Caveats

| ⚠️ Risk | Mitigation |
|---------|------------|
| **Fast Startup / hibernation** corrupts NTFS when you switch OSes | In Windows (once):<br/>`powercfg /h off` & reboot |
| **BitLocker** sees “different hardware” & demands the recovery key | Suspend BitLocker (or keep the key handy) *before* the first VM boot |
| **Activation** may flip to *Not activated* | Link your license to a Microsoft account → **Settings → Activation → Troubleshoot → I changed hardware** |
| **Concurrent access** (mounting NTFS in Linux while VM runs) bricks the filesystem | **Never** mount the Windows partitions on the host while the VM is powered on |
| **Back‑ups** | Raw‑disk mode writes straight to the drive—keep an image backup just in case |

---

## 1  Install VirtualBox & Host Modules

```bash
sudo pacman -S virtualbox virtualbox-host-modules-arch
sudo usermod -aG vboxusers,disk $USER   # vboxusers for USB, disk for raw‑disk
sudo modprobe vboxdrv vboxnetflt
```

---

## 2  Identify Your Windows Drive Safely

```bash
ls -l /dev/disk/by-id/
# Example result:
# nvme-Samsung_SSD_970_WINDOWS -> ../../nvme1n1
DISK=/dev/disk/by-id/nvme-Samsung_SSD_970_WINDOWS
```

Using **`/dev/disk/by-id/`** avoids surprises if `/dev/nvme1n1` changes between boots.

---

## 3  Create a *Raw‑Disk* VMDK

### (A) Whole‑Drive Pass‑Through

```bash
VBoxManage createmedium disk   --filename ~/windows_raw.vmdk   --format VMDK --variant RawDisk   --property RawDrive=$DISK
```

### (B) Only the EFI & Windows Partitions  
*(Replace `1,3` with the actual partition numbers shown by `lsblk`)*

```bash
VBoxManage createmedium disk   --filename ~/windows_raw.vmdk   --format VMDK --variant RawDisk   --property RawDrive=$DISK --property Partitions=1,3
```

Give yourself ownership so VirtualBox can open the file without root:

```bash
sudo chown $USER:$USER ~/windows_raw*.vmdk
```

---

## 4  Build the VM

1. **VirtualBox Manager → New** → name it e.g. **“Win‑Raw”** and pick **Windows 10/11 (64‑bit)**.  
2. Assign RAM & vCPUs as you like.  
3. **System → Enable EFI** (mandatory for modern Windows installs).  
4. **Storage → Add existing disk** → `~/windows_raw.vmdk`.  
5. *(Optional)* Attach **Guest Additions** ISO for better input/video.  
6. Keep the disk bus as **SATA** for the first boot—Windows already has the driver.

---

## 5  First Boot Inside the VM

* Windows enumerates the VirtualBox hardware & installs drivers.  
* Install **Guest Additions**.  
* Shut down cleanly:

```powershell
shutdown /s /t 0
```

*(Do **not** hibernate.)*

---

## 6  Boot Natively to Play

From your firmware boot menu (or GRUB chain‑loader) pick the Windows disk.  
Windows will re‑detect real hardware; one extra reboot is normal.  
If activation complains, run the hardware‑change troubleshooter.

---

## 7  Daily Workflow

```bash
# Host (Arch):
VBoxManage startvm "Win‑Raw" --type gui   # or use the GUI

# -- do Windows Updates, Steam downloads, game‑store log‑ins --

# Inside the guest:
shutdown /s /t 0
```

After the guest powers off you may once again mount the NTFS partition in Linux *or* reboot to game on bare metal.

---

## 8  Optional Extras

* **Snapshots** – convenient for experiments, but remember the underlying disk keeps changing.  
* **USB Passthrough** – needs the Oracle extension pack; useful for flashing controllers or phones.  
* **Separate hardware profiles** – `sysdm.cpl → Hardware → Hardware Profiles` stops Windows from juggling drivers every switch.  
* **GPU passthrough?** – VirtualBox can’t match VFIO/PCIe passthrough performance; stick to maintenance tasks in the VM.

---

## 9  Crib‑Sheet (One‑Liners)

```bash
# One‑time: create raw VMDK
VBoxManage internalcommands createrawvmdk    -filename ~/win.vmdk -rawdisk $DISK

# Start VM when needed
VBoxManage startvm "Win‑Raw" --type gui
```

---

## References & Further Reading

* Arch Wiki – [VirtualBox](https://wiki.archlinux.org/title/VirtualBox)  
* Arch Wiki – [VirtualBox/Install Windows from raw partition](https://wiki.archlinux.org/title/VirtualBox/Install_Windows_from_existing_installation)  
* Microsoft Docs – [Turn off, disable, or enable hibernate](https://learn.microsoft.com/windows-client/tips/turn-off-hibernate)  
* Microsoft Docs – [Reactivate Windows after hardware change](https://support.microsoft.com/windows/reactivating-windows-after-a-hardware-change-b19cbdde-670c-4b9a-3c39-ec002f91a90a)  
* VirtualBox Manual – § 9.16 *Using a Raw Host Hard Disk from a Guest*  

---

### TL;DR

Disable Fast Startup, create a raw‑disk VMDK that points at your Windows drive, boot it in a VirtualBox VM for maintenance, **never** mount the same NTFS partition in both host and guest, and shut down cleanly before rebooting to game on bare metal.
