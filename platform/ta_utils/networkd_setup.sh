#!/usr/bin/env bash

if [[ $PWD != *mini_internet_project/platform ]]; then 
  echo "must be run from mini_internet_project/platform"
  exit 1
fi

# Set variables
TEMPLATE_FILE="ta_utils/10-ens18.network"
DEST_FILE="/etc/systemd/network/10-ens18.network"

# Extract the VM number from the hostname
VM_NUMBER=$(hostname | awk -F'-' '{print $NF}')

# Calculate the IP address by adding the VM number to the base IP 10.34.4.160
BASE_IP="10.34.4.160"
OCTET=$(echo $BASE_IP | awk -F'.' '{print $4}')
NEW_OCTET=$((OCTET + VM_NUMBER - 1))
IP_ADDRESS="10.34.4.$NEW_OCTET"

# Ensure the destination directory exists
sudo mkdir -p /etc/systemd/network

# Copy the template file to the destination
sudo cp $TEMPLATE_FILE $DEST_FILE

# Replace the $IP_ADDRESS variable in the copied file
sudo sed -i "s/\$IP_ADDRESS/$IP_ADDRESS/g" $DEST_FILE

# Restart systemd-networkd to apply changes
systemctl restart systemd-networkd