#!/usr/bin/env bash
#
# Copyright 2023-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Ensure noninteractive frontend is disabled
echo 'debconf debconf/frontend select dialog' | sudo debconf-set-selections

# Clear build configuration files
sudo rm -rf /var/tmp/config/

# The reboot provisioner leaves this behind on purpose, see build-azure-matlab.pkr.hcl
sudo rm -f /tmp/packer-reboot.sh

# Clear packer home directory
sudo rm -rf /home/packer

# Clear SSH host keys
sudo rm -f /etc/ssh/ssh_host_*_key*

# Clear SSH local config (including authorized keys)
sudo rm -rf ~/.ssh/ /root/.ssh/

#########  Azure marketplace certification malware fix  #########

# Malware detected on your VHD and the list of filenames includes (Malware detected on your VHD and the list of filenames 
# includes (Image digestId: , File name: pismo.h, Malware Information: avira(malware) sophos(phishing) bitdefender(phishing) 
# ConfirmedMaliciousURL hXXp[:]//www[.]pismoworld[.]org/ (FileType:.h)  (Executable:true)

sudo find /usr/src -type f -name "pismo.h" -exec sed -i '/pismoworld.org/d' {} +

sudo apt-get remove --purge --yes yt-dlp || true
# Remove package flagged by Azure, this gets installed with mate-desktop
sudo apt-get remove --yes youtube-dl || true

# Remove the rest of the packages Azure flags. Ubuntu publishes their fixes only
# to the Pro esm-apps pocket, so apt cannot patch them on this image.
CERT_SOURCES='^(imagemagick|ffmpeg|cjson|mbedtls|qtbase-opensource-src|mosquitto)$'
CERT_PACKAGES=$({ dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package} ${source:Package}\n' \
    2>/dev/null || true; } | awk -v re="${CERT_SOURCES}" '$1=="ii" && $3 ~ re {print $2}' \
    | sort -u | tr '\n' ' ')

echo "Flagged packages installed in this image: ${CERT_PACKAGES:-none}"

if [ -n "${CERT_PACKAGES}" ]; then
    # Record what apt takes out alongside them before removing anything.
    sudo apt-get --simulate remove --purge ${CERT_PACKAGES} 2>&1 \
        | grep -E 'The following|to remove' || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get remove --purge --yes ${CERT_PACKAGES} || true
fi

# No autoremove here. The packages Azure flags are gone once the purge above
# finishes, and autoremove went on to take 87 more that nothing flagged. One of
# them was libvdpau1, which nice-dcv-server needs: the build only unpacks the
# DCV debs, so apt cannot see that dependency and counted the library as an
# orphan. The startup scripts then failed to install DCV on every deployment.

echo "Flagged packages still installed after cleanup:"
{ dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package} ${Version} ${source:Package}\n' \
    2>/dev/null || true; } | awk -v re="${CERT_SOURCES}" '$1=="ii" && $4 ~ re {print "  " $2 " " $3}'
