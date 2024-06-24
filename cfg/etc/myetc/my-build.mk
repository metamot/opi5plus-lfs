# V=@
PKG+= wget
PKG+= kernel-headers
PKG+= binutils
PKG+= gcc
PKG+= isl
PKG+= gmp
PKG+= mpc
PKG+= mpfr
PKG+= glibc
PKG+= coreutils
PKG+= acl
#PKG+= util-linux
PKG+= tar
PKG+= xz
PKG+= sed
PKG+= gawk
PKG+= diffutils
PKG+= flex
PKG+= gzip
PKG+= patch
#PKG+= openssh
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
acl:
	$(V)cat /boot/zst/acl.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
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
flex:
	$(V)cat /boot/zst/flex.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gzip:
	$(V)cat /boot/zst/gzip.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
patch:
	$(V)cat /boot/zst/patch.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
openssh:
	$(V)cat /boot/zst/openssh.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1

