# V=@
PKG+= kernel-headers
PKG+= gcc
PKG+= isl
PKG+= gmp
PKG+= mpc
PKG+= mpfr
PKG+= glibc
PKG+= binutils
PKG+= wget
PKG+= coreutils
PKG+= util-linux
PKG+= tar
PKG+= xz
PKG+= sed
PKG+= gawk
PKG+= diffutils
PKG+= openssh
all: $(PKG)
kernel-headers:
	$(V)cat /boot/zst/kernel-headers.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gcc:
	$(V)cat /boot/zst/gcc.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
isl:
	$(V)cat /boot/zst/isl.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gmp:
	$(V)cat /boot/zst/gmp.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
mpc:
	$(V)cat /boot/zst/mpc.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
mpfr:
	$(V)cat /boot/zst/mpfr.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
glibc:
	$(V)cat /boot/zst/glibc.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
binutils:
	$(V)cat /boot/zst/binutils.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
wget:
	$(V)cat /boot/zst/wget.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
coreutils:
	$(V)cat /boot/zst/coreutils.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
util-linux:
	$(V)cat /boot/zst/util-linux.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
tar:
	$(V)cat /boot/zst/tar.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
xz:
	$(V)cat /boot/zst/xz.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
sed:
	$(V)cat /boot/zst/sed.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gawk:
	$(V)cat /boot/zst/gawk.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
diffutils:
	$(V)cat /boot/zst/diffutils.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
openssh:
	$(V)cat /boot/zst/openssh.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1

