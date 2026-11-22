#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"

echo "=== 1. Installing build tools & headers for $(uname -r) ==="
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

echo "=== 2. Installing nvidia-legacy-390xx (390.157) patched DKMS source ==="
sudo rm -rf "/usr/src/nvidia-legacy-390xx-390.157"
sudo cp -a "$SCRIPT_DIR/nvidia-legacy-390xx-390.157" "/usr/src/nvidia-legacy-390xx-390.157"
sudo chown -R root:root "/usr/src/nvidia-legacy-390xx-390.157"

sudo dkms remove -m "nvidia-legacy-390xx" -v "390.157" --all || true
sudo dkms add -m "nvidia-legacy-390xx" -v "390.157"
sudo dkms build -m "nvidia-legacy-390xx" -v "390.157" -k $(uname -r)
sudo dkms install -m "nvidia-legacy-390xx" -v "390.157" -k $(uname -r)

echo "=== 3. Restoring Xorg configurations ==="
if ls "$SCRIPT_DIR/xorg.conf.d/"* >/dev/null 2>&1; then
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo cp -f "$SCRIPT_DIR/xorg.conf.d/"* /etc/X11/xorg.conf.d/
fi
[ -f "$SCRIPT_DIR/xorg.conf" ] && sudo cp -f "$SCRIPT_DIR/xorg.conf" /etc/X11/xorg.conf || true

echo "=== Done! Check grub-cmdline.txt if boot parameters (like simpledrm blacklist) are needed, then reboot. ==="
