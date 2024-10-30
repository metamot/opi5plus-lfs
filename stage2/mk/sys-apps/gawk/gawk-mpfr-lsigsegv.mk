# gawk.mk must be included berore
PKG+=pkg/gawk-mpfr-lsigsegv.cpio.zst
gawk-mpfr-lsigsegv: pkg/gawk-mpfr-lsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GAWK_MPFR_SIGSEGV_OPT+= --prefix=/usr
GAWK_MPFR_SIGSEGV_OPT+= --disable-nls
GAWK_MPFR_SIGSEGV_OPT+= $(OPT_FLAGS)
pkg/gawk-mpfr-lsigsegv.cpio.zst: src/gawk-$(GAWK_VER).tar.xz pkg/mpfr.cpio.zst pkg/libsigsegv.cpio.zst
# pkg/readline.cpio.zst pkg/bison.cpio.zst
#	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gawk-mpfr-lsigsegv
	mkdir -p tmp/gawk-mpfr-lsigsegv/bld
	tar -xJf $< -C tmp/gawk-mpfr-lsigsegv
	sed -i 's/extras//' tmp/gawk-mpfr-lsigsegv/gawk-$(GAWK_VER)/Makefile.in
	cd tmp/gawk-mpfr-lsigsegv/bld && ../gawk-$(GAWK_VER)/configure $(GAWK_MPFR_SIGSEGV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gawk-mpfr-lsigsegv/ins/usr/share/info
	rm -fr tmp/gawk-mpfr-lsigsegv/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/gawk-mpfr-lsigsegv/ins/usr/libexec/awk/*
	strip $(STRIP_BUILD_LIB) tmp/gawk-mpfr-lsigsegv/ins/usr/lib/gawk/*
	strip $(STRIP_BUILD_BIN) tmp/gawk-mpfr-lsigsegv/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/gawk-mpfr-lsigsegv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gawk-mpfr-lsigsegv
