#!/usr/bin/env bash
set -oue pipefail

# Schedule Lix ostree install on first boot
cat > /etc/systemd/system/nix-install.service << 'EOF'
[Unit]
Description=Install Nix (Lix) on first boot
ConditionPathExists=!/nix/var/nix/db
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install ostree --no-confirm'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/nix-install.service \
    /etc/systemd/system/multi-user.target.wants/nix-install.service
