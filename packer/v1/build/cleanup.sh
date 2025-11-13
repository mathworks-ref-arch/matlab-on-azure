#!/usr/bin/env bash
#
# Copyright 2023-2025 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Ensure noninteractive frontend is disabled
echo 'debconf debconf/frontend select dialog' | sudo debconf-set-selections

# Clear build configuration files
sudo rm -rf /var/tmp/config/

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

sudo apt-get remove --purge --yes yt-dlp
sudo apt-get autoremove --yes
