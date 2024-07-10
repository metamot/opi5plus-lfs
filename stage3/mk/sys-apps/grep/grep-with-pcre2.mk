SRC+=src/grep-$(GREP_WITH_PCRE2_VER).tar.xz
PKG+=pkg/grep-with-pcre2.cpio.zst
grep-with-pcre2: pkg/grep-with-pcre2.cpio.zst
	cat pkg/libpcre2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GREP_WITH_PCRE2_OPT+= --prefix=/usr
GREP_WITH_PCRE2_OPT+= --disable-nls
GREP_WITH_PCRE2_OPT+= --enable-perl-regexp
GREP_WITH_PCRE2_OPT+= $(OPT_FLAGS)
pkg/grep-with-pcre2.cpio.zst: src/grep-$(GREP_WITH_PCRE2_VER).tar.xz pkg/findutils.cpio.zst pkg/perl.cpio.zst pkg/libsigsegv.cpio.zst pkg/libpcre2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libpcre2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/grep-with-pcre2
	mkdir -p tmp/grep-with-pcre2/bld
	tar -xJf $< -C tmp/grep-with-pcre2
	cd tmp/grep-with-pcre2/bld && ../grep-$(GREP_WITH_PCRE2_VER)/configure $(GREP_WITH_PCRE2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/grep-with-pcre2/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/grep-with-pcre2/ins/usr/bin/grep
endif
	mkdir -p pkg && cd tmp/grep-with-pcre2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/grep-with-pcre2
src/grep-$(GREP_WITH_PCRE2_VER).tar.xz: src/.gitignore
	wget --no-check-certificate -P src http://ftp.gnu.org/gnu/grep/grep-$(GREP_WITH_PCRE2_VER).tar.xz && touch $@
