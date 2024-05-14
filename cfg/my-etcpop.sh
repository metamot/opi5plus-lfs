#!/bin/sh
/bin/cat /mnt/p1/etc.cpio | /bin/cpio -idumH newc -D /etc
