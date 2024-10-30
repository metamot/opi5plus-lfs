# diffutils.mk must be included above
PKG+=pkg/diffutils-lsigsegv.cpio.zst
diffutils-lsigsegv: pkg/diffutils-lsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DIFFUTILS_SIGSEGV_OPT+= --prefix=/usr
DIFFUTILS_SIGSEGV_OPT+= --disable-nls
DIFFUTILS_SIGSEGV_OPT+= $(OPT_FLAGS)
pkg/diffutils-lsigsegv.cpio.zst: src/diffutils-$(DIFF_UTILS_VER).tar.xz pkg/libsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/diffutils-lsigsegv
	mkdir -p tmp/diffutils-lsigsegv/bld
	tar -xJf $< -C tmp/diffutils-lsigsegv
	cd tmp/diffutils-lsigsegv/bld && ../diffutils-$(DIFF_UTILS_VER)/configure $(DIFFUTILS_SIGSEGV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/diffutils-lsigsegv/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/diffutils-lsigsegv/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/diffutils-lsigsegv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/diffutils-lsigsegv
