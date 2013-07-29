#!/bin/sh

# create the starting point of the file system image
# this gives you a bare bones linux root directory with the basics
sudo debootstrap precise linuxrootdir

# force the hostname of the image to be PBB
sudo chroot linuxrootdir hostname PBB

# Add "restricted universe multiverse" to the end of the first line
sudo cp src/sources.list linuxrootdir/etc/apt
sudo chown root.root linuxrootdir/etc/apt/sources.list

# Add PBB, SUSC and SUSD to /etc/hosts
sudo cp src/hosts linuxrootdir/etc
sudo chown root.root linuxrootdir/etc/hosts

# Add user matrix1, use password 'matrix1'
sudo chroot linuxrootdir adduser matrix1
sudo chroot linuxrootdir adduser matrix1 adm
sudo chroot linuxrootdir adduser matrix1 sudo

# Remove the logrotate and cron packages:
sudo chroot linuxrootdir dpkg -r cron logrotate

# Update the package repository
sudo chroot linuxrootdir apt-get -y update

# Install ntp and ssh
sudo chroot linuxrootdir apt-get -y install ntp ssh

# put mapper specific rsyslog.conf and ntp.conf in /etc
sudo cp src/rsyslog.conf linuxrootdir/etc
sudo chown root.root linuxrootdir/etc/rsyslog.conf
sudo cp src/ntp.conf linuxrootdir/etc
sudo chown root.root linuxrootdir/etc/ntp.conf

# put configuration script that sets the network speed on the data network in /etc
sudo cp src/rc.local linuxrootdir/etc
sudo chown root.root linuxrootdir/etc/rc.local

# put network configuration in /etc/network
sudo cp src/interfaces linuxrootdir/etc/network
sudo chown root.root linuxrootdir/etc/network/interfaces

# put ftdi rules in udev folder
sudo cp src/85-ftdi.rules linuxrootdir/etc/udev/rules.d
sudo chown root.root linuxrootdir/etc/udev/rules.d

# put /etc/fstab in the image.
# This mounts /tmp as a tmpfs file system to prevent a potential 
# memory leak in aufs
sudo cp src/fstab linuxrootdir/etc/fstab
sudo chown root.root linuxrootdir/etc/fstab

# put the rc.local file to reinitilize data connection
sudo cp src/rc.local linuxrootdir/etc/rc.local
sudo chown root.root linuxrootdir/etc/rc.local

# to prevent errors from ssh clients about man-in-the-middle attacks
sudo cp /etc/ssh/ssh_host_* linuxrootdir/etc/ssh

# to prevent sudo from asking a password for user matrix1
sudo cp src/sudoers linuxrootdir/etc
sudo chown root.root linuxrootdir/etc/sudoers
sudo chmod 0440 linuxrootdir/etc/sudoers

# Remove persistency files
sudo rm linuxrootdir/etc/udev/rules.d/70-persistent-net.rules
sudo rm linuxrootdir/lib/udev/rules.d/75-persistent-net-generator.rules

# Install dependencies
sudo chroot linuxrootdir apt-get -y install python-scipy lm-sensors python-h5py python-daemon python-setproctitle python-cjson manpages usbutils nano busybox-static live-boot libftdi-dev python-ftdi ethtool

# Update live-boot script
sudo cp src/live-boot linuxrootdir/etc/init.d/live-boot

# Install PBB HAL
cd PBBHAL && make all && cd .. 
cp -r PBBHAL linuxrootdir/opt/
sudo chroot linuxrootdir chmod 775 /opt/PBBHAL

# Copy required kernel modules
#sudo mkdir -p linuxrootdir/lib/modules/3.2.0-29-generic/kernel/drivers/hwmon
#sudo cp /lib/modules/3.2.0-29-generic/kernel/drivers/hwmon/coretemp.ko linuxrootdir/lib/modules/3.2.0-29-generic/kernel/drivers/hwmon
#sudo cp /lib/modules/3.2.0-29-generic/kernel/drivers/hwmon/w83795.ko linuxrootdir/lib/modules/3.2.\
#0-29-generic/kernel/drivers/hwmon
#sudo mkdir -p linuxrootdir/lib/modules/3.2.0-29-generic/kernel/drivers/i2c/busses
#sudo cp /lib/modules/3.2.0-29-generic/kernel/drivers/i2c/busses/i2c-i801.ko linuxrootdir/lib/modules/3.2.0-29-generic/kernel/drivers/i2c/busses
#sudo cp src/modules linuxrootdir/etc/modules
#sudo chroot linuxrootdir depmod -a

