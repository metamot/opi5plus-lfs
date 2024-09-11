SRC+=src/autoconf-$(AUTOCONF_VER).tar.xz
PKG+=pkg/autoconf.cpio.zst
autoconf: pkg/autoconf.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
AUTOCONF_OPT+= --prefix=/usr
pkg/autoconf.cpio.zst: src/autoconf-$(AUTOCONF_VER).tar.xz pkg/m4.cpio.zst pkg/perl.cpio.zst pkg/help2man.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/help2man.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/autoconf
	mkdir -p tmp/autoconf/bld
	tar -xJf $< -C tmp/autoconf
	sed -i '361 s/{/\\{/' tmp/autoconf/autoconf-$(AUTOCONF_VER)/bin/autoscan.in
	cd tmp/autoconf/bld && ../autoconf-$(AUTOCONF_VER)/configure $(AUTOCONF_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/autoconf/ins/usr/share/info
	rm -fr tmp/autoconf/ins/usr/share/man
	rm -f  tmp/autoconf/ins/usr/share/autoconf/INSTALL
	mkdir -p pkg && cd tmp/autoconf/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/autoconf
src/autoconf-$(AUTOCONF_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_VER).tar.xz && touch $@
#--no-check-certificate
