SRC+=src/xz-$(XZ_VER).tar.xz
PKG+=pkg/xz-utils.cpio.zst
xz-utils: pkg/xz-utils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
XZ_OPT+= --prefix=/usr
XZ_OPT+= --disable-static
XZ_OPT+= --docdir=/usr/share/doc/xz-$(XZ_VER)
XZ_OPT+= --disable-nls
ifeq ($(BASE_OPT_VALUE),-Os)
XZ_OPT+= --enable-small
endif
XZ_OPT+= --disable-doc
XZ_OPT+= $(OPT_FLAGS)
pkg/xz-utils.cpio.zst: src/xz-$(XZ_VER).tar.xz
	rm -fr tmp/xz
	mkdir -p tmp/xz/bld
	tar -xJf $< -C tmp/xz
	cd tmp/xz/bld && ../xz-$(XZ_VER)/configure $(XZ_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/xz/ins/usr/share
	rm -f tmp/xz/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/xz/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/xz/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/xz/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/xz
src/xz-$(XZ_VER).tar.xz: src/.gitignore
	wget --no-check-certificate -P src https://tukaani.org/xz/xz-$(XZ_VER).tar.xz && touch $@
