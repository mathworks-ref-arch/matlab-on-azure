#!/usr/bin/env bash
#
# Copyright 2024 The MathWorks, Inc.

set -x
echo "Starting matlab-proxy-app"

function setup_matlab_proxy_env(){
    # Set the environment variables below to configure your MATLAB Proxy settings. For detailed instructions, see https://github.com/mathworks/matlab-proxy/blob/main/Advanced-Usage.md
    export PATH="${PATH}:/opt/mathworks/matlab-proxy/python-package/bin"
    export PYTHONPATH='/opt/mathworks/matlab-proxy/python-package'
    export MWI_APP_PORT='8123'
    export MWI_ENABLE_SSL='true'
    export MWI_ENABLE_TOKEN_AUTH='true'
    log_location="/home/${USER}/.MathWorks/matlab-proxy"
    mkdir -p "${log_location}" 
    touch "${log_location}/matlab-proxy.log"
    export MWI_LOG_FILE="${log_location}/matlab-proxy.log"
    export MWI_MATLAB_STARTUP_SCRIPT="cd /home/${USER}/"
    # The MWI_AUTH_TOKEN variable declared below is set by line 15 of the 50_setup-matlab-proxy.sh script in the startup folder. The script sets this variable to specify the authentication token for matlab-proxy. 
    # Do not uncomment or modify this variable declaration. 
    # export MWI_AUTH_TOKEN=
}

function main(){
    setup_matlab_proxy_env
    matlab-proxy-app
}

main "$@"
