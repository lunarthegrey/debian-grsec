#!/bin/bash

# Add jessie-backports to sources.list and apt-get update
echo "deb http://ftp.debian.org/debian/ jessie-backports main contrib" > /etc/apt/sources.list
apt-get update

# Check if you're on 32bit or 64bit and install the correct kernel
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  apt-get -t jessie-backports install -y linux-image-grsec-amd64
else
  apt-get -t jessie-backports install -y linux-image-grsec-i386
fi

while true; do
    read -p "To apply the new grsec kernel you must reboot. Would you like to reboot now?" yn
    case $yn in
        [Yy]* ) reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
