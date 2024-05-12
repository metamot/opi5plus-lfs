#!/bin/sh
/bin/sync && /bin/umount -a -r > /dev/null 2>&1 || /bin/systemctl poweroff -ff

