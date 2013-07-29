#!/bin/sh

# use standard initrd image of current kernel as a starting point
mkdir initramfs
cd initramfs
cp /boot/initrd.img-`uname -r` .
zcat initrd.img-`uname -r`|cpio -i -H newc 
rm initrd.img-`uname -r`

#copy busybox for tftp support
cp /bin/busybox ./bin



