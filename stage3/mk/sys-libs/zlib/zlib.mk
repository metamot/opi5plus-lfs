SRC+=src/zlib-$(ZLIB_VER).tar.xz
PKG+=pkg/zlib.cpio.zst
zlib: pkg/zlib.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ZLIB_OPT+= --prefix=/usr
pkg/zlib.cpio.zst: src/zlib-$(ZLIB_VER).tar.xz
	rm -fr tmp/zlib
	mkdir -p tmp/zlib/bld
	tar -xJf $< -C tmp/zlib
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/zlib/zlib-$(ZLIB_VER)/configure
	cd tmp/zlib/bld && ../zlib-$(ZLIB_VER)/configure $(ZLIB_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/zlib/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/zlib/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/zlib/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/zlib/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/zlib
src/zlib-$(ZLIB_VER).tar.xz: src/.gitignore
	wget --no-check-certificate -P src https://zlib.net/zlib-$(ZLIB_VER).tar.xz && touch $@
