SRC+=src/gdbm-$(GDBM_VER).tar.gz
PKG+=pkg/gdbm.cpio.zst
gdbm: pkg/gdbm.cpio.zst
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GDBM_OPT+= --prefix=/usr
GDBM_OPT+= --disable-static
GDBM_OPT+= --enable-libgdbm-compat
GDBM_OPT+= --disable-nls
GDBM_OPT+= $(OPT_FLAGS)
pkg/gdbm.cpio.zst: src/gdbm-$(GDBM_VER).tar.gz pkg/gzip.cpio.zst pkg/readline.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gdbm
	mkdir -p tmp/gdbm/bld
	tar -xzf $< -C tmp/gdbm
	sed -r -i '/^char.*parseopt_program_(doc|args)/d' tmp/gdbm/gdbm-$(GDBM_VER)/src/parseopt.c
	cd tmp/gdbm/bld && ../gdbm-$(GDBM_VER)/configure $(GDBM_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gdbm/ins/usr/share
	rm -fr tmp/gdbm/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/gdbm/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/gdbm/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/gdbm/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gdbm
src/gdbm-$(GDBM_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/gdbm/gdbm-$(GDBM_VER).tar.gz && touch $@
