#!/bin/bash
#
# Copyright 2023 The MathWorks Inc.


# Set up log file
swap_desktop_log="/var/log/mathworks_swap_desktop_solution.log"
sudo touch "$swap_desktop_log"
sudo chown root:users "$swap_desktop_log"

# Print commands for logging purposes, including timestamps.
exec 1>>"$swap_desktop_log" 2>&1
set -x
PS4='+ [\d \t] '

REMOTE_DESKTOP_SOLUTION=$1

function cleanup_xrdp_session {
  # Kill desktop session from previous xrdp run
  xrdp_desktop_pid=$(ps aux | grep Xorg | awk '/xrdp\/xorg\.conf/ {print $2}')
  if [[ -n "$xrdp_desktop_pid" ]] ; then
    sudo kill -9 "$xrdp_desktop_pid"
  fi
}

function init_dcv_desktop {
  sudo systemctl set-default graphical.target
  sudo systemctl isolate multi-user.target
  sudo systemctl isolate graphical.target
}

function init_dcv {
  # Check if gpu doesn't exist
  nvidia-smi > /dev/null 2>&1
  gpu_exists=$?
  if [ $gpu_exists -ne 0 ] ; then
    init_dcv_desktop
  else
    sudo nvidia-xconfig --enable-all-gpus --preserve-busid
    init_dcv_desktop
  fi
}

if [[ $REMOTE_DESKTOP_SOLUTION == "rdp" ]] ; then
  # If xrdp is already running, exit
  xrdp_status=$(systemctl is-active xrdp)
  if [[ $xrdp_status == "active" ]]; then
    exit 0
  fi
  
  sudo systemctl stop lightdm

  cleanup_xrdp_session

  # Stop and disable dcvserver
  sudo systemctl stop dcvserver
  sudo systemctl disable dcvserver
    
  # Enable and start xrdp
  sudo systemctl enable xrdp
  sudo systemctl start xrdp

else
  # If dcvserver is already running, exit
  dcv_status=$(systemctl is-active dcvserver)
  if [[ $dcv_status == "active" ]]; then
    exit 0
  fi

  # Stop and disable dcvserver
  cleanup_xrdp_session
  sudo systemctl stop xrdp
  sudo systemctl disable xrdp
  sudo systemctl start lightdm

  dcv_status=$(systemctl is-active dcvserver)
  if [[ $dcv_status == "inactive" ]]; then
    init_dcv
    sudo systemctl enable dcvserver
    sudo systemctl start dcvserver
  fi
fi
