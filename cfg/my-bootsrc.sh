#!/bin/sh

for x in $(/bin/cat /proc/cmdline); do
  case $x in
  myboot=*)
    BOOT_DEV=${x#myboot=}
    ;;
  esac
done
if [ ${BOOT_DEV} = "0" ]
then
   /bin/echo 'microSD' > /var/myboot/bootsrc-typ.txt
   /bin/echo 'mmcblk0' > /var/myboot/bootsrc-dev.txt
#   /bin/echo '/dev/mmcblk0p1 /mnt/p1 vfat rw,relatime,fmask=0022,codepage=936,iocharset=utf8,shortname=mixed,utf8,errors=remount-ro 0 0' >> /etc/fstab
else
   /bin/echo 'eMMC' > /var/myboot/bootsrc-typ.txt
   /bin/echo 'mmcblk1' > /var/myboot/bootsrc-dev.txt
   /bin/mkdir -p /mnt/sd
#   /bin/echo '/dev/mmcblk1p1 /mnt/p1 vfat rw,relatime,fmask=0022,codepage=936,iocharset=utf8,shortname=mixed,utf8,errors=remount-ro 0 0' >> /etc/fstab
fi

ip link set can0 type can bitrate 500000 && ip link set can0 up

