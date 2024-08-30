#!/usr/bin/env bash

if [[ $PWD != *mini_internet_project/platform ]]; then 
  echo "must be run from mini_internet_project/platform"
  exit 1
fi

#install packages
sudo apt update
sudo apt install openvswitch-switch systemd-zram-generator ufw openvpn qemu-guest-agent -y
sudo systemctl start qemu-guest-agent.service
curl -fsSL https://get.docker.com | sudo sh

#add user to docker group
sudo usermod -aG docker $USER 

#setup zram
sudo cp ./ta_utils/zram-generator.conf /etc/systemd/zram-generator.conf
sudo systemctl start systemd-zram-setup@zram0.service
sudo swapon -p 100 -d /dev/zram0

#setup mini-net
ip_addr=$(ip -o -4 addr show ens18 | awk '{print $4}' | cut -d/ -f1)
sed -i "s/HOSTNAME=.*/HOSTNAME=\"$ip_addr\"/" setup/website_setup.sh
sed -i "s|CONFIG_DIR=.*|CONFIG_DIR=$(pwd)/config|" utils/iptables/filters.sh

sudo ./startup.sh .
sudo ./utils/iptables/filters.sh .