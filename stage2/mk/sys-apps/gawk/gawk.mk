SRC+=src/gawk-$(GAWK_VER).tar.xz
PKG+=pkg/gawk.cpio.zst
gawk: pkg/gawk.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GAWK_OPT+= --prefix=/usr
GAWK_OPT+= --disable-nls
GAWK_OPT+= --disable-mpfr
GAWK_OPT+= --without-libiconv-prefix
GAWK_OPT+= --without-libintl-prefix
GAWK_OPT+= --without-libsigsegv-prefix
GAWK_OPT+= $(OPT_FLAGS)
pkg/gawk.cpio.zst: src/gawk-$(GAWK_VER).tar.xz
	rm -fr tmp/gawk
	mkdir -p tmp/gawk/bld
	tar -xJf $< -C tmp/gawk
	sed -i 's/extras//' tmp/gawk/gawk-$(GAWK_VER)/Makefile.in
	cd tmp/gawk/bld && ../gawk-$(GAWK_VER)/configure $(GAWK_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gawk/ins/usr/share/info
	rm -fr tmp/gawk/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/gawk/ins/usr/libexec/awk/*
	strip $(STRIP_BUILD_LIB) tmp/gawk/ins/usr/lib/gawk/*
	strip $(STRIP_BUILD_BIN) tmp/gawk/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/gawk/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gawk
src/gawk-$(GAWK_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gawk/gawk-$(GAWK_VER).tar.xz && touch $@
#--no-check-certificate
