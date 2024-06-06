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
   /bin/mount /dev/mmcblk0p1 /boot
else
   /bin/echo 'eMMC' > /var/myboot/bootsrc-typ.txt
   /bin/echo 'mmcblk1' > /var/myboot/bootsrc-dev.txt
   /bin/mount /dev/mmcblk1p1 /boot
   /bin/mkdir -p /mnt/sd
fi
/bin/cat /boot/etc.cpio | /bin/cpio -idumH newc --quiet -D /etc

