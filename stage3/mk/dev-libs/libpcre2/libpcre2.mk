SRC+=src/pcre2-$(LIBPCRE2_VER).tar.bz2
PKG+=pkg/libpcre2.cpio.zst
libpcre2: pkg/libpcre2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBPCRE2_OPT+= --prefix=/usr
LIBPCRE2_OPT+= --docdir=/usr/share/doc/$(LIBPCRE2_VER)
LIBPCRE2_OPT+= --enable-unicode
LIBPCRE2_OPT+= --enable-jit
LIBPCRE2_OPT+= --enable-pcre2-16
LIBPCRE2_OPT+= --enable-pcre2-32
LIBPCRE2_OPT+= --enable-pcre2grep-libz
LIBPCRE2_OPT+= --enable-pcre2grep-libbz2
#LIBPCRE2_OPT+= --enable-pcre2test-libedit
LIBPCRE2_OPT+= --enable-pcre2test-libreadline
LIBPCRE2_OPT+= --disable-static
LIBPCRE2_OPT+= $(OPT_FLAGS)
pkg/libpcre2.cpio.zst: src/pcre2-$(LIBPCRE2_VER).tar.bz2 pkg/bzip2.cpio.zst pkg/zlib.cpio.zst pkg/readline.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libpcre2
	mkdir -p tmp/libpcre2/bld
	tar -xjf $< -C tmp/libpcre2
	cd tmp/libpcre2/bld && ../pcre2-$(LIBPCRE2_VER)/configure $(LIBPCRE2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libpcre2/ins/usr/share
	rm -f tmp/libpcre2/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/libpcre2/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/libpcre2/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libpcre2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libpcre2
src/pcre2-$(LIBPCRE2_VER).tar.bz2: src/.gitignore
	wget -P src --no-check-certificate https://downloads.sourceforge.net/pcre/pcre2-$(LIBPCRE2_VER).tar.bz2 && touch $@
