SRC+=src/mpfr-$(MPFR_VER).tar.xz
PKG+=pkg/mpfr.cpio.zst
mpfr: pkg/mpfr.cpio.zst
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
MPFR_OPT+= --prefix=/usr
MPFR_OPT+= --disable-static
MPFR_OPT+= --enable-thread-safe
MPFR_OPT+= --docdir=/usr/share/doc/mpfr-$(MPFR_VER)
MPFR_OPT+= $(OPT_FLAGS)
pkg/mpfr.cpio.zst: src/mpfr-$(MPFR_VER).tar.xz pkg/gmp.cpio.zst
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/mpfr
	mkdir -p tmp/mpfr/bld
	tar -xJf $< -C tmp/mpfr
	cd tmp/mpfr/bld && ../mpfr-$(MPFR_VER)/configure $(MPFR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mpfr/ins/usr/share
	rm -f tmp/mpfr/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/mpfr/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/mpfr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mpfr
src/mpfr-$(MPFR_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://www.mpfr.org/mpfr-$(MPFR_VER)/mpfr-$(MPFR_VER).tar.xz && touch $@
