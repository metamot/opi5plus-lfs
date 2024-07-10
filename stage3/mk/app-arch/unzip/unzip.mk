# WARNING: This unzip has problems with non-latin file-names! See 'Caution' on html-page above.
# Workaround1: Uze WinZip under Wine. -- Looks like terrific! (sarcasm)
# Workaround2: Use 'bsdtar -xf' (from libarchive) for unpack zip-files with convmv-fixing
# Workaround3: Use this UnZip and hope that filenames has no non-latin characters.
SRC+=src/unzip$(UNZIP_VER0).tar.gz
SRC+=src/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch
PKG+=pkg/unzip.cpio.zst
unzip: pkg/unzip.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/unzip.cpio.zst: src/unzip$(UNZIP_VER0).tar.gz unzip-$(UNZIP_VER)-consolidated_fixes-1.patch pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/unzip
	mkdir -p tmp/unzip
	tar -xzf $< -C tmp/unzip
	cp -f pkg/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch tmp/unzip/
	cd tmp/unzip/unzip$(UNZIP_VER0) && patch -Np1 -i ../unzip-$(UNZIP_VER)-consolidated_fixes-1.patch
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/unzip/unzip$(UNZIP_VER0)/unix/configure
	cd tmp/unzip/unzip$(UNZIP_VER0) && make $(JOBS) -f unix/Makefile generic
	mkdir -p tmp/unzip/ins/usr
	cd tmp/unzip/unzip$(UNZIP_VER0) && make prefix=../ins/usr MANDIR=../ins/usr/share/man/man1 -f unix/Makefile install
	rm -fr tmp/unzip/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/unzip/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/unzip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/unzip
src/unzip$(UNZIP_VER0).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/infozip/unzip$(UNZIP_VER0).tar.gz && touch $@
#--no-check-certificate
src/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch && touch $@

