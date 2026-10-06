#!/usr/bin/env bash
#
# Copyright 2024-2026 The MathWorks, Inc.

# Print commands for logging purposes.
set -x

MATLAB_PROXY_FILES="/opt/mathworks/matlab-proxy"

function setup_matlab_proxy_auth_token(){
    if [[ -n ${PASSWORD} ]]; then
        launch_script="${MATLAB_PROXY_FILES}/launch-matlab-proxy.sh"

        # Set the password for matlab-proxy to use token-authentication
        decoded_password="\$(echo '${PASSWORD}' | base64 -d)"
        sed -i "s/# export MWI_AUTH_TOKEN=/export MWI_AUTH_TOKEN=${decoded_password}/g" "${launch_script}"
     else
        echo "Please set the PASSWORD environment variable for this script to correctly setup matlab-proxy."
        exit 1
    fi
}

function setup_matlab_proxy_user(){
    # Configure service to run with the correct user
    if [[ -n ${USERNAME} ]]; then
        launch_script="${MATLAB_PROXY_FILES}/launch-matlab-proxy.sh"
        sed -i "s/USER=ubuntu/USER=${USERNAME}/g" "${launch_script}"

        service_unit=/etc/systemd/system/matlab-proxy.service

        sed -i "s/User=ubuntu/User=${USERNAME}/g" "${service_unit}"
        # Refresh systemd daemon since we have modified a service-unit
        systemctl daemon-reload
    else
        echo "Please set the USERNAME environment variable for this script to correctly setup matlab-proxy."
        exit 1
    fi
}

function setup_matlab_proxy_log(){
    # Create the matlab-proxy log file alongside the other MathWorks logs and hand
    # it to the service user. This script runs as root at startup, so the service
    # (which runs unprivileged) does not need to create the file itself.
    matlab_proxy_log="/var/log/mathworks/matlab-proxy.log"
    mkdir -p "$(dirname "${matlab_proxy_log}")"
    touch "${matlab_proxy_log}"
    chown "${USERNAME}" "${matlab_proxy_log}"
}

function setup_matlab_proxy_service(){
    # Starting the service that runs matlab-proxy
    systemctl enable matlab-proxy.service
    systemctl start matlab-proxy.service
}

function main(){
    if [[ "${ENABLE_MATLAB_PROXY}" == "Yes" ]]; then
        setup_matlab_proxy_auth_token
        setup_matlab_proxy_user
        setup_matlab_proxy_log
        setup_matlab_proxy_service
    fi
}

main "$@"
