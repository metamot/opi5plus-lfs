SRC+=src/icu-$(ICU_VER).tar.gz
PKG+=pkg/icu.cpio.zst
icu: pkg/icu.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ICU_OPT+= --prefix=/usr
ICU_OPT+= $(OPT_FLAGS)
pkg/icu.cpio.zst: src/icu-$(ICU_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/icu
	mkdir -p tmp/icu/icu/bld
	tar -xzf $< -C tmp/icu
	cd tmp/icu/icu/bld && ../source/configure $(ICU_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../../ins install
	rm -fr tmp/icu/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/icu/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/icu/ins/usr/sbin/* || true
	strip $(STRIP_BUILD_LIB) tmp/icu/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/icu/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/icu
src/icu-$(ICU_VER).tar.gz: src/.gitignore
	wget -O $@ --no-check-certificate http://github.com/unicode-org/icu/releases/download/release-$(ICU_VER1)/icu4c-$(ICU_VER2)-src.tgz && touch $@
