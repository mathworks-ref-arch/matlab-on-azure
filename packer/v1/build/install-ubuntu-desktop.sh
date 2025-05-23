#!/usr/bin/env bash
#
# Copyright 2023-2025 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail
echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections

echo "Update Ubuntu repositories and upgrade to latest packages..."
sudo apt-get -qq clean
sudo mv /var/lib/apt/lists /var/lib/apt/lists.broke
sudo mkdir -p /var/lib/apt/lists/partial

# Clear locks: https://unix.stackexchange.com/questions/315502/how-to-disable-apt-daily-service-on-ubuntu-cloud-vm-image
sudo systemctl stop apt-daily.service
sudo systemctl kill --kill-who=all apt-daily.service

# Wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | grep -qE '(dead|failed)'); do
  sleep 1;
done

# Wait until locks clear
sleep 10

# Make sure package list and packages are up to date
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  upgrade

###################################################### CONFIGURE XRDP ######################################################
# Enable xfce
sudo rm -f /usr/bin/x-session-manager
sudo ln -s /usr/bin/xfce4-session /usr/bin/x-session-manager

# Install whois
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install whois

# Install/Configure xrdp
# https://github.com/neutrinolabs/xrdp/wiki/Building-on-Debian-8
sudo mv /var/lib/dpkg/info/install-info.postinst /var/lib/dpkg/info/install-info.postinst.bad

UBUNTU_VERSION=$(lsb_release -rs | tr -d '.')

sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  install \
  autoconf \
  automake \
  bison \
  flex \
  g++ \
  gcc \
  git \
  intltool \
  libfuse-dev \
  libjpeg-dev \
  libmp3lame-dev \
  libpam0g-dev \
  libpixman-1-dev \
  libssl-dev \
  libtool \
  libx11-dev \
  libxfixes-dev \
  libxml2-dev \
  libxrandr-dev \
  make \
  nasm \
  pkg-config \
  xserver-xorg-dev \
  xsltproc \
  xutils \
  xutils-dev \
  "$([[ $UBUNTU_VERSION -lt 2204 ]] && echo "python-libxml2" || echo "python3-libxml2")"

sudo apt-get -qq install --reinstall xserver-xorg-video-intel xserver-xorg-core

BASE_DIR=$(pwd)
mkdir -p "${BASE_DIR}"/git/neutrinolabs
cd "${BASE_DIR}"/git/neutrinolabs
wget --no-verbose https://github.com/neutrinolabs/xrdp/releases/download/v0.9.9/xrdp-0.9.9.tar.gz
wget --no-verbose https://github.com/neutrinolabs/xorgxrdp/releases/download/v0.2.12/xorgxrdp-0.2.12.tar.gz

cd "${BASE_DIR}"/git/neutrinolabs
tar xvfz xrdp-0.9.9.tar.gz
cd "${BASE_DIR}"/git/neutrinolabs/xrdp-0.9.9
./bootstrap
./configure --enable-fuse --enable-mp3lame --enable-pixman
sudo make install
sudo ln -sf /usr/local/sbin/xrdp /usr/sbin
sudo ln -sf /usr/local/sbin/xrdp-sesman /usr/sbin

cd "${BASE_DIR}"/git/neutrinolabs
tar xvfz xorgxrdp-0.2.12.tar.gz
cd "${BASE_DIR}"/git/neutrinolabs/xorgxrdp-0.2.12
./bootstrap
./configure
make
sudo make install

cd "${BASE_DIR}"
sudo rm -rf git

sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  autoremove

# Configure the XServer so it can be started by users connecting with remote desktop.
# Ensure there is an Xwrapper.config file.
FILE=/etc/X11/Xwrapper.config
if test -f "$FILE"; then
  sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
  echo "Xwrapper.config updated"
else
  sudo echo "allowed_users=anybody" | sudo tee -a /etc/X11/Xwrapper.config > /dev/null
  echo "Xwrapper.config created"
fi

# Set default permissions
sudo chmod -R a+w /var/tmp/config

# Fix xrdp icons
sudo mkdir -p /usr/share/matlab
sudo cp /var/tmp/config/matlab/icons/matlabicon24b.bmp /usr/share/matlab

# Fix xrdp login screen options
sudo cp /var/tmp/config/xrdp/xrdp.ini /etc/xrdp/xrdp.ini
# Fix xrdp bit depth and folder sharing options
sudo cp /var/tmp/config/xrdp/sesman.ini /etc/xrdp/sesman.ini

sudo sed -Ei 's/After=network.target.+$/After=multi-user.target syslog.target network.target xrdp-sesman.service/' /lib/systemd/system/xrdp.service
sudo sed -Ei '/ExecStart/i ExecStartPre=/bin/mkdir -p /var/run/xrdp' /lib/systemd/system/xrdp.service
sudo systemctl daemon-reload

###################################################### CONFIGURE DCV ######################################################
# Prerequisites for installing NICE DCV server
export DEBCONF_NONINTERACTIVE_SEEN=true
sudo apt-get -qq update
sudo apt-get -qq upgrade
sudo apt-get -qq -o=Dpkg::Use-Pty=0 install ubuntu-mate-desktop
sudo apt-get -qq install \
    xserver-xorg-video-dummy \
    xfonts-cyrillic \
    xfonts-cronyx-* \
    libglvnd-dev \
    xserver-xorg-dev \
    dkms \
    build-essential \
    libxcb-damage0 \
    libxcb-xtest0 \
    linux-headers-generic \
    "$( [[ $UBUNTU_VERSION -lt 2204 ]] && echo "xserver-xorg-input-void" )"

# Install libssl1.1 for ubuntu 2204 for dcv server
if [[ $UBUNTU_VERSION -ge 2204 ]]; then
    sudo wget --no-verbose http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
    sudo apt -qq install ./libssl1.1_1.1.0g-2ubuntu4_amd64.deb
    sudo rm -f ./libssl1.1_1.1.0g-2ubuntu4_amd64.deb
fi

# Install kernel header files
sudo apt-get -qq install "linux-headers-$(uname -r)"

# Installing NVDIA driver
if [[ -n "${NVIDIA_DRIVER_VERSION}" ]]; then
  sudo apt-get -qq install --no-install-recommends "nvidia-driver-${NVIDIA_DRIVER_VERSION}-server"
fi

sudo cp /var/tmp/config/nvidia/xorg.conf /etc/X11/xorg.conf

# Remove gnome option from the lightdm menu
if [[ -e "/usr/share/xsessions/ubuntu.desktop" ]]; then
    sudo mv /usr/share/xsessions/ubuntu.desktop /usr/share/xsessions/ubuntu.desktop.disabled
fi

sudo systemctl set-default multi-user.target

# Configure auto-login
sudo touch /etc/lightdm/lightdm.conf
# The username will be overwritten at startup
sudo bash -c "cat > /etc/lightdm/lightdm.conf" <<EOT
[SeatDefaults]
greeter-session=lightdm-slick-greeter
autologin-user=ubuntu
EOT

if [[ -e "/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf" ]]; then
    sudo rm /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
fi

# Disable ubuntu upgrade notification pop-ups
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Download the NICE DCV server
echo "Downloading nice dcv zip"
sudo wget --no-verbose "${DCV_INSTALLER_URL}"
sudo tar xvf nice-dcv-*.tgz -C /usr/local/bin/

sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport

# Disable rdp for now, will be started if chosen by user
sudo systemctl disable xrdp

sudo reboot
