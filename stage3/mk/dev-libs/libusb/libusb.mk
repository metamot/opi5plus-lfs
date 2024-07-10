SRC+=src/libusb-$(LIBUSB_VER).tar.bz2
PKG+=pkg/libusb.cpio.zst
libusb: pkg/libusb.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBUSB_OPT3+= --prefix=/usr
LIBUSB_OPT3+= --disable-static
LIBUSB_OPT3+= $(OPT_FLAGS)
pkg/libusb.cpio.zst: src/libusb-$(LIBUSB_VER).tar.bz2 pkg/bzip2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libusb
	mkdir -p tmp/libusb/bld
	tar -xjf $< -C tmp/libusb
	sed -i "s/^PROJECT_LOGO/#&/" tmp/libusb/libusb-$(LIBUSB_VER)/doc/doxygen.cfg.in
	cd tmp/libusb/bld && ../libusb-$(LIBUSB_VER)/configure $(LIBUSB_OPT) && make -j1 V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libusb/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libusb/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libusb/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libusb
src/libusb-$(LIBUSB_VER).tar.bz2: src/.gitignore
	wget -P src https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VER)/libusb-$(LIBUSB_VER).tar.bz2 && touch $@
# --no-check-certificate

