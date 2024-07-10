SRC+=src/lz4-$(LZ4_VER).tar.gz
PKG+=pkg/lz4.cpio.zst
lz4: pkg/lz4.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/lz4.cpio.zst: src/lz4-$(LZ4_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/lz4
	mkdir -p tmp/lz4
	tar -xzf $< -C tmp/lz4
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/lz4/lz4-$(LZ4_VER)/lib/Makefile
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/lz4/lz4-$(LZ4_VER)/programs/Makefile
#	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/lz4/lz4-$(LZ4_VER)/Makefile
	cd tmp/lz4/lz4-$(LZ4_VER) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins PREFIX=/usr install
	rm -fr tmp/lz4/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/lz4/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/lz4/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/lz4/ins/usr/bin/* || true
endif
	rm -f tmp/lz4/ins/usr/lib/*.a
	mkdir -p pkg && cd tmp/lz4/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/lz4
src/lz4-$(LZ4_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://github.com/lz4/lz4/releases/download/v$(LZ4_VER)/lz4-$(LZ4_VER).tar.gz && touch $@
