#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

PS4='[\d \t] '
set -x

if [[ "${ACCESS_PROTOCOL}" == "RDP" ]]; then
    systemctl enable xrdp
    systemctl start xrdp
fi