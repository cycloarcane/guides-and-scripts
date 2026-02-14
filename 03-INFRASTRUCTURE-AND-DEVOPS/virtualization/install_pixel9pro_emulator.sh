#!/usr/bin/env bash

set -e

echo "=== Pixel 9 Pro Emulator Installer (Arch / CachyOS compatible) ==="

# -----------------------------
# 1. Install base dependencies
# -----------------------------
echo "[1/7] Installing base dependencies..."

sudo pacman -Sy --needed --noconfirm \
    android-tools \
    qemu-desktop \
    virt-manager \
    dnsmasq \
    vde2 \
    wget \
    unzip \
    glibc \
    libpulse \
    libx11 \
    libxcomposite \
    libxcursor \
    libxdamage \
    libxext \
    libxfixes \
    libxi \
    libxrandr \
    libxrender \
    libxtst \
    mesa \
    alsa-lib

# -----------------------------
# 2. Enable KVM
# -----------------------------
echo "[2/7] Enabling KVM..."

CPU_VENDOR=$(lscpu | grep Vendor | awk '{print $3}')

if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    sudo modprobe kvm_intel || true
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    sudo modprobe kvm_amd || true
fi

sudo modprobe kvm || true

sudo usermod -aG kvm $USER || true

# -----------------------------
# 3. Install Android SDK CLI tools
# -----------------------------
echo "[3/7] Installing Android SDK CLI tools..."

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

mkdir -p "$ANDROID_HOME/cmdline-tools"
cd "$ANDROID_HOME/cmdline-tools"

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip
    unzip tools.zip
    mv cmdline-tools latest
    rm tools.zip
fi

# -----------------------------
# 4. Configure PATH
# -----------------------------
echo "[4/7] Configuring environment..."

PROFILE="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && PROFILE="$HOME/.zshrc"

if ! grep -q ANDROID_HOME "$PROFILE"; then
cat >> "$PROFILE" <<EOF

export ANDROID_HOME=\$HOME/Android/Sdk
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export PATH=\$PATH:\$ANDROID_HOME/emulator
export PATH=\$PATH:\$ANDROID_HOME/platform-tools
export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin
EOF
fi

export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# -----------------------------
# 5. Accept licenses
# -----------------------------
echo "[5/7] Accepting licenses..."

yes | sdkmanager --licenses > /dev/null

# -----------------------------
# 6. Install emulator + Pixel 9 Pro image
# -----------------------------
echo "[6/7] Installing emulator and Pixel 9 Pro image..."

sdkmanager \
    "platform-tools" \
    "emulator" \
    "platforms;android-35" \
    "system-images;android-35;google_apis;x86_64"

# -----------------------------
# 7. Create AVD
# -----------------------------
echo "[7/7] Creating AVD..."

mkdir -p "$HOME/.android/avd"

if ! avdmanager list avd | grep -q Pixel_9_Pro; then
    echo "no" | avdmanager create avd \
        -n Pixel_9_Pro \
        -k "system-images;android-35;google_apis;x86_64" \
        -d "pixel_9_pro"
fi

echo ""
echo "SUCCESS: Pixel 9 Pro emulator installed"
echo ""

echo "Launching emulator..."

$ANDROID_HOME/emulator/emulator -avd Pixel_9_Pro -gpu host -accel on &
