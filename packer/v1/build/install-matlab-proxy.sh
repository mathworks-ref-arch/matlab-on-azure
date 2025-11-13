#!/usr/bin/env bash
#
# Copyright 2024-2025 The MathWorks, Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

RUNTIME_SOURCE=/tmp
CONFIG_SOURCE=/var/tmp/config/matlab-proxy
DESTINATION=/opt/mathworks/matlab-proxy

function install_matlab_proxy_dependencies(){
    # Install xvfb for matlab-proxy
    sudo apt-get -qq install xvfb
}

function install_matlab_proxy(){
    # Install matlab-proxy in a global location that persists after the build completes
    sudo mkdir -p $DESTINATION
    if [ -z "${MATLAB_PROXY_VERSION}" ]; then
        sudo python3 -m pip install matlab-proxy --target $DESTINATION/python-package --break-system-packages
    else
        sudo python3 -m pip install matlab-proxy==${MATLAB_PROXY_VERSION} --target $DESTINATION/python-package --break-system-packages
    fi
    echo "Installed matlab-proxy"
}

function install_matlab_proxy_launch_script(){
    # Move the launcher script to the right directory   
    sudo mv $RUNTIME_SOURCE/launch-matlab-proxy.sh $DESTINATION/launch-matlab-proxy.sh
    sudo chmod +x $DESTINATION/launch-matlab-proxy.sh
}

function install_matlab_proxy_service(){
    # Create a systemd service to start matlab-proxy
    sudo mv $CONFIG_SOURCE/matlab-proxy.service /etc/systemd/system/matlab-proxy.service
    sudo chown root:root /etc/systemd/system/matlab-proxy.service
    echo "created matlab-proxy.service"

    # Update dependencies tree for systemd
    sudo systemctl daemon-reload
}

function main(){
    install_matlab_proxy_dependencies
    install_matlab_proxy
    install_matlab_proxy_launch_script
    install_matlab_proxy_service
}

main "$@"
