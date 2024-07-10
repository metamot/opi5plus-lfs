SRC+=src/usbutils-$(USB_UTILS_VER).tar.xz
PKG+=pkg/attr.cpio.zst
attr: pkg/attr.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/attr.cpio.zst: src/usbutils-$(USB_UTILS_VER).tar.xz
	rm -fr tmp/usbutils
	mkdir -p tmp/usbutils
	tar -xJf $< -C tmp/usbutils
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/usbutils/usbutils-$(USB_UTILS_VER)/autogen.sh
	cd tmp/usbutils/usbutils-$(USB_UTILS_VER) && ./autogen.sh --prefix=/usr --datadir=/usr/share/hwdata && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/usbutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/usbutils/ins/usr/bin/* || true
endif
	install -dm755 tmp/usbutils/ins/usr/share/hwdata/
	cd tmp/usbutils/ins/usr/share/hwdata && wget http://www.linux-usb.org/usb.ids
	mkdir -p pkg && cd tmp/usbutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/usbutils
src/usbutils-$(USB_UTILS_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/usb/usbutils/usbutils-$(USB_UTILS_VER).tar.xz && touch $@
#--no-check-certificate

