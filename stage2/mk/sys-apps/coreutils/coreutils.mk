SRC+=src/coreutils-$(CORE_UTILS_VER).tar.xz
SRC+=src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch
PKG+=pkg/coreutils.cpio.zst
coreutils: pkg/coreutils.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libcap.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
COREUTILS_OPT+= --prefix=/usr
COREUTILS_OPT+= --enable-no-install-program=kill,uptime
COREUTILS_OPT+= --disable-nls
COREUTILS_OPT+= $(OPT_FLAGS)
#pkg/coreutils.cpio.zst: src/coreutils-$(CORE_UTILS_VER).tar.xz src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch pkg/acl.cpio.zst pkg/gmp.cpio.zst pkg/perl.cpio.zst pkg/ncurses.cpio.zst pkg/m4.cpio.zst pkg/libcap.cpio.zst pkg/gettext.cpio.zst pkg/automake.cpio.zst
pkg/coreutils.cpio.zst: src/coreutils-$(CORE_UTILS_VER).tar.xz pkg/acl.cpio.zst pkg/gmp.cpio.zst pkg/perl.cpio.zst pkg/ncurses.cpio.zst pkg/m4.cpio.zst pkg/libcap.cpio.zst pkg/gettext.cpio.zst pkg/automake.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/autoconf.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/automake.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gettext.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libcap.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/coreutils
	mkdir -p tmp/coreutils/bld
	tar -xJf $< -C tmp/coreutils
##	cp -f src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch tmp/coreutils/
##	cd tmp/coreutils/coreutils-$(CORE_UTILS_VER) && patch -Np1 -i ../coreutils-$(CORE_UTILS_VER)-i18n-1.patch
### gcc   -mcpu=cortex-a76.cortex-a55+crypto -Os -Wl,--as-needed  -o src/expand src/expand.o src/expand-common.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a 
### /bin/ld: src/expand.o: in function `main':
### expand.c:(.text.startup+0x1e8): undefined reference to `mbfile_multi_getc'
### collect2: error: ld returned 1 exit status
# https://github.com/dslm4515/Musl-LFS/issues/11
	sed -i '/test.lock/s/^/#/' tmp/coreutils/coreutils-$(CORE_UTILS_VER)/gnulib-tests/gnulib.mk
	sed -i "s/SYS_getdents/SYS_getdents64/" tmp/coreutils/coreutils-$(CORE_UTILS_VER)/src/ls.c
	cd tmp/coreutils/coreutils-$(CORE_UTILS_VER) && autoreconf -fiv
	cd tmp/coreutils/bld && FORCE_UNSAFE_CONFIGURE=1 ../coreutils-$(CORE_UTILS_VER)/configure $(COREUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/coreutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/coreutils/ins/usr/libexec/coreutils/libstdbuf.so
	strip $(STRIP_BUILD_BIN) tmp/coreutils/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/coreutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/coreutils
src/coreutils-$(CORE_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/coreutils/coreutils-$(CORE_UTILS_VER).tar.xz && touch $@
src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch: src/.gitignore
	wget -P src --no-check-certificate http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/coreutils-$(CORE_UTILS_VER)-i18n-1.patch && touch $@
