SRC+=src/cpio-$(CPIO_VER).tar.bz2
PKG+=pkg/cpio.cpio.zst
cpio: pkg/cpio.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
CPIO_OPT+= --prefix=/usr
CPIO_OPT+= --enable-mt
CPIO_OPT+= --disable-nls
CPIO_OPT+= --disable-static
CPIO_OPT+= --with-rmt=/usr/libexec/rmt
CPIO_OPT+= $(OPT_FLAGS)
pkg/cpio.cpio.zst: src/cpio-$(CPIO_VER).tar.bz2 pkg/bzip2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/cpio
	mkdir -p tmp/cpio/bld
	tar -xjf $< -C tmp/cpio
	sed -i '/The name/,+2 d' tmp/cpio/cpio-$(CPIO_VER)/src/global.c
	cd tmp/cpio/bld && ../cpio-$(CPIO_VER)/configure $(CPIO_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/cpio/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/cpio/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/cpio/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/cpio
src/cpio-$(CPIO_VER).tar.bz2: src/.gitignore
	wget --no-check-certificate -P src https://ftp.gnu.org/gnu/cpio/cpio-$(CPIO_VER).tar.bz2 && touch $@
