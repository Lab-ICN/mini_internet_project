#!/bin/bash

# Ensure run as root
if [[ $(id -u) -ne 0 ]]; then
	echo "You must run as root, exiting..."
fi

# Create swapfile
echo "Creating new /swapfile"
swapoff /swapfile
rm /swapfile
touch /swapfile
chmod 600 /swapfile
echo "Fallocating size 5G into /swapfile"
fallocate -l 5G /swapfile
echo "Adding entry into /etc/fstab"
echo "/swapfile	none	swap	defaults	0	0" >> /etc/fstab

echo "SYSTEMD Daemon Reloading"
systemctl daemon-reload

echo "MKSWAPPING /swapfile"
mkswap /swapfile

echo "Turning on swapfile with PRIO -2"
swapon -p -2 /swapfile

echo "Zram Swap..."
apt update && apt install zram-config -y

sleep 2

echo "Changing totalmem into 15G on init-zram-swapping script"
sed '7 s/totalmem \/ 2/15728580/1' /usr/bin/init-zram-swapping > res.txt
cat res.txt | tee /usr/bin/init-zram-swapping

sleep 2

echo "Changing PRIO into 100 on init-zram-swapping script"
sed 's/-p [0-9]+/-p 100/1' /usr/bin/init-zram-swapping > res.txt
cat res.txt | tee /usr/bin/init-zram-swapping
rm res.txt

echo "Activating Zram Now"
swapoff $(swapon --show=NAME --noheadings | grep zram)
rmmod zram
/usr/bin/init-zram-swapping

echo "Verifying Swap has been activated (Ensure that /swapfile and /dev/zramX is showed!!"
swapon
