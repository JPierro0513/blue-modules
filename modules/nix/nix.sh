#!/usr/bin/env bash
set -oue pipefail

mkdir -p /nix
mkdir -p /var/lib/nix

MODULE_DIR="$(dirname "$0")"
cp "$MODULE_DIR/units/nix.mount" /etc/systemd/system/nix.mount
cp "$MODULE_DIR/units/nix-install.service" /etc/systemd/system/nix-install.service

mkdir -p /etc/systemd/system/local-fs.target.wants
ln -sf /etc/systemd/system/nix.mount \
    /etc/systemd/system/local-fs.target.wants/nix.mount

mkdir -p /etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/nix-install.service \
    /etc/systemd/system/multi-user.target.wants/nix-install.service
