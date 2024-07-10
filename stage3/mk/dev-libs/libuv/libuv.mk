SRC+=src/libuv-$(LIBUV_VER).tar.gz
PKG+=pkg/libuv.cpio.zst
libuv: pkg/libuv.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBUV_OPT3+= --prefix=/usr
LIBUV_OPT3+= --disable-static
LIBUV_OPT3+= $(OPT_FLAGS)
pkg/libuv.cpio.zst: src/libuv-$(LIBUV_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libuv
	mkdir -p tmp/libuv/bld
	tar -xzf $< -C tmp/libuv
	cd tmp/libuv/libuv-$(LIBUV_VER) && ./autogen.sh
	cd tmp/libuv/bld && ../libuv-$(LIBUV_VER)/configure $(LIBUV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libuv/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libuv/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libuv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@	
	rm -fr tmp/libuv
src/libuv-$(LIBUV_VER).tar.gz: src/.gitignore
	wget -P src https://dist.libuv.org/dist/$(LIBUV_VER)/libuv-$(LIBUV_VER).tar.gz && touch $@
# --no-check-certificate

