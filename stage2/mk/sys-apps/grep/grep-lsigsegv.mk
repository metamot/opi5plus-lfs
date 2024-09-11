# grep,mk must be included above
PKG+=pkg/grep-lsigsegv.cpio.zst
grep-lsigsegv: pkg/grep-lsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GREP_SIGSEGV_OPT+= --prefix=/usr
GREP_SIGSEGV_OPT+= --disable-nls
GREP_SIGSEGV_OPT+= --disable-perl-regexp
GREP_SIGSEGV_OPT+= $(OPT_FLAGS)
pkg/grep-lsigsegv.cpio.zst: src/grep-$(GREP_VER).tar.xz pkg/libsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/grep-lsigsegv
	mkdir -p tmp/grep-lsigsegv/bld
	tar -xJf $< -C tmp/grep-lsigsegv
	cd tmp/grep-lsigsegv/bld && ../grep-$(GREP_VER)/configure $(GREP_SIGSEGV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/grep-lsigsegv/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/grep-lsigsegv/ins/usr/bin/grep
endif
	mkdir -p pkg && cd tmp/grep-lsigsegv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/grep-lsigsegv
