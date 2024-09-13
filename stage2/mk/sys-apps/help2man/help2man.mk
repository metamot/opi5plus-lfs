SRC+=src/help2man-$(HELP2MAN_VER).tar.xz
PKG+=pkg/help2man.cpio.zst
help2man: pkg/help2man.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
HELP2MAN_OPT+= --prefix=/usr
HELP2MAN_OPT+= --disable-nls
pkg/help2man.cpio.zst: src/help2man-$(HELP2MAN_VER).tar.xz pkg/perl.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/help2man
	mkdir -p tmp/help2man/bld
	tar -xJf $< -C tmp/help2man
	cd tmp/help2man/bld && ../help2man-$(HELP2MAN_VER)/configure $(HELP2MAN_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/help2man/ins/usr/share
	mkdir -p pkg && cd tmp/help2man/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/help2man
src/help2man-$(HELP2MAN_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/help2man/help2man-$(HELP2MAN_VER).tar.xz && touch $@
