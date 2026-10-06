#!/usr/bin/env bash
#
# Copyright 2023-2026 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Run apt non-interactively (no prompts) for the whole script.
export DEBIAN_FRONTEND=noninteractive

# Configure apt retry and timeout behavior.
sudo tee /etc/apt/apt.conf.d/80-refarch-retries >/dev/null <<'APTCONF'
Acquire::Retries "2";
Acquire::http::Timeout "20";
Acquire::https::Timeout "20";
APT::Update::Error-Mode "any";
APTCONF

# Prefer the Azure mirror, fall back to archive.ubuntu.com automatically.
# https://manpages.ubuntu.com/manpages/noble/man1/apt-transport-mirror.1.html
sudo install -d -m 0755 /etc/apt/mirrors
printf '%s\tpriority:%s\n' \
  'http://azure.archive.ubuntu.com/ubuntu/' 1 \
  'http://archive.ubuntu.com/ubuntu/'       2 |
  sudo tee /etc/apt/mirrors/refarch-ubuntu.list >/dev/null

# Point Ubuntu sources at the mirror list (handles both source layouts).
ubuntu_source_files=(
  /etc/apt/sources.list
  /etc/apt/sources.list.d/*.sources
  /etc/apt/sources.list.d/*.list
)
for source_file in "${ubuntu_source_files[@]}"; do
  [[ -f "${source_file}" ]] || continue
  sudo sed -i -E \
    "s|https?://([[:alnum:].-]+\.)?archive\.ubuntu\.com/ubuntu/?|mirror+file:/etc/apt/mirrors/refarch-ubuntu.list|g" \
    "${source_file}"
done

# Initialise apt
echo 'debconf debconf/frontend select noninteractive' | sudo debconf-set-selections
sudo apt-get -qq update
sudo apt-get -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Ensure essential utilities are installed
sudo apt-get -qq install gcc jq make unzip wget

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install pip
sudo apt-get install -y python3-pip

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
