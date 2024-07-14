SRC+= src/binutils-$(BINUTILS_VER).tar.xz
PKG+= pkg/binutils.cpio.zst
binutils: pkg/binutils.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BINUTILS_OPT+= --prefix=/usr
#BINUTILS_OPT+= --enable-gold
BINUTILS_OPT+= --enable-ld=default
BINUTILS_OPT+= --enable-plugins
BINUTILS_OPT+= --enable-shared
BINUTILS_OPT+= --disable-werror
BINUTILS_OPT+= --enable-64-bit-bfd
BINUTILS_OPT+= --with-system-zlib
BINUTILS_OPT+= --without-debuginfod
BINUTILS_OPT+= $(OPT_FLAGS)
BINUTILS_OPT+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg/binutils.cpio.zst: src/binutils-$(BINUTILS_VER).tar.xz pkg/expect.cpio.zst pkg/texinfo.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/texinfo.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expect.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/binutils
	mkdir -p tmp/binutils/bld
	tar -xJf $< -C tmp/binutils
	expect -c "spawn ls"
#OK
	sed -i '/@\tincremental_copy/d' tmp/binutils/binutils-$(BINUTILS_VER)/gold/testsuite/Makefile.in
	cd tmp/binutils/bld && ../binutils-$(BINUTILS_VER)/configure $(BINUTILS_OPT) && make MAKEINFO=true tooldir=/usr $(JOBS) V=$(VERB) && make MAKEINFO=true tooldir=/usr DESTDIR=`pwd`/../ins install
	rm -fr tmp/binutils/ins/usr/share
	rm -f tmp/binutils/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/binutils/ins/usr/bin/* || true
	strip $(STRIP_BUILD_AST) tmp/binutils/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/binutils/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/binutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/binutils
src/binutils-$(BINUTILS_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.xz && touch $@
