# https://sourceware.org/elfutils/
SRC+=src/elfutils-$(ELF_UTILS_VER).tar.bz2
PKG+=pkg/elfutils.cpio.zst
elfutils: pkg/elfutils.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ELFUTILS_OPT+= --prefix=/usr
ELFUTILS_OPT+= --disable-debuginfod
ELFUTILS_OPT+= --libdir=/usr/lib
ELFUTILS_OPT+= --disable-nls
ELFUTILS_OPT+= $(OPT_FLAGS)
pkg/elfutils.cpio.zst: src/elfutils-$(ELF_UTILS_VER).tar.bz2 pkg/bzip2.cpio.zst pkg/zlib.cpio.zst pkg/xz-utils.cpio.zst pkg/grep.cpio.zst pkg/m4.cpio.zst pkg/bison.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/elfutils
	mkdir -p tmp/elfutils/bld
	tar -xjf $< -C tmp/elfutils
	cd tmp/elfutils/bld && ../elfutils-$(ELF_UTILS_VER)/configure $(ELFUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins-full install
#	cd tmp/elfutils/bld && make -C libelf DESTDIR=`pwd`/../ins-libelf install
	rm -fr tmp/elfutils/ins-full/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/elfutils/ins-full/usr/bin/* || true
	strip $(STRIP_BUILD_AST) tmp/elfutils/ins-full/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/elfutils/ins-full/usr/lib/*.so*
#	strip $(STRIP_BUILD_AST) tmp/elfutils/ins-libelf/usr/lib/*.a
#	strip $(STRIP_BUILD_LIB) tmp/elfutils/ins-libelf/usr/lib/*.so*
endif
	rm -f tmp/elfutils/ins-full/usr/lib/*.a
#	rm -f tmp/elfutils/ins-libelf/usr/lib/*.a
#	mkdir -p tmp/elfutils/ins-libelf/usr/lib/pkgconfig
#	install -vm644 tmp/elfutils/bld/config/libelf.pc tmp/elfutils/ins-libelf/usr/lib/pkgconfig
	mkdir -p pkg && cd tmp/elfutils/ins-full && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	mkdir -p pkg && cd tmp/elfutils/ins-libelf && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../pkg/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst
	rm -fr tmp/elfutils
src/elfutils-$(ELF_UTILS_VER).tar.bz2: src/.gitignore
	wget -P src --no-check-certificate https://sourceware.org/ftp/elfutils/$(ELF_UTILS_VER)/elfutils-$(ELF_UTILS_VER).tar.bz2 && touch $@
