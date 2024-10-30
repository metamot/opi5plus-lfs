# gawk.mk must be included berore
PKG+=pkg/gawk-mpfr.cpio.zst
gawk-mpfr: pkg/gawk-mpfr.cpio.zst
#	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GAWK_MPFR_OPT+= --prefix=/usr
GAWK_MPFR_OPT+= --disable-nls
GAWK_MPFR_OPT+= --without-libiconv-prefix
GAWK_MPFR_OPT+= --without-libintl-prefix
GAWK_MPFR_OPT+= --without-libsigsegv-prefix
GAWK_MPFR_OPT+= $(OPT_FLAGS)
pkg/gawk-mpfr.cpio.zst: src/gawk-$(GAWK_VER).tar.xz pkg/mpfr.cpio.zst
# pkg/readline.cpio.zst pkg/bison.cpio.zst  pkg/libsigsegv.cpio.zst
#	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gawk_mpfr
	mkdir -p tmp/gawk_mpfr/bld
	tar -xJf $< -C tmp/gawk_mpfr
	sed -i 's/extras//' tmp/gawk_mpfr/gawk-$(GAWK_VER)/Makefile.in
	cd tmp/gawk_mpfr/bld && ../gawk-$(GAWK_VER)/configure $(GAWK_MPFR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gawk_mpfr/ins/usr/share/info
	rm -fr tmp/gawk_mpfr/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/gawk_mpfr/ins/usr/libexec/awk/*
	strip $(STRIP_BUILD_LIB) tmp/gawk_mpfr/ins/usr/lib/gawk/*
	strip $(STRIP_BUILD_BIN) tmp/gawk_mpfr/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/gawk_mpfr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gawk_mpfr
