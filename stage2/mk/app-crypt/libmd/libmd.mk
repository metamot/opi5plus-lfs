SRC+=src/libmd-$(LIBMD_VER).tar.xz
PKG+=pkg/libmd.cpio.zst
libmd: pkg/libmd.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBMD_OPT+= --prefix=/usr
LIBMD_OPT+= --disable-static
LIBMD_OPT+= $(OPT_FLAGS)
pkg/libmd.cpio.zst: src/libmd-$(LIBMD_VER).tar.xz pkg/file.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libmd
	mkdir -p tmp/libmd/bld
	tar -xJf $< -C tmp/libmd
	cd tmp/libmd/bld && ../libmd-$(LIBMD_VER)/configure $(LIBMD_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libmd/ins/usr/lib/*.la
	rm -fr tmp/libmd/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libmd/ins/usr/lib/*.so* || true
endif
	mkdir -p pkg && cd tmp/libmd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libmd
src/libmd-$(LIBMD_VER).tar.xz: src/.gitignore
#	wget -P src https://archive.hadrons.org/software/libmd/libmd-$(LIBMD_VER).tar.xz && touch $@
	wget -P src --no-check-certificate https://libbsd.freedesktop.org/releases/libmd-$(LIBMD_VER).tar.xz && touch $@
