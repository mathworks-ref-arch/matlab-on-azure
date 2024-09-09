#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Install and setup mpm.
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md
cd /tmp
sudo apt-get -qq install \
  unzip \
  wget \
  ca-certificates
sudo wget --no-verbose https://www.mathworks.com/mpm/glnxa64/mpm
sudo chmod +x mpm

# If a source URL is provided, then use it to install MATLAB and toolboxes.
release_arguments=""
source_arguments=""
if [[ -n "${SPKG_SOURCE_LOCATION}" ]]; then
  # Setup source for MATLAB installation
  sudo chmod +x /var/tmp/config/matlab/setup-matlab-source.sh
  /var/tmp/config/matlab/setup-matlab-source.sh mount "${SPKG_SOURCE_LOCATION}" "MATLABFILESHAREUSERNAME" "MATLABFILESHAREPASSWORD" "${AZURE_KEY_VAULT}"

  # Setup appropriate source flag to use with mpm
  source_arguments="--source /mnt/${SPKG_SOURCE_LOCATION}/support_packages"
else
  release_arguments="--release ${RELEASE}"
fi

# Run mpm to install MATLAB and toolboxes in the PRODUCTS variable
# into the target location. The mpm installation is deleted afterwards.
# The PRODUCTS variable should be a space separated list of products, with no surrounding quotes.
# Use quotes around the destination argument if it contains spaces.
sudo ./mpm install \
  ${release_arguments} \
  ${source_arguments} \
  --destination ${MATLAB_ROOT} \
  --products ${SPKGS} \
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && exit 1) \
  && sudo rm -f mpm /tmp/mathworks_root.log

# If a source location for installation was provided, delete related files and folders after install.
if [[ -n "${SPKG_SOURCE_LOCATION}" ]]; then
    /var/tmp/config/matlab/setup-matlab-source.sh unmount "${SPKG_SOURCE_LOCATION}"
fi
