SRC+=src/zstd-$(ZSTD_VER).tar.gz
PKG+=pkg/zstd.cpio.zst
zstd: pkg/zstd.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/zstd.cpio.zst: src/zstd-$(ZSTD_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/zstd
	mkdir -p tmp/zstd
	tar -xzf $< -C tmp/zstd
	find tmp/zstd/zstd-$(ZSTD_VER) -name "Makefile" -exec sed -i "s|-O3|$(BASE_OPT_VALUE)|" {} +
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/tests/fuzz/fuzz.py
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/contrib/linux-kernel/0002-lib-Add-zstd-modules.patch
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/Makefile
	cd tmp/zstd/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS) HAVE_ZLIB=0 HAVE_LZMA=0 HAVE_LZ4=0
	cd tmp/zstd/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS) HAVE_ZLIB=0 HAVE_LZMA=0 HAVE_LZ4=0 prefix=`pwd`/../ins/usr install
	rm -fr tmp/zstd/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/zstd/ins/usr/bin/* || true
	strip $(STRIP_BUILD_AST) tmp/zstd/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/zstd/ins/usr/lib/*.so*
endif
	rm -f tmp/zstd/ins/usr/lib/*.a
	mkdir -p pkg && cd tmp/zstd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/zstd
src/zstd-$(ZSTD_VER).tar.gz: src/.gitignore
	wget --no-check-certificate -P src https://github.com/facebook/zstd/releases/download/v$(ZSTD_VER)/zstd-$(ZSTD_VER).tar.gz && touch $@
