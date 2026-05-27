# OnePlus Nord (Avicii) Variants & NetHunter Support  
The original OnePlus Nord (codename **avicii**) is officially supported by Kali NetHunter. Offensive Security publishes a full NetHunter image for the Nord (Android 16/OxygenOS 16)【63†L180-L183】. This “full” build includes a Kali chroot, tools, and NetHunter app. Before proceeding, confirm your Nord is the standard *avicii* model (the Nord CE/2/others have different codes). Kali’s device kernel list shows OnePlus Nord (avicii) has pre-built NetHunter images available【63†L180-L183】.  All steps below assume an updated stock Nord; if you are on a custom ROM, ensure it’s compatible (LineageOS or current OxygenOS is safest).

## Downloads: Recoveries & Tools  
- **TWRP (TeamWin Recovery Project):** The official TWRP site provides images for the Nord (avicii). For example, TWRP v3.7.1_12 for avicii is available (ZIP installer and IMG)【12†L25-L28】. Download the latest `twrp-*.img` and/or installer ZIP from [dl.twrp.me](https://dl.twrp.me/avicii/) (Americas/Europe mirrors)【11†L30-L38】【12†L25-L28】.  
- **PitchBlack Recovery (PBRP):** An official PBRP build (v4.0) exists for Nord (avicii). For example, `PBRP-avicii-4.0-20240623-0702-OFFICIAL.zip` is available on SourceForge【25†L445-L453】. The PitchBlack website/documentation provides install instructions (flash ZIP via existing recovery)【25†L445-L453】.  
- **OrangeFox Recovery:** Unofficial OrangeFox builds for Nord (avicii) exist (see SourceForge or XDA). For instance, OrangeFox for OxygenOS 12 (OOS12) is listed on SourceForge【37†L81-L89】. These usually come as flashable ZIPs.  
- **SkyHawk Recovery (SHRP):** The SkyHawk (SHRP) TWRP fork has a build for Nord. On SourceForge under “Recovery Builds – Sky Hawk – FBEv2”, you can find `SHRP_v3.1_Stable-Unofficial_avicii-*.img` and corresponding ZIP【35†L81-L87】【36†L81-L87】. The main SkyHawk page also has a flashable ZIP【32†L66-L68】 (67.5 MB).  
- **Tools:** On your Arch Linux host, install Android platform-tools (ADB/fastboot). On Arch:  
  ```bash
  sudo pacman -S android-tools
  ```  
  This provides `adb` and `fastboot`. You may also install `android-udev` and apply Android udev rules so the Nord is recognized when plugged in. (See the official Android documentation【11†L50-L54】 for platform-tools downloads or Arch’s packages.)

## Prepare the Device  
1. **Enable Developer Options & USB Debugging:** On the Nord, go to **Settings → About → Build number** and tap 7 times. Then in **Settings → System → Developer options**, enable **USB debugging** and **OEM unlocking**. (This step is standard for all Android devices.)  
2. **Stock Firmware:** It’s wise to download the latest official OnePlus Nord factory/firmware image (OxygenOS) from OnePlus’s site or community forums before proceeding. TWRP notes that if you ever flash the wrong image, you can restore the stock boot.img from the factory package【11†L46-L54】.  

## Unlocking the Bootloader  
1. **Boot to Fastboot:** Connect the Nord via USB. In a terminal on your Arch host:  
   ```
   adb reboot bootloader
   ```  
   Alternatively, power off the phone, then hold Volume Up + Volume Down to enter fastboot mode.  
2. **Unlock:** Once in the bootloader, execute (confirm on the phone):  
   ```
   fastboot oem unlock
   ```  
   On OnePlus devices, this will trigger a confirmation on-screen; accept to unlock. This wipes all data on the device. After unlock completes, reboot into Android to finish setup, then re-enable USB debugging.  
3. **Verify:** Reboot to bootloader again (`adb reboot bootloader`) and check `fastboot devices`. You should see the device listed, indicating bootloader is unlocked.

## Installing Custom Recovery  
With the bootloader unlocked, flash a custom recovery:  

- **Flash TWRP:** Using the TWRP image downloaded earlier, you can either temporarily boot it or flash it permanently. For example:  
  ```bash
  fastboot boot twrp-3.7.1_12-0-avicii.img
  ```  
  This will boot the phone into TWRP without overwriting the stock recovery【11†L69-L77】. Once in TWRP, go to **Advanced → Install Recovery Ramdisk** (or “Flash Current TWRP” on some builds) to permanently install TWRP【11†L69-L77】. Then use **Advanced → Fix Recovery Bootloop** in TWRP to prevent the stock ROM from overwriting it【11†L78-L84】.  
- **Alternative Recoveries:** If you prefer PBRP or another recovery, copy its ZIP to the device (via MTP or ADB push), boot any recovery (even stock if needed), then in recovery install the zip (PitchBlack or SkyHawk/SHRP are provided as zip installers). For PBRP, simply flash the downloaded `PBRP-avicii-4.0…zip` from TWRP【25†L445-L453】. OrangeFox and SHRP similarly have flashable zips.

After installing a custom recovery, reboot into recovery mode (e.g. from TWRP’s **Reboot → Recovery**). In TWRP/PBRP you can now mount or format partitions as needed.

## Disabling Encryption (DM-Verity/ForceEncrypt)  
Newer Android versions enforce encryption by default. TWRP may not access `/data` if forced encryption is enabled. Kali NetHunter recommends flashing the **Universal DM-Verity & ForceEncrypt Disabler** before installing NetHunter on Android 9/10/11【56†L159-L164】. In practice, boot TWRP and flash a “disable-verity-opt-encrypt” zip (many sources on XDA or the NetHunter forum provide this). Then in TWRP, use **Wipe → Format Data** to ensure `/data` is decrypted (you may have to type “yes” to confirm). This ensures Magisk and NetHunter can work on `/data`.  

> **Note:** Kali docs warn that on Android 9–11 you *must* flash the DM-Verity/Encrypt disabler and reformat data before NetHunter, or you’ll encounter errors (e.g. “Required key not available”) when running the Kali rootfs【56†L159-L164】.

## Rooting (Magisk)  
Root the device by installing Magisk: download the latest Magisk ZIP (from [GitHub/official sources](https://github.com/topjohnwu/Magisk/releases)). In TWRP, flash the Magisk ZIP. This will inject root support. After flashing, reboot into Android and verify that Magisk Manager is installed. (See Magisk docs for any Arch/Linux steps or use `adb sideload Magisk-v*.zip` from recovery.) NetHunter requires root for its full functionality (HID attacks, USB Arsenal, etc)【69†L238-L241】.

## Flashing Kali NetHunter  
1. **Download NetHunter Image:** From Kali’s downloads, get the OnePlus Nord NetHunter ZIP. For Android 16, the file is named like `kali-nethunter-2025.4-oneplus-nord-sixteen-full.zip` (2.4 GB)【63†L178-L182】. Verify its SHA256 sum matches the value on the Kali site【69†L216-L219】.  
2. **Transfer to Device:** Copy the NetHunter zip onto the phone’s storage (via MTP, `adb push`, or an OTG drive).  
3. **Flash in Recovery:** Boot the Nord into TWRP/PBRP. In recovery, choose **Install**, then select the NetHunter ZIP and swipe to flash. This installs the Kali chroot and apps. TWRP will show “Install Done” when finished【69†L245-L249】. If you instead prefer the Magisk module method (newer method), use the NetHunter App to install the same zip as a Magisk module (keep the screen awake during install)【46†L180-L188】.  
4. **Reboot:** Once flashing completes, reboot into Android. On first boot, open the **NetHunter App** (or Magisk Manager if using module) to finalize setup.  

## Post-Install Configuration  
After installing and rebooting:  
- **NetHunter App:** Open the Kali NetHunter app and go to **Kali Chroot Manager**. Allow it to initialize the Kali rootfs.  
- **Install Keyboard:** From the NetHunter App Store (within the NetHunter app), install the “Hacker’s Keyboard” (this is recommended for terminal use)【69†L252-L259】.  
- **Services & Tools:** Start desired services (SSH, Bluetooth-Arsenal, etc) from the app. The **Services** tab lets you enable SSH/shell on boot. Initialize the exploit database if prompted.  
- **USB Arsenal/HID:** Test USB gadgets by connecting the Nord to a host via USB and configuring via the NetHunter UI.  
- **Kernel Modules:** If you plan to use wireless injection, ensure compatible USB Wi‑Fi drivers are present. Community builds may include drivers (e.g. R8188eu for RTL8188-based adapters) in the kernel【7†L34-L40】. If your Nord kernel lacks needed drivers, you may need to compile or flash a custom NetHunter kernel (the NetHunter app’s Kernel manager can download kernels if available).

## Troubleshooting  
- **Boot Loop/Recovery Loop:** If the device gets stuck in a bootloop or recovery after flashing NetHunter, restore the stock boot.img: re-flash the original OxygenOS boot and reboot, then retry NetHunter steps. Always keep the official firmware handy【11†L46-L54】.  
- **TWRP Won’t Decrypt Data:** Ensure you flashed the Encrypt-Disabler and formatted data. Without that, TWRP can’t write to `/data`.  
- **ADB/Fastboot Not Recognized:** On Arch, ensure `adb`/`fastboot` are installed and that udev rules allow access. Running `lsusb` should show the Nord in fastboot mode. Try `sudo fastboot devices`.  
- **Magisk Issues:** If Magisk fails to install or boot (especially on Android 13/14+), double-check you have the latest Magisk and that TWRP is not blocking installations. You may also try the “MagiskHide” modules if any conflicts occur.  
- **External Wi-Fi Injection:** If your Wi-Fi dongle isn’t detected, verify the kernel modules. You may need to compile the appropriate drivers (e.g. rtl8188eu) or switch to a kernel that includes them【7†L34-L40】.  

## Summary Checklist  
1. **Developer options:** Enable USB Debugging & OEM Unlock.  
2. **ADB/fastboot:** Install `android-tools` on Arch; verify `adb devices`.  
3. **Unlock Bootloader:** `fastboot oem unlock` (accept on phone).  
4. **Flash Recovery:** `fastboot boot twrp.img` then flash TWRP, fix bootloop【11†L69-L77】.  
5. **Disable Encryption:** Flash DM-Verity/Encrypt disabler, format data【56†L159-L164】.  
6. **Root:** Flash Magisk ZIP in TWRP【69†L238-L241】.  
7. **Download NetHunter:** Get the official ZIP (2025.4 build)【63†L180-L183】. Verify SHA256【69†L216-L219】.  
8. **Install NetHunter:** In TWRP, flash the Kali NetHunter ZIP【69†L245-L249】.  
9. **Reboot & Configure:** Launch NetHunter App, initialize chroot, install Hacker keyboard, and enable Kali services【69†L252-L259】.  

Each step should be performed carefully. If errors occur, consult the Kali NetHunter documentation or device forums. The above sources provide detailed instructions (TWRP usage【11†L69-L77】, NetHunter installation steps【69†L235-L243】【56†L159-L164】) and downloads (recoveries【12†L25-L28】【25†L445-L453】, NetHunter image【63†L180-L183】) to guide the process.  

**Sources:** Official NetHunter docs【69†L235-L243】【69†L252-L259】【56†L159-L164】; TeamWin (TWRP) site【11†L30-L38】【11†L69-L77】; SourceForge recovery builds【12†L25-L28】【25†L445-L453】; Kali image repository【63†L178-L182】; and related community/kernel notes【7†L34-L40】.