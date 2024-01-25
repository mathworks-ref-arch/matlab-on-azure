#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

PS4='[\d \t] '
set -x

# Fix home folder permissions
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Ensure that the MATLAB icon is in the desktop
mkdir -p /home/${USERNAME}/Desktop
cp -f /etc/skel/Desktop/matlab.desktop /home/${USERNAME}/Desktop/

# Refresh icon cache
sudo update-icon-caches /usr/share/icons/*
sudo dconf update 

# Specify user for auto-login
# Make sure that we do not set an empty string
if [[ -n "${USERNAME}" ]]; then
    sed -i "s/autologin-user=.*/autologin-user=${USERNAME}/" /etc/lightdm/lightdm.conf
fi

# Use lightdm as display manager
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm

# Enable all gpus
if [[ -d /proc/driver/nvidia/gpus ]]; then
    nvidia-xconfig --enable-all-gpus --preserve-busid
fi

# Enable unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
