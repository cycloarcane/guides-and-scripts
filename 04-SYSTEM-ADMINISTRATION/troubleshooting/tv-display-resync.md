# Fix a TV Used as a Monitor That Drops Out After Sleep

Some TVs used as desktop monitors fail to come back after the machine sleeps. The
desktop still thinks the output is connected and enabled — the panel simply shows
nothing. Changing the resolution in System Settings and changing it back brings the
picture back, because that forces a fresh modeset over HDMI.

This guide automates that workaround on **KDE Plasma (Wayland)**, using
`kscreen-doctor`. Tested on CachyOS with a Philips FTV on HDMI, alongside two
DisplayPort monitors that were unaffected.

---

## Step 1: Identify the Output

List the outputs and their modes:

```bash
kscreen-doctor -o
```

Connector names (`HDMI-A-1`, `DP-1`, …) don't say which physical screen they are.
Match them to monitor names with the EDID data the kernel exposes:

```bash
for f in /sys/class/drm/*/edid; do
    echo "$f: $(strings "$f" | tr '\n' ' ')"
done
```

```
/sys/class/drm/card1-DP-1/edid: ... KB272 ...
/sys/class/drm/card1-DP-2/edid: ... PHL 271S7Q ...
/sys/class/drm/card1-HDMI-A-1/edid: ... Philips FTV ...
```

Note the connector name and the current mode (marked `*` in `kscreen-doctor -o`),
e.g. `HDMI-A-1` at `3840x2160@60`.

---

## Step 2: The Script

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/tv-kick.sh <<'SCRIPT'
#!/bin/bash
# Re-sync the Philips FTV (HDMI-A-1). Usage: tv-kick.sh [method] [delay]
#   same    - re-apply the current mode (no-op on KWin; see notes)
#   bounce  - drop to 1080p and back (works; reads as a single flash)
#   offon   - disable and re-enable the output (shuffles windows)
OUT=HDMI-A-1
NATIVE=3840x2160@60
TEMP=1920x1080@60
METHOD=${1:-bounce}
DELAY=${2:-0}

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/tv-kick.lock"
flock -n 9 || exit 0
sleep "$DELAY"

case $METHOD in
    same)   kscreen-doctor output.$OUT.mode.$NATIVE ;;
    bounce) kscreen-doctor output.$OUT.mode.$TEMP && kscreen-doctor output.$OUT.mode.$NATIVE ;;
    offon)  kscreen-doctor output.$OUT.disable && sleep 1 && kscreen-doctor output.$OUT.enable ;;
    *)      echo "unknown method: $METHOD" >&2; exit 1 ;;
esac
SCRIPT
chmod +x ~/.local/bin/tv-kick.sh
```

Change `OUT`, `NATIVE` and `TEMP` to match Step 1.

The `flock` guard means duplicate triggers are dropped rather than queued, so the
output can't be bounced several times in a row.

### Which method to use

| Method | Result |
| --- | --- |
| `same` | **Does not work.** KWin ignores a mode set that matches the current configuration, so nothing reaches the hardware. This is the same reason the GUI greys out the active resolution. |
| `bounce` | **Works.** Two modesets, but they run back-to-back and read as one brief blackout. |
| `offon` | Works, but re-enabling the output shuffles windows onto the other screens and back. Last resort. |

A single same-resolution refresh is not possible: the mode has to actually change
for the driver to re-sync, and it has to change back afterwards.

---

## Step 3: A Taskbar Button

A launcher is the simplest trigger, since the other screens keep working and you
can still click things:

```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/tv-kick.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Fix TV Display
GenericName=Re-sync Philips TV
Comment=Bounce the HDMI-A-1 output's mode to make the TV display again
Exec=/home/USER/.local/bin/tv-kick.sh bounce
Icon=video-display
Terminal=false
Categories=Utility;
Keywords=tv;display;hdmi;resolution;monitor;
DESKTOP
update-desktop-database ~/.local/share/applications
```

`Exec` needs an absolute path — replace `USER` with your username.

Then find **Fix TV Display** in the application launcher, right-click it and choose
*Pin to Task Manager*.

A keyboard shortcut is worth adding too, under System Settings → Keyboard →
Shortcuts → Add New → Application. It works even when the blank screen is the one
holding the taskbar.

---

## Step 4 (Optional): Run It Automatically After Unlocking

To fire the reset when the lock screen closes after a resume, watch KDE's screen
locker on D-Bus:

```bash
cat > ~/.local/bin/tv-kick-watch.sh <<'SCRIPT'
#!/bin/bash
# Run tv-kick.sh once per unlock (KDE emits ActiveChanged on several paths).
last=0
dbus-monitor --session "type='signal',interface='org.freedesktop.ScreenSaver',member='ActiveChanged'" |
while read -r line; do
    if [[ $line == *"boolean false"* ]]; then
        now=$(date +%s)
        if (( now - last > 15 )); then
            last=$now
            echo "unlock detected, re-syncing TV"
            "$HOME/.local/bin/tv-kick.sh" bounce 2 &
        fi
    fi
done
SCRIPT
chmod +x ~/.local/bin/tv-kick-watch.sh

cat > ~/.config/systemd/user/tv-kick.service <<'UNIT'
[Unit]
Description=Re-sync Philips TV after unlocking
PartOf=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=%h/.local/bin/tv-kick-watch.sh
Restart=on-failure

[Install]
WantedBy=graphical-session.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now tv-kick.service
```

**The 15-second debounce matters.** KDE emits `ActiveChanged` on more than one
D-Bus path, so without it the output is bounced repeatedly on every unlock — which
looks like the screen flashing five or six times.

The 2-second delay gives the compositor time to settle after the unlock before the
modeset.

Watch it work with:

```bash
journalctl --user -u tv-kick -f
```

Disable it again with `systemctl --user disable --now tv-kick.service`.

---

## Notes

- **Check HDR first.** HDR and deep colour make the HDMI handshake more fragile
  after sleep. If disabling HDR for that output, or turning off the TV's HDMI-CEC
  and auto-power-off features, stops the dropouts, no workaround is needed.
- **The connector name is hardcoded.** Moving the TV to another HDMI port means
  updating `OUT=` in the script.
- **X11 instead of Wayland:** use `xrandr --output HDMI-1 --mode 1920x1080` followed
  by `--mode 3840x2160` in place of the `kscreen-doctor` calls.
- **Other desktops:** GNOME Wayland has no equivalent CLI; `wlr-randr` covers
  wlroots compositors (Sway, Hyprland).

---

[← Back to troubleshooting](../README.md)
