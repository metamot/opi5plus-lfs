SRC+=src/diffutils-$(DIFF_UTILS_VER).tar.xz
PKG+=pkg/diffutils.cpio.zst
diffutils: pkg/diffutils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DIFFUTILS_OPT+= --prefix=/usr
DIFFUTILS_OPT+= --disable-nls
DIFFUTILS_OPT+= $(OPT_FLAGS)
pkg/diffutils.cpio.zst: src/diffutils-$(DIFF_UTILS_VER).tar.xz
	rm -fr tmp/diffutils
	mkdir -p tmp/diffutils/bld
	tar -xJf $< -C tmp/diffutils
	cd tmp/diffutils/bld && ../diffutils-$(DIFF_UTILS_VER)/configure $(DIFFUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/diffutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/diffutils/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/diffutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/diffutils
src/diffutils-$(DIFF_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/diffutils/diffutils-$(DIFF_UTILS_VER).tar.xz && touch $@
