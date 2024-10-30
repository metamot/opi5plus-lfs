SRC+=src/libunistring-$(LIBUNISTRING_VER).tar.xz
PKG+=pkg/libunistring.cpio.zst
libunistring: pkg/libunistring.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBUNISTRING_OPT+= --prefix=/usr
LIBUNISTRING_OPT+= --disable-static
LIBUNISTRING_OPT+= --docdir=/usr/share/doc/libunistring-$(LIBUNISTRING_VER)
LIBUNISTRING_OPT+= $(OPT_FLAGS)
pkg/libunistring.cpio.zst: src/libunistring-$(LIBUNISTRING_VER).tar.xz
	rm -fr tmp/libunistring
	mkdir -p tmp/libunistring/bld
	tar -xJf $< -C tmp/libunistring
	cd tmp/libunistring/bld && ../libunistring-$(LIBUNISTRING_VER)/configure $(LIBUNISTRING_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/libunistring/ins/usr/share
#	rm -f tmp/libunistring/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/libunistring/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/libunistring/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/libunistring
src/libunistring-$(LIBUNISTRING_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libunistring/libunistring-$(LIBUNISTRING_VER).tar.xz && touch $@
#--no-check-certificate

