SRC+=src/libedit-$(LIBEDIT_VER).tar.gz
PKG+=pkg/libedit.cpio.zst
libedit: pkg/libedit.cpio.zst
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBEDIT_OPT+= --prefix=/usr
LIBEDIT_OPT+= --disable-static
LIBEDIT_OPT+= --disable-examples
LIBEDIT_OPT+= $(OPT_FLAGS)
pkg/libedit.cpio.zst: src/libedit-$(LIBEDIT_VER).tar.gz pkg/gzip.cpio.zst pkg/ncurses.cpio.zst pkg/file.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libedit
	mkdir -p tmp/libedit/bld
	tar -xzf $< -C tmp/libedit
	cd tmp/libedit/bld && ../libedit-$(LIBEDIT_VER)/configure $(LIBEDIT_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libedit/ins/usr/share
	rm -f  tmp/libedit/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libedit/ins/usr/lib/*.so* || true
endif
	mkdir -p pkg && cd tmp/libedit/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libedit
src/libedit-$(LIBEDIT_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://www.thrysoee.dk/editline/libedit-$(LIBEDIT_VER).tar.gz && touch $@
