#!/bin/sh
cd /var/myboot/etc && /bin/find . -print0 | /bin/cpio -o0H newc > /boot/etc.cpio || cd -

