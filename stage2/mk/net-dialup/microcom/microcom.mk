SRC+=src/microcom-$(MICROCOM_VER).tar.gz
PKG+=pkg/microcom.cpio.zst
microcom: pkg/microcom.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
MICROCOM_OPT+= --prefix=/usr
MICROCOM_OPT+= --enable-can
MICROCOM_OPT+= $(OPT_FLAGS)
pkg/microcom.cpio.zst: src/microcom-$(MICROCOM_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/microcom
	mkdir -p tmp/microcom/bld
	tar -xzf $< -C tmp/microcom
	cd tmp/microcom/microcom-$(MICROCOM_VER) && autoreconf -i
	cd tmp/microcom/bld && ../microcom-$(MICROCOM_VER)/configure $(MICROCOM_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/microcom/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/microcom/ins/usr/bin/microcom
endif
	mkdir -p pkg && cd tmp/microcom/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/microcom
src/microcom-$(MICROCOM_VER).tar.gz: src/.gitignore
	wget -O src/microcom-$(MICROCOM_VER).tar.gz https://github.com/pengutronix/microcom/archive/refs/tags/v$(MICROCOM_VER).tar.gz && touch $@
#--no-check-certificate

