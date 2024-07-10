SRC+=src/libtool-$(LIBTOOL_VER).tar.xz
PKG+=pkg/libtool.cpio.zst
libtool: pkg/libtool.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBTOOL_OPT+= --prefix=/usr
LIBTOOL_OPT+= $(OPT_FLAGS)
pkg/libtool.cpio.zst: src/libtool-$(LIBTOOL_VER).tar.xz pkg/m4.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libtool
	mkdir -p tmp/libtool/bld
	tar -xJf $< -C tmp/libtool
	cd tmp/libtool/bld && ../libtool-$(LIBTOOL_VER)/configure $(LIBTOOL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libtool/ins/usr/share/info
	rm -fr tmp/libtool/ins/usr/share/man
	rm -f  tmp/libtool/ins/usr/share/libtool/README
	rm -f  tmp/libtool/ins/usr/share/libtool/COPYING.LIB
	rm -f  tmp/libtool/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/libtool/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/libtool/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libtool/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libtool
src/libtool-$(LIBTOOL_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/libtool/libtool-$(LIBTOOL_VER).tar.xz && touch $@
#--no-check-certificate

