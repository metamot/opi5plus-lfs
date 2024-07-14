SRC+=src/expat-$(EXPAT_VER).tar.xz
PKG+=pkg/expat.cpio.zst
expat: pkg/expat.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
EXPAT_OPT+= --prefix=/usr
EXPAT_OPT+= --disable-static
EXPAT_OPT+= --docdir=/usr/share/doc/expat-$(EXPAT_VER)
EXPAT_OPT+= $(OPT_FLAGS)
pkg/expat.cpio.zst: src/expat-$(EXPAT_VER).tar.xz pkg/file.cpio.zst
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/expat
	mkdir -p tmp/expat/bld
	tar -xJf $< -C tmp/expat
	cd tmp/expat/bld && ../expat-$(EXPAT_VER)/configure $(EXPAT_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/expat/ins/usr/share
	rm -f tmp/expat/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/expat/ins/usr/bin/xmlwf
	strip $(STRIP_BUILD_LIB) tmp/expat/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/expat/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/expat
src/expat-$(EXPAT_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://prdownloads.sourceforge.net/expat/expat-$(EXPAT_VER).tar.xz && touch $@
