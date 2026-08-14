#!/usr/bin/env bash
#
# Copyright 2026 The MathWorks, Inc.
#
# Disable the automatic apt update/upgrade services for the duration of the
# packer image build so they do not hold the apt/dpkg lock while the build
# scripts install packages. They are re-enabled at deployment time by the
# startup script 99_enable-auto-upgrades.sh.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Stop the running services and timers, then disable them so they do not
# restart for the rest of the build.
sudo systemctl stop unattended-upgrades.service apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service || true
sudo systemctl disable unattended-upgrades.service apt-daily.timer apt-daily-upgrade.timer || true

# Wait up to 10 minutes for any remaining apt/dpkg lock holders to release,
deadline=$((SECONDS + 600))
while sudo fuser /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock >/dev/null 2>&1; do
  if [[ "$SECONDS" -ge "$deadline" ]]; then
    echo 'timed out after 10 minutes waiting for apt/dpkg lock to clear' >&2
    exit 1
  fi
  echo 'waiting for apt/dpkg lock to clear...'
  sleep 2
done

# Turn off the periodic apt timers via configuration
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
