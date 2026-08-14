#!/usr/bin/env bash
#
# Copyright 2026 The MathWorks, Inc.
#
# Re-enable the automatic apt update/upgrade services that were disabled
# during the packer image build. Must run last so earlier startup scripts
# do not face race conditions with the auto-upgrade services for the apt/dpkg lock.

PS4='[\d \t] '
set -x

CONFIG_FILE=/etc/apt/apt.conf.d/20auto-upgrades

# Refresh the periodic apt configuration only when it is missing or not
# already requesting daily updates/upgrades, to avoid rewriting on every boot.
if ! grep -qs '^APT::Periodic::Unattended-Upgrade "1";' "$CONFIG_FILE"; then
    tee "$CONFIG_FILE" > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
fi

systemctl enable --now apt-daily.timer apt-daily-upgrade.timer
systemctl enable --now unattended-upgrades.service
