#!/bin/bash
echo "# make" > load.mk
for fn in `cat list.txt`; do
  printf 'PKG+=%s\n' "${fn}" >> load.mk
done
printf 'all: $(PKG)\n' >> load.mk
for fn in `cat list.txt`; do
  printf '%s:\n' "${fn}" >> load.mk
  printf '\tcat pkg/%s.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1\n' "${fn}" >> load.mk
done
