SRC+=src/libarchive-$(LIBARCHIVE_VER).tar.xz
SRC+=src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch
PKG+=pkg/libarchive.cpio.zst
libarchive: pkg/libarchive.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBARCHIVE_OPT+= --prefix=/usr
LIBARCHIVE_OPT+= --disable-static
LIBARCHIVE_OPT+= $(OPT_FLAGS)
pkg/libarchive.cpio.zst: src/libarchive-$(LIBARCHIVE_VER).tar.xz src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch
	rm -fr tmp/libarchive
	mkdir -p tmp/libarchive/bld
	tar -xJf $< -C tmp/libarchive
	cp -f pkg/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch tmp/libarchive
	cd tmp/libarchive/libarchive-$(LIBARCHIVE_VER) && patch -Np1 -i ../libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch
	cd tmp/libarchive/bld && ../libarchive-$(LIBARCHIVE_VER)/configure $(LIBARCHIVE_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libarchive/ins/usr/share
	rm -f  tmp/libarchive/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/libarchive/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/libarchive/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libarchive/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libarchive
src/libarchive-$(LIBARCHIVE_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/libarchive/libarchive/releases/download/v$(LIBARCHIVE_VER)/libarchive-$(LIBARCHIVE_VER).tar.xz && touch $@
#--no-check-certificate
src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch && touch $@

