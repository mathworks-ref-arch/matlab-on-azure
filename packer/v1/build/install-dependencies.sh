#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Initialise apt
echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections
sudo apt-get -qq update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Ensure essential utilities are installed
sudo apt-get -qq install gcc jq make unzip wget

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install pip
curl https://bootstrap.pypa.io/get-pip.py | sudo python3

# Install NVIDIA CUDA Toolkit
if [[ -n "${NVIDIA_CUDA_TOOLKIT}" ]]; then
  wget --no-verbose "${NVIDIA_CUDA_TOOLKIT}"
  chmod +x cuda*.run
  sudo bash cuda*.run --silent --override --toolkit --samples --toolkitpath=/usr/local/cuda-toolkit --samplespath=/usr/local/cuda --no-opengl-libs
  sudo ln -s /usr/local/cuda-toolkit /usr/local/cuda
  echo "export PATH=\"$PATH:/usr/local/cuda-toolkit/bin\"" >> set_cuda_on_path.sh
  sudo cp set_cuda_on_path.sh /etc/profile.d/
  rm cuda*.run
fi

# Install Firefox to ensure a web browser is available
sudo apt-get -qq install firefox
