SRC+=src/texinfo-$(TEXINFO_VER).tar.xz
PKG+=pkg/texinfo.cpio.zst
texinfo: pkg/texinfo.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
TEXINFO_OPT+= --prefix=/usr
TEXINFO_OPT+= --disable-nls
TEXINFO_OPT+= $(OPT_FLAGS)
pkg/texinfo.cpio.zst: src/texinfo-$(TEXINFO_VER).tar.xz pkg/perl.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/texinfo
	mkdir -p tmp/texinfo/bld
	tar -xJf $< -C tmp/texinfo
	cd tmp/texinfo/bld && ../texinfo-$(TEXINFO_VER)/configure $(TEXINFO_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/texinfo/ins/usr/share/info
	rm -fr tmp/texinfo/ins/usr/share/man
	rm -f  tmp/texinfo/ins/usr/lib/texinfo/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/texinfo/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/texinfo/ins/usr/lib/texinfo/*.so*
endif
	mkdir -p pkg && cd tmp/texinfo/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/texinfo
src/texinfo-$(TEXINFO_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.xz && touch $@
