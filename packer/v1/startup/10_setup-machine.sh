#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

PS4='[\d \t] '
set -x

# Make the current user the owner of MATLAB_ROOT to allow support packages installation without sudo permissions
GROUP=$(id -gn ${USERNAME}) && chown -R ${USERNAME}:${GROUP} ${MATLAB_ROOT} &

# Ensure that the MATLAB icon is in the desktop
mkdir -p /home/${USERNAME}/Desktop
cp -f /etc/skel/Desktop/matlab.desktop /home/${USERNAME}/Desktop/

# Refresh the icon cache to ensure the MATLAB icon displays correctly
sudo update-icon-caches /usr/share/icons/*

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

# Fix home folder permissions
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}