# Windows NVMe Data Recovery from Arch Linux

This guide explains how to recover files and restore an accidentally formatted Windows NVMe drive using **Arch Linux** tools. It also includes troubleshooting tips for common problems you may encounter along the way.

---

## 🧭 Overview

If you performed a *soft format* (quick format) of your Windows NVMe drive — meaning you recreated the filesystem but didn’t overwrite the data — your files are likely still recoverable. The steps below will help you restore access safely.

---

## ⚙️ Step-by-Step Recovery Process

### 1. Identify the Drive

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL
```

Find the Windows NVMe partition (e.g. `/dev/nvme0n1p2` or `/dev/sda2`). Do **not** mount it yet.

---

### 2. Create a Safe Backup Image (Optional but Recommended)

```bash
sudo pacman -S gnu-ddrescue
sudo ddrescue -f -n /dev/nvme0n1p2 ~/nvme_backup.img ~/nvme_backup.log
```

You can then work on `/dev/loop0` instead of the real device:

```bash
sudo losetup -fP ~/nvme_backup.img
```

---

### 3. Use TestDisk to Recover the Original Partition

```bash
sudo pacman -S testdisk
sudo testdisk /dev/sda
```

Steps inside TestDisk:

1. Choose **[Proceed]** → Select **EFI GPT**
2. Choose **[Analyse]** → **[Quick Search]**
3. Identify the old NTFS partition
4. Press **p** to list files — if visible, your data is intact
5. Mark the partition as **P (Primary)** and **[Write]** the partition table if correct

---

### 4. Repair NTFS Boot Sector if Needed

From **Advanced → Boot** inside TestDisk:

* If both boot sectors are OK but not identical, choose **[Backup BS]** to restore the original.
* If corrupted, use **[Rebuild BS]**.

---

### 5. Fix Filesystem Issues in Arch Linux

Install NTFS tools:

```bash
sudo pacman -S ntfs-3g
```

Then run:

```bash
sudo ntfsfix /dev/sda2
```

This will repair the MFT and mark the filesystem as clean.

---

### 6. Mount the Partition

Try the modern kernel driver first:

```bash
sudo mount -t ntfs3 /dev/sda2 /mnt/recovered
```

If that fails with a dirty flag error, try:

```bash
sudo mount -t ntfs3 -o ro,force /dev/sda2 /mnt/recovered
```

If `$Bitmap` or similar errors appear, mount using the legacy driver:

```bash
sudo mount -t ntfs-3g /dev/sda2 /mnt/recovered
```

---

### 7. Copy Your Data

Once mounted, copy your files elsewhere:

```bash
rsync -avh --progress /mnt/recovered/ /mnt/backup/
```

---

### 8. (Optional) Run Windows chkdsk for Final Repair

After copying your data, attach the NVMe to a Windows machine and run:

```cmd
chkdsk X: /f
```

This fully repairs the NTFS bitmap and transaction log.

---

## 🧩 Troubleshooting

| Problem                                       | Cause                            | Fix                                                           |
| --------------------------------------------- | -------------------------------- | ------------------------------------------------------------- |
| `Unable to open file or device --fileopt`     | Wrong PhotoRec usage             | Run `sudo photorec --fileopt` **without** specifying a device |
| No partitions found in TestDisk               | GPT or MBR table overwritten     | Use **[Deeper Search]** in TestDisk                           |
| Boot sector mismatch                          | Backup and main sectors differ   | Use **[Backup BS]** to restore the original                   |
| `volume is dirty and "force" flag is not set` | NTFS not cleanly unmounted       | Run `sudo ntfsfix /dev/sda2` or mount with `-o ro,force`      |
| `$Bitmap is corrupted`                        | NTFS allocation map damaged      | Run `chkdsk /f` in Windows to rebuild it                      |
| `wrong fs type` error                         | Kernel `ntfs3` driver too strict | Mount with `ntfs-3g` instead                                  |
| No files visible                              | Boot sector OK but MFT corrupt   | Use **PhotoRec** or **DMDE** to carve/recover files           |

---

## 🧠 Key Takeaways

* Never write to the drive until data is backed up.
* Use `testdisk` for structural recovery, `photorec` for raw file carving.
* `ntfs3` is faster but stricter — fallback to `ntfs-3g` when in doubt.
* Only Windows `chkdsk` can fully repair NTFS `$Bitmap` corruption.

---

## 🧰 Useful Commands Cheat Sheet

```bash
lsblk                              # list drives
sudo testdisk /dev/sda             # partition recovery
sudo photorec /dev/sda2            # raw file carving
sudo ntfsfix /dev/sda2             # fix NTFS structure
sudo mount -t ntfs-3g /dev/sda2 /mnt/recovered  # safe mount
rsync -avh --progress /mnt/recovered/ /mnt/backup/  # backup files
```

---

### ✅ Final Notes

If you reached a point where `ntfs-3g` can mount the volume and your data is visible, **immediately back it up**. Once your files are safe, repair or reformat the NVMe before reusing it to ensure filesystem integrity.
