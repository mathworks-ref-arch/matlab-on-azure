#!/usr/bin/env bash

# Copyright 2024 The MathWorks, Inc.

# This script mounts and optionally unmounts the Azure file share used for MATLAB installation.

# Usage:
# To mount: ./setup-matlab-source.sh mount <FILE_SHARE_NAME> <FILE_SHARE_USERNAME> <FILE_SHARE_PASSWORD> <KEY_VAULT_NAME>
# To unmount: ./setup-matlab-source.sh unmount <FILE_SHARE_NAME>
# Copyright 2024 The MathWorks Inc.

# Exit on any failure
set -eo pipefail

# Input arguments
ACTION=$1
FILE_SHARE_NAME=$2
FILE_SHARE_USERNAME=$3
FILE_SHARE_PASSWORD=$4
KEY_VAULT_NAME=$5

# Check action argument
if [[ "$ACTION" != "mount" ]] && [[ "$ACTION" != "unmount" ]]; then
    echo "Invalid action. Use 'mount' or 'unmount'."
    exit 1
fi

# Mount function
mount_share() {
    # Check for required arguments
    if [[ -z "$FILE_SHARE_NAME" ]] || [[ -z "$FILE_SHARE_USERNAME" ]] || [[ -z "$FILE_SHARE_PASSWORD" ]] || [[ -z "$KEY_VAULT_NAME" ]]; then
        echo "Usage: $0 mount <FILE_SHARE_NAME> <FILE_SHARE_USERNAME> <FILE_SHARE_PASSWORD> <KEY_VAULT_NAME>"
        exit 1
    fi

    # Login to Azure using Managed Identity
    az login --identity 1>/dev/null

    # Retrieve username and password from Azure Key Vault
    username=$(az keyvault secret show --name $FILE_SHARE_USERNAME --vault-name $KEY_VAULT_NAME --query value -o tsv)
    password=$(az keyvault secret show --name $FILE_SHARE_PASSWORD --vault-name $KEY_VAULT_NAME --query value -o tsv)

    # Logout from Azure
    az logout

    # Create smbcredentials directory if it doesn't exist
    if [[ ! -d "/etc/smbcredentials" ]]; then
        sudo mkdir /etc/smbcredentials
    fi

    # Create credentials file if it doesn't exist
    if [[ ! -f "/etc/smbcredentials/$username.cred" ]]; then
        echo "username=$username" | sudo tee -a /etc/smbcredentials/matlabfileshare.cred > /dev/null
        echo "password=$password" | sudo tee -a /etc/smbcredentials/matlabfileshare.cred > /dev/null
    fi

    # Create mount point directory
    sudo mkdir -p /mnt/${FILE_SHARE_NAME}

    # Add entry to /etc/fstab
    echo "//$username.file.core.windows.net/${FILE_SHARE_NAME} /mnt/${FILE_SHARE_NAME} cifs nofail,vers=3.0,credentials=/etc/smbcredentials/matlabfileshare.cred,dir_mode=0555,file_mode=0555,serverino" | sudo tee -a /etc/fstab > /dev/null

    # Mount the Azure file share
    sudo mount -t cifs //$username.file.core.windows.net/${FILE_SHARE_NAME} /mnt/${FILE_SHARE_NAME} -o vers=3.0,credentials=/etc/smbcredentials/matlabfileshare.cred,dir_mode=0555,file_mode=0555,serverino

    # List contents of the mounted directory
    ls -al "/mnt/${FILE_SHARE_NAME}/"
}

# Unmount function
unmount_share() {
    # Check for required arguments
    if [[ -z "$FILE_SHARE_NAME" ]]; then
        echo "Usage: $0 unmount <FILE_SHARE_NAME>"
        exit 1
    fi

    # Unmount the directory
    sudo umount /mnt/${FILE_SHARE_NAME}

    # Remove the mount point directory
    sudo rm -rf /mnt/${FILE_SHARE_NAME}

    # Remove the credentials file
    sudo shred -u /etc/smbcredentials/matlabfileshare.cred

    # Remove the entry from /etc/fstab
    sudo sed -i "/\/mnt\/${FILE_SHARE_NAME}/d" /etc/fstab
}

# Execute the appropriate function based on the action argument
if [[ "$ACTION" == "mount" ]]; then
    mount_share
elif [[ "$ACTION" == "unmount" ]]; then
    unmount_share
fi
