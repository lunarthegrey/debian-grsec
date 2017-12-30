#!/bin/bash
GRUB="/etc/default/grub"
VERSION="4.9.0-4"

# Make sure only root can run the script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root, su to become root" 1>&2
  exit 1
fi

while [ ! $# -eq 0 ]
do
case "$1" in
--install | -i)
    
  # Force stable package prefences, for some reason only works with apt-get
  cat << EOF > /etc/apt/preferences.d/force-stable
  Package: *
  Pin: release a=stable
  Pin-Priority: 1001
  EOF

  # Add sid to sources.list and apt-get update
  echo "deb http://http.debian.net/debian/ sid main contrib" | tee -a /etc/apt/sources.list
  apt-get update

  # Check if you're on 32bit or 64bit, install the correct kernel from sid and add it to grub
  MACHINE_TYPE=`uname -m`
  if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    apt-get -t sid install -y linux-image-grsec-amd64
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-amd64"/g' $GRUB
    update-grub
  else
    apt-get -t sid install -y linux-image-grsec-i386
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-i386"/g' $GRUB
    update-grub
  fi

  while true; do
  echo
  read -p "To apply the new grsec kernel you must reboot. Would you like to reboot now? [Y/n] " yn
  case $yn in
    [Yy]* ) sync; reboot; break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
  done
      
exit
;;
        
--update | -u)
  apt-get update
	# Check if you're on 32bit or 64bit, install the correct kernel from sid and add it to grub
  MACHINE_TYPE=`uname -m`
  if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    apt-get -t sid install -y linux-image-grsec-amd64 linux-image-{$VERSION}-grsec-amd64
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-amd64"/g' $GRUB
    update-grub
  else
    apt-get -t sid install -y linux-image-grsec-i386 linux-image-{$VERSION}-grsec-i386
    sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Debian GNU\/Linux>Debian GNU\/Linux, with Linux {$VERSION}-grsec-i386"/g' $GRUB
    update-grub
  fi
      
exit
;;
esac
shift
done
