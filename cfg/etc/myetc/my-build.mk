include /etc/myetc/versions.mk
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
all: $(PKG)
kernel-headers:
	$(V)cat /boot/zst/kernel-headers.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gcc:
	$(V)cat /boot/zst/gcc-$(GCC_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
isl:
	$(V)cat /boot/zst/isl-$(ISL_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
gmp:
	$(V)cat /boot/zst/gmp-$(GMP_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
mpc:
	$(V)cat /boot/zst/mpc-$(MPC_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
mpfr:
	$(V)cat /boot/zst/mpfr-$(MPFR_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
glibc:
	$(V)cat /boot/zst/glibc-$(GLIBC_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
binutils:
	$(V)cat /boot/zst/binutils-$(BINUTILS_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
wget:
	$(V)cat /boot/zst/wget-$(WGET_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
coreutils:
	$(V)cat /boot/zst/coreutils-$(COREUTILS_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
util-linux:
	$(V)cat /boot/zst/util-linux-$(UTIL-LINUX_VER).cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1

