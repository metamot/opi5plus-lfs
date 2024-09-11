#WARNING!!! Basic "zstd.mk" must be included above!
#SRC+=src/zstd-$(ZSTD_VER).tar.gz
PKG+=pkg/zstd-max.cpio.zst
zstd-max: pkg/zstd-max.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/lz4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/zstd-max.cpio.zst: src/zstd-$(ZSTD_VER).tar.gz pkg/gzip.cpio.zst pkg/zlib.cpio.zst pkg/xz-utils.cpio.zst pkg/lz4.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/lz4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/zstd-max
	mkdir -p tmp/zstd-max
	tar -xzf $< -C tmp/zstd-max
	find tmp/zstd-max/zstd-$(ZSTD_VER) -name "Makefile" -exec sed -i "s|-O3|$(BASE_OPT_VALUE)|" {} +
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd-max/zstd-$(ZSTD_VER)/tests/fuzz/fuzz.py
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd-max/zstd-$(ZSTD_VER)/contrib/linux-kernel/0002-lib-Add-zstd-modules.patch
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd-max/zstd-$(ZSTD_VER)/Makefile
	cd tmp/zstd-max/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS)
	cd tmp/zstd-max/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS) prefix=`pwd`/../ins/usr install
	rm -fr tmp/zstd-max/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/zstd-max/ins/usr/bin/* || true
	strip $(STRIP_BUILD_AST) tmp/zstd-max/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/zstd-max/ins/usr/lib/*.so*
endif
	rm -f tmp/zstd-max/ins/usr/lib/*.a
	mkdir -p pkg && cd tmp/zstd-max/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/zstd-max
#src/zstd-$(ZSTD_VER).tar.gz: src/.gitignore
#	wget --no-check-certificate -P src https://github.com/facebook/zstd/releases/download/v$(ZSTD_VER)/zstd-$(ZSTD_VER).tar.gz && touch $@
