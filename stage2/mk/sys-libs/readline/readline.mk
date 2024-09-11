SRC+=src/readline-$(READLINE_VER).tar.gz
PKG+=pkg/readline.cpio.zst
readline: pkg/readline.cpio.zst
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
READLINE_OPT+= --prefix=/usr
READLINE_OPT+= --disable-static
READLINE_OPT+= --with-curses
READLINE_OPT+= $(OPT_FLAGS)
pkg/readline.cpio.zst: src/readline-$(READLINE_VER).tar.gz pkg/gzip.cpio.zst pkg/ncurses.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/readline
	mkdir -p tmp/readline/bld
	tar -xzf $< -C tmp/readline
	sed -i '/MV.*old/d' tmp/readline/readline-$(READLINE_VER)/Makefile.in
	sed -i '/{OLDSUFF}/c:' tmp/readline/readline-$(READLINE_VER)/support/shlib-install
	cd tmp/readline/bld && ../readline-$(READLINE_VER)/configure $(READLINE_OPT) && make SHLIB_LIBS="-lncursesw" -j1 V=$(VERB) && make SHLIB_LIBS="-lncursesw" DESTDIR=`pwd`/../ins install
	rm -fr tmp/readline/ins/usr/bin
	rm -fr tmp/readline/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/readline/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/readline/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/readline
src/readline-$(READLINE_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/readline/readline-$(READLINE_VER).tar.gz && touch $@
