#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

PS4='[\d \t] '
set -x

# Install NICE DCV
apt-get -qq install /usr/local/bin/nice-dcv-*/nice-dcv-server_*.deb /usr/local/bin/nice-dcv-*/nice-dcv-web-viewer*.deb
usermod -aG video dcv

# Use DCV authentication
sed -i 's/#authentication="none"/authentication="system"/' /etc/dcv/dcv.conf

# Configure automatic console sessions on service startup
sed -i "s/^#owner.*/owner=${USERNAME}/" /etc/dcv/dcv.conf
sed -i 's/^#create-session.*$/create-session=true/' /etc/dcv/dcv.conf

# Configure max 1 session
sed -i 's/^#max-concurrent-clients.*/max-concurrent-clients=1/' /etc/dcv/dcv.conf

# Enable file sharing
sed -i 's/^#storage-root.*/storage-root="%home%"/' /etc/dcv/dcv.conf

# Setup licensing
if [[ ${NICE_DCV_LICENSE_SERVER} =~ "@" ]]; then
    echo "License NICE DCV using license: ${NICE_DCV_LICENSE_SERVER}"
    sed -i "s/^#license-file.*/license-file=${NICE_DCV_LICENSE_SERVER}/" /etc/dcv/dcv.conf
else
    echo 'License NICE DCV using demo license'
fi

# Disable dcvserver for now. Will be enabled based on the user choice
systemctl disable dcvserver
