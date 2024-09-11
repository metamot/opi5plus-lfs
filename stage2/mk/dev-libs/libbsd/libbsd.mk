# https://libbsd.freedesktop.org/releases/
SRC+=src/libbsd-$(LIBBSD_VER).tar.xz
PKG+=pkg/libbsd.cpio.zst
libbsd: pkg/libbsd.cpio.zst
	cat pkg/libmd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBBSD_OPT+= --prefix=/usr
LIBBSD_OPT+= --enable-shared
LIBBSD_OPT+= --disable-static
LIBBSD_OPT+= $(OPT_FLAGS)
pkg/libbsd.cpio.zst: src/libbsd-$(LIBBSD_VER).tar.xz pkg/libmd.cpio.zst pkg/file.cpio.zst
	cat pkg/libmd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libbsd
	mkdir -p tmp/libbsd/bld
	tar -xJf $< -C tmp/libbsd
	cd tmp/libbsd/bld && ../libbsd-$(LIBBSD_VER)/configure $(LIBBSD_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libbsd/ins/usr/share
	rm -f tmp/libbsd/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/libbsd/ins/usr/lib/libbsd-ctor.a
	strip $(STRIP_BUILD_LIB) tmp/libbsd/ins/usr/lib/*.so* || true
endif
	mkdir -p pkg && cd tmp/libbsd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libbsd
src/libbsd-$(LIBBSD_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://libbsd.freedesktop.org/releases/libbsd-$(LIBBSD_VER).tar.xz && touch $@
