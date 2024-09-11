SRC+=src/libunwind-$(LIBUNWIND_VER).tar.gz
PKG+=pkg/libunwind.cpio.zst
libunwind: pkg/libunwind.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBUNWIND_OPT+= --prefix=/usr
LIBUNWIND_OPT+= --disable-static
LIBUNWIND_OPT+= --disable-documentation
# ^^^ latex2man(texlive). Don't care! Configure still produce: WARNING: latex2man not found.
LIBUNWIND_OPT+= $(OPT_FLAGS)
pkg/libunwind.cpio.zst: src/libunwind-$(LIBUNWIND_VER).tar.gz pkg/gzip.cpio.zst pkg/zlib.cpio.zst pkg/xz-utils.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libunwind
	mkdir -p tmp/libunwind/bld
	tar -xzf $< -C tmp/libunwind
	cd tmp/libunwind/bld && ../libunwind-$(LIBUNWIND_VER)/configure $(LIBUNWIND_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libunwind/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libunwind/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libunwind/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libunwind
src/libunwind-$(LIBUNWIND_VER).tar.gz: src/.gitignore
	wget --no-check-certificate -P src https://download.savannah.nongnu.org/releases/libunwind/libunwind-$(LIBUNWIND_VER).tar.gz && touch $@
