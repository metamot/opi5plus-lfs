SRC+= src/bison-$(BISON_VER).tar.xz
PKG+= pkg/bison.cpio.zst
bison: pkg/bison.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BISON_OPT+= --prefix=/usr
BISON_OPT+= --disable-nls
BISON_OPT+= $(OPT_FLAGS)
pkg/bison.cpio.zst: src/bison-$(BISON_VER).tar.xz pkg/m4.cpio.zst pkg/perl.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/bison
	mkdir -p tmp/bison/bld
	tar -xJf $< -C tmp/bison
	cd tmp/bison/bld && ../bison-$(BISON_VER)/configure $(BISON_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/bison/ins/usr/share/doc
	rm -fr tmp/bison/ins/usr/share/info
	rm -fr tmp/bison/ins/usr/share/man
	rm -f  tmp/bison/ins/usr/share/bison/README.md
	rm -f  tmp/bison/ins/usr/share/bison/skeletons/README-D.txt
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/bison/ins/usr/lib/liby.a
	strip $(STRIP_BUILD_BIN) tmp/bison/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/bison/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/bison
src/bison-$(BISON_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/bison/bison-$(BISON_VER).tar.xz && touch $@

