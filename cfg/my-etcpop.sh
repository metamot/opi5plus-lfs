#!/bin/sh
cat /boot/etc.cpio | cpio -idumH newc -D /var/myboot/etc

