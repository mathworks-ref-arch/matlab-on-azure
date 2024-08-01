#!/usr/bin/env bash
#
# Copyright 2023-2024 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

# Configure MATLAB_ROOT directory
sudo mkdir -p "${MATLAB_ROOT}"
sudo chmod -R 755 "${MATLAB_ROOT}"

# Install and setup mpm.
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md
sudo apt-get -qq install \
  unzip \
  wget \
  ca-certificates
sudo wget --no-verbose https://www.mathworks.com/mpm/glnxa64/mpm
sudo chmod +x mpm

# The mpm --doc flag is supported in R2022b and older releases only.
# To install doc for offline use, follow the steps in
# https://www.mathworks.com/help/releases/R2023a/install/ug/install-documentation-on-offline-machines.html
doc_flag=""
if [[ $RELEASE < 'R2023a' ]]; then
  doc_flag="--doc"
fi

# If a source URL is provided, then use it to install MATLAB and toolboxes.
release_arguments=""
source_arguments=""
if [[ -n "${MATLAB_SOURCE_LOCATION}" ]]; then
  # Setup source for MATLAB installation
  sudo chmod +x /var/tmp/config/matlab/setup-matlab-source.sh
  /var/tmp/config/matlab/setup-matlab-source.sh mount "${MATLAB_SOURCE_LOCATION}" "MATLABFILESHAREUSERNAME" "MATLABFILESHAREPASSWORD" "${AZURE_KEY_VAULT}"

  # Setup appropriate source flag to use with mpm
  source_arguments="--source=/mnt/${MATLAB_SOURCE_LOCATION}/dvd/archives"
else
  release_arguments="--release=${RELEASE}"
fi

# Run mpm to install MATLAB and toolboxes in the PRODUCTS variable
# into the target location. The mpm installation is deleted afterwards.
# The PRODUCTS variable should be a space separated list of products, with no surrounding quotes.
# Use quotes around the destination argument if it contains spaces.
sudo ./mpm install \
  ${doc_flag} \
  ${release_arguments} \
  ${source_arguments} \
  --destination="${MATLAB_ROOT}" \
  --products ${PRODUCTS} \
  || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
  && sudo rm -f mpm /tmp/mathworks_root.log

# If a source location for installation was provided, delete related files and folders after install.
if [[ -n "${MATLAB_SOURCE_LOCATION}" ]]; then
    /var/tmp/config/matlab/setup-matlab-source.sh unmount "${MATLAB_SOURCE_LOCATION}"
fi

# Enable MHLM licensing default
sudo mkdir -p "${MATLAB_ROOT}/licenses"
sudo chmod 777 "${MATLAB_ROOT}/licenses"
cp /var/tmp/config/matlab/license_info.xml "${MATLAB_ROOT}/licenses/"

# Add symlink to MATLAB
sudo ln -s "${MATLAB_ROOT}/bin/matlab" /usr/local/bin

# Set keyboard settings to windows flavor for any new user.
sudo mkdir -p "/etc/skel/.matlab/${RELEASE}"
sudo cp /var/tmp/config/matlab/matlab.prf  "/etc/skel/.matlab/${RELEASE}/"

# Enable DDUX collection by default for the VM
cd "${MATLAB_ROOT}/bin/glnxa64"
sudo ./ddux_settings -s -c

# Config MHLM Client setting
sudo cp /var/tmp/config/matlab/mhlmvars.sh /etc/profile.d/

# Config DDUX context tag setting
sudo cp /var/tmp/config/matlab/mw_context_tag.sh /etc/profile.d/

# Copy license file to root of the image
sudo cp /var/tmp/config/matlab/thirdpartylicenses.txt /
