#!/bin/bash
mkdir -p tmp
ls -1 /boot/zst/*.cpio.zst > tmp/inidep.txt
for fn in `cat tmp/inidep.txt`; do
  echo "RootFs Install From ::: ${fn}"
  cat ${fn} | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
done
rm -f tmp/inidep.txt
