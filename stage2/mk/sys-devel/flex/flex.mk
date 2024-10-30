SRC+= src/flex-$(FLEX_VER).tar.gz
PKG+= pkg/flex.cpio.zst
flex: pkg/flex.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
FLEX_OPT+= --prefix=/usr
FLEX_OPT+= --disable-nls
FLEX_OPT+= $(OPT_FLAGS)
pkg/flex.cpio.zst: src/flex-$(FLEX_VER).tar.gz pkg/gzip.cpio.zst pkg/m4.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/flex
	mkdir -p tmp/flex/bld
	tar -xzf $< -C tmp/flex
	cd tmp/flex/bld && ../flex-$(FLEX_VER)/configure $(FLEX_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/flex/ins/usr/share
	rm -f tmp/flex/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/flex/ins/usr/bin/flex
	strip $(STRIP_BUILD_AST) tmp/flex/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/flex/ins/usr/lib/*.so*
endif
	cd tmp/flex/ins/usr/bin && ln -sf flex lex
	mkdir -p pkg && cd tmp/flex/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/flex
src/flex-$(FLEX_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://github.com/westes/flex/releases/download/v$(FLEX_VER)/flex-$(FLEX_VER).tar.gz && touch $@
