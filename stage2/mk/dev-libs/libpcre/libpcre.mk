SRC+=src/pcre-$(LIBPCRE_VER).tar.bz2
PKG+=pkg/libpcre.cpio.zst
libpcre: pkg/libpcre.cpio.zst
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBPCRE_OPT+= --prefix=/usr
LIBPCRE_OPT+= --docdir=/usr/share/doc/pcre-$(LIBPCRE_VER)
LIBPCRE_OPT+= --enable-unicode-properties
LIBPCRE_OPT+= --enable-pcre16
LIBPCRE_OPT+= --enable-pcre32
LIBPCRE_OPT+= --enable-pcregrep-libz
LIBPCRE_OPT+= --enable-pcregrep-libbz2
#LIBPCRE_OPT+= --enable-pcretest-libedit
LIBPCRE_OPT+= --enable-pcretest-libreadline
LIBPCRE_OPT+= --disable-static
#LIBPCRE_OPT+= --enable-jit
LIBPCRE_OPT+= $(OPT_FLAGS)
pkg/libpcre.cpio.zst: src/pcre-$(LIBPCRE_VER).tar.bz2 pkg/bzip2.cpio.zst pkg/zlib.cpio.zst pkg/readline.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/libedit.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libpcre
	mkdir -p tmp/libpcre/bld
	tar -xjf $< -C tmp/libpcre
	cd tmp/libpcre/bld && ../pcre-$(LIBPCRE_VER)/configure $(LIBPCRE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libpcre/ins/usr/share
	rm -f  tmp/libpcre/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/libpcre/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/libpcre/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libpcre/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libpcre
src/pcre-$(LIBPCRE_VER).tar.bz2: src/.gitignore
	wget -P src --no-check-certificate https://sourceforge.net/projects/pcre/files/pcre/$(LIBPCRE_VER)/pcre-$(LIBPCRE_VER).tar.bz2 && touch $@
