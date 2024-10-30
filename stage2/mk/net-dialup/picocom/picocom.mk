SRC+=src/picocom-$(PICOCOM_VER).tar.zip
PKG+=pkg/picocom.cpio.zst
picocom: pkg/picocom.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PICOCOM_OPT+= --prefix=/usr
PICOCOM_OPT+= $(OPT_FLAGS)
pkg/picocom.cpio.zst: src/picocom-$(PICOCOM_VER).tar.zip pkg/libarchive.cpio.zst
	cat pkg/libarchive.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/picocom
	mkdir -p tmp/picocom/bld
	bsdtar -xf $< -C tmp/pyelftools
#	cd tmp/attr/bld && ../attr-$(ATTR_VER)/configure $(ATTR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/attr/ins/usr/share
#	rm -f tmp/attr/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/attr/ins/usr/lib/*.so*
#	strip $(STRIP_BUILD_BIN) tmp/attr/ins/usr/bin/* || true
#endif
#	mkdir -p pkg && cd tmp/attr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/attr
src/picocom-$(PICOCOM_VER).tar.zip: src/.gitignore
	wget -O src/picocom-$(PICOCOM_VER).tar.zip https://github.com/npat-efault/picocom/archive/refs/tags/$(PICOCOM_VER).zip && touch $@
#--no-check-certificate

