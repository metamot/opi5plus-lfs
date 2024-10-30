SRC+=src/ncurses-$(NCURSES_VER).tar.gz
PKG+=pkg/ncurses.cpio.zst
ncurses: pkg/ncurses.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
NCURSES_OPT+= --prefix=/usr
NCURSES_OPT+= --mandir=/usr/share/man
NCURSES_OPT+= --with-shared
NCURSES_OPT+= --without-debug
NCURSES_OPT+= --without-normal
NCURSES_OPT+= --enable-pc-files
NCURSES_OPT+= --enable-widec
NCURSES_OPT+= --without-ada
NCURSES_OPT+= --without-pcre2
NCURSES_OPT+= $(OPT_FLAGS)
pkg/ncurses.cpio.zst: src/ncurses-$(NCURSES_VER).tar.gz pkg/gzip.cpio.zst pkg/pkgconfig.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idH newc -D / > /dev/null 2>&1
	cat pkg/pkgconfig.cpio.zst | zstd -d | cpio -idH newc -D / > /dev/null 2>&1
	rm -fr tmp/ncurses
	mkdir -p tmp/ncurses/bld
	tar -xzf $< -C tmp/ncurses
	sed -i '/LIBTOOL_INSTALL/d' tmp/ncurses/ncurses-$(NCURSES_VER)/c++/Makefile.in
	cd tmp/ncurses/bld && ../ncurses-$(NCURSES_VER)/configure $(NCURSES_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/ncurses/ins/usr/share/man
	rm -vf tmp/ncurses/ins/usr/lib/libncurses.so
	echo "INPUT(-lncursesw)" > tmp/ncurses/ins/usr/lib/libncurses.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf ncursesw.pc ncurses.pc
	rm -vf tmp/ncurses/ins/usr/lib/libform.so
	echo "INPUT(-lformw)" > tmp/ncurses/ins/usr/lib/libform.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf formw.pc form.pc
	rm -vf tmp/ncurses/ins/usr/lib/libpanel.so
	echo "INPUT(-lpanelw)" > tmp/ncurses/ins/usr/lib/libpanel.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf panelw.pc panel.pc
	rm -vf tmp/ncurses/ins/usr/lib/libmenu.so
	echo "INPUT(-lmenuw)" > tmp/ncurses/ins/usr/lib/libmenu.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf menuw.pc menu.pc
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf ncurses++w.pc ncurses++.pc
	rm -vf tmp/ncurses/ins/usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > tmp/ncurses/ins/usr/lib/libcursesw.so
	cd tmp/ncurses/ins/usr/lib && ln -sf libncurses.so libcurses.so
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/ncurses/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/ncurses/ins/usr/lib/*.so* || true
	strip $(STRIP_BUILD_AST) tmp/ncurses/ins/usr/lib/*.a
endif
	mkdir -p pkg && cd tmp/ncurses/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/ncurses
src/ncurses-$(NCURSES_VER).tar.gz: src/.gitignore
	wget --no-check-certificate -P src http://ftp.gnu.org/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz && touch $@
