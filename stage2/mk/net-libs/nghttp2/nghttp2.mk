SRC+=src/nghttp2-$(NGHTTP2_VER).tar.xz
PKG+=pkg/nghttp2.cpio.zst
nghttp2: pkg/nghttp2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
NGHTTP2_OPT+= --prefix=/usr
NGHTTP2_OPT+= --disable-static
NGHTTP2_OPT+= --enable-lib-only
NGHTTP2_OPT+= --docdir=/usr/share/doc/nghttp2-$(NGHTTP2_VER)
NGHTTP2_OPT+= $(OPT_FLAGS)
pkg/nghttp2.cpio.zst: src/nghttp2-$(NGHTTP2_VER).tar.xz
	rm -fr tmp/nghttp2
	mkdir -p tmp/nghttp2/bld
	tar -xJf $< -C tmp/nghttp2
	cd tmp/nghttp2/bld && ../nghttp2-$(NGHTTP2_VER)/configure $(NGHTTP2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/nghttp2/ins/usr/share/doc
	rm -fr tmp/nghttp2/ins/usr/share/man
	rm -fr tmp/nghttp2/ins/usr/bin
	rm -fr tmp/nghttp2/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/nghttp2/ins/usr/lib/*.so* || true
endif
#	mkdir -p pkg && cd tmp/nghttp2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/nghttp2
src/nghttp2-$(NGHTTP2_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/nghttp2/nghttp2/releases/download/v$(NGHTTP2_VER)/nghttp2-$(NGHTTP2_VER).tar.xz && touch $@
# --no-check-certificate

