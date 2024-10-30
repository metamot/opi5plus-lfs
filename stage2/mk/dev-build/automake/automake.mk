SRC+=src/automake-$(AUTOMAKE_VER).tar.xz
PKG+=pkg/automake.cpio.zst
automake: pkg/automake.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
AUTOMAKE_OPT+= --prefix=/usr
#AUTOMAKE_OPT+= --disable-f77
pkg/automake.cpio.zst: src/automake-$(AUTOMAKE_VER).tar.xz pkg/autoconf.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/autoconf.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/automake
	mkdir -p tmp/automake/bld
	tar -xJf $< -C tmp/automake
	sed -i "s/''/etags/" tmp/automake/automake-$(AUTOMAKE_VER)/t/tags-lisp-space.sh
	cd tmp/automake/bld && ../automake-$(AUTOMAKE_VER)/configure $(AUTOMAKE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/automake/ins/usr/share/doc
	rm -fr tmp/automake/ins/usr/share/info
	rm -fr tmp/automake/ins/usr/share/man
	rm -fr tmp/automake/ins/usr/share/aclocal
# aclocal is empty
	rm -f  tmp/automake/ins/usr/share/automake-$(AUTOMAKE_VER0)/COPYING
	rm -f  tmp/automake/ins/usr/share/automake-$(AUTOMAKE_VER0)/INSTALL
	mkdir -p pkg && cd tmp/automake/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/automake
src/automake-$(AUTOMAKE_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_VER).tar.xz && touch $@
