SRC+=src/bzip2-$(BZIP2_VER).tar.gz
SRC+=src/bzip2-$(BZIP2_VER)-install_docs-1.patch
PKG+=pkg/bzip2.cpio.zst
bzip2: pkg/bzip2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/bzip2.cpio.zst: src/bzip2-$(BZIP2_VER).tar.gz src/bzip2-$(BZIP2_VER)-install_docs-1.patch pkg/gzip.cpio.zst pkg/patch.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/patch.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/bzip2
	mkdir -p tmp/bzip2/ins/usr
	tar -xzf $< -C tmp/bzip2/
	cp -fav src/bzip2-$(BZIP2_VER)-install_docs-1.patch tmp/bzip2/
	cd tmp/bzip2/bzip2-$(BZIP2_VER) && patch -Np1 -i ../bzip2-$(BZIP2_VER)-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i 's@(PREFIX)/man@(PREFIX)/share/man@g' tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile-libbz2_so
	cd tmp/bzip2/bzip2-$(BZIP2_VER) && make $(JOBS) V=$(VERB) -f Makefile-libbz2_so && make clean && make $(JOBS) V=$(VERB) && make PREFIX=`pwd`/../ins/usr install
	rm -f tmp/bzip2/ins/usr/bin/bunzip2
	rm -f tmp/bzip2/ins/usr/bin/bzcat
	rm -f tmp/bzip2/ins/usr/bin/bzip2
	cp -fa tmp/bzip2/bzip2-$(BZIP2_VER)/bzip2-shared tmp/bzip2/ins/usr/bin/bzip2
	cd tmp/bzip2/ins/usr/bin && ln -sf bzip2 bunzip2 && ln -sf bzip2 bzcat
	cp -fa tmp/bzip2/bzip2-$(BZIP2_VER)/*.so* tmp/bzip2/ins/usr/lib/
	cd tmp/bzip2/ins/usr/lib && ln -sf libbz2.so.1.0 libbz2.so
	rm -fr tmp/bzip2/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/bzip2/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/bzip2/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/bzip2/ins/usr/bin/* || true
endif
	rm -f tmp/bzip2/ins/usr/lib/*.a
	mkdir -p pkg && cd tmp/bzip2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/bzip2
src/bzip2-$(BZIP2_VER).tar.gz: src/.gitignore
	wget --no-check-certificate -P src https://www.sourceware.org/pub/bzip2/bzip2-$(BZIP2_VER).tar.gz && touch $@
src/bzip2-$(BZIP2_VER)-install_docs-1.patch: src/.gitignore
	wget --no-check-certificate -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bzip2-$(BZIP2_VER)-install_docs-1.patch && touch $@
