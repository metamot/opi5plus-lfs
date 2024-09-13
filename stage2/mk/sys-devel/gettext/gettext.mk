SRC+=src/gettext-$(GETTEXT_VER).tar.xz
PKG+=pkg/gettext.cpio.zst
gettext: pkg/gettext.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GETTEXT_OPT+= --prefix=/usr
GETTEXT_OPT+= --disable-static
GETTEXT_OPT+= --docdir=/usr/share/doc/gettext-$(GETTEXT_VER)
GETTEXT_OPT+= --disable-nls
GETTEXT_OPT+= $(OPT_FLAGS)
pkg/gettext.cpio.zst: src/gettext-$(GETTEXT_VER).tar.xz pkg/acl.cpio.zst pkg/ncurses.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gettext
	mkdir -p tmp/gettext/bld
	tar -xJf $< -C tmp/gettext
	cd tmp/gettext/bld && ../gettext-$(GETTEXT_VER)/configure $(GETTEXT_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gettext/ins/usr/share/doc
	rm -fr tmp/gettext/ins/usr/share/info
	rm -fr tmp/gettext/ins/usr/share/gettext/projects
	rm -fr tmp/gettext/ins/usr/share/gettext/ABOUT-NLS
	rm -fr tmp/gettext/ins/usr/lib/*.la
	chmod -v 0755 tmp/gettext/ins/usr/lib/preloadable_libintl.so
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/gettext/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/gettext/ins/usr/lib/gettext/* || true
	strip $(STRIP_BUILD_LIB) tmp/gettext/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/gettext/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gettext
src/gettext-$(GETTEXT_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/gettext/gettext-$(GETTEXT_VER).tar.xz && touch $@
