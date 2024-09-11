SRC+=src/parted-$(PARTED_VER).tar.xz
PKG+=pkg/parted.cpio.zst
parted: pkg/parted.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PARTED_OPT+= --prefix=/usr
PARTED_OPT+= --disable-static
PARTED_OPT+= --disable-nls
PARTED_OPT+= --disable-device-mapper
PARTED_OPT+= $(OPT_FLAGS)
pkg/parted.cpio.zst: src/parted-$(PARTED_VER).tar.xz
	rm -fr tmp/parted
	mkdir -p tmp/parted/bld
	tar -xJf $< -C tmp/parted
	cd tmp/parted/bld && ../parted-$(PARTED_VER)/configure $(PARTED_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/parted/ins/usr/share
	rm -f  tmp/parted/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/parted/ins/usr/sbin/*
	strip $(STRIP_BUILD_LIB) tmp/parted/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/parted/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/parted
src/parted-$(PARTED_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz && touch $@
# --no-check-certificate

