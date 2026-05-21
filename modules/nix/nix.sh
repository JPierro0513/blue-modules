#!/usr/bin/env bash
set -oue pipefail

# Install Lix into /usr/share/nix-store during image build
mkdir -p /usr/share/nix-store
mkdir -p /nix

curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix \
  | sh -s -- install linux --no-start-daemon --no-confirm

# Move store to image-baked location
mv /nix/* /usr/share/nix-store/

# Copy and enable our mount/seed units
MODULE_DIR="$(dirname "$0")"
cp "$MODULE_DIR/units/nix.mount" /etc/systemd/system/nix.mount
cp "$MODULE_DIR/units/nix-seed.service" /etc/systemd/system/nix-seed.service
echo "=== checking nix.mount made it ==="
ls -la /etc/systemd/system/nix.mount 2>/dev/null || { echo 'Not present'; exit 1; }

# Symlink nix-daemon units from store into systemd
NIX_UNIT_DIR=$(echo /usr/share/nix-store/store/*-lix-*/lib/systemd/system)
ln -sf "$NIX_UNIT_DIR/nix-daemon.service" /etc/systemd/system/nix-daemon.service
ln -sf "$NIX_UNIT_DIR/nix-daemon.socket"  /etc/systemd/system/nix-daemon.socket

mkdir -p /etc/systemd/system/nix-daemon.socket.d
cat > /etc/systemd/system/nix-daemon.socket.d/selinux.conf << 'EOF'
[Socket]
SELinuxContextFromNet=yes
EOF

systemctl enable nix-daemon.socket nix.mount nix-seed.service
