SRC+=src/pkg-config-$(PKGCONFIG_VER).tar.gz
PKG+=pkg/pkgconfig.cpio.zst
pkgconfig: pkg/pkgconfig.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PKGCONFIG_OPT+= --prefix=/usr
PKGCONFIG_OPT+= --with-internal-glib
PKGCONFIG_OPT+= --disable-host-tool
PKGCONFIG_OPT+= $(OPT_FLAGS)
pkg/pkgconfig.cpio.zst: src/pkg-config-$(PKGCONFIG_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/pkgconfig
	mkdir -p tmp/pkgconfig/bld
	tar -xzf $< -C tmp/pkgconfig
	cd tmp/pkgconfig/bld && ../pkg-config-$(PKGCONFIG_VER)/configure $(PKGCONFIG_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/pkgconfig/ins/usr/share/doc
	rm -fr tmp/pkgconfig/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/pkgconfig/ins/usr/bin/pkg-config
endif
	mkdir -p pkg && cd tmp/pkgconfig/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/pkgconfig
src/pkg-config-$(PKGCONFIG_VER).tar.gz: src/.gitignore
	wget --no-check-certificate -P src https://pkg-config.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz && touch $@
