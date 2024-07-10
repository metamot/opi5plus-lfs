SRC+=src/zip$(ZIP_VER0).tar.gz
PKG+=pkg/zip.cpio.zst
zip: pkg/zip.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/zip.cpio.zst: src/zip$(ZIP_VER0).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/zip
	mkdir -p tmp/zip
	tar -xzf $< -C tmp/zip
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/zip/zip$(ZIP_VER0)/unix/configure
	cd tmp/zip/zip$(ZIP_VER0) && make $(JOBS) -f unix/Makefile generic_gcc
	mkdir -p tmp/zip/ins/usr
	cd tmp/zip/zip$(ZIP_VER0) && make prefix=../ins/usr MANDIR=../ins/usr/share/man/man1 -f unix/Makefile install
	rm -fr tmp/zip/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/zip/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/zip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/zip
src/zip$(ZIP_VER0).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/infozip/zip$(ZIP_VER0).tar.gz && touch $@
#--no-check-certificate

