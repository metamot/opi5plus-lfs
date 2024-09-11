SRC+=src/libuuid-$(LIBUUID_VER).tar.gz
PKG+=pkg/libuuid.cpio.zst
libuuid: pkg/libuuid.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBUUID_OPT+= --prefix=/usr
LIBUUID_OPT+= --disable-static
LIBUUID_OPT+= $(OPT_FLAGS)
pkg/libuuid.cpio.zst: src/libuuid-$(LIBUUID_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libuuid
	mkdir -p tmp/libuuid/bld
	tar -xzf $< -C tmp/libuuid
	cd tmp/libuuid/bld && ../libuuid-$(LIBUUID_VER)/configure $(LIBUUID_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libuuid/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libuuid/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libuuid/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libuuid
src/libuuid-$(LIBUUID_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://sourceforge.net/projects/libuuid/files/libuuid-$(LIBUUID_VER).tar.gz && touch $@
