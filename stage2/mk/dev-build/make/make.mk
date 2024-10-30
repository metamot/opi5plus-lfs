SRC+=src/make-$(MAKE_VER).tar.gz
PKG+=pkg/make.cpio.zst
make: pkg/make.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
MAKE_OPT+= --prefix=/usr
MAKE_OPT+= --disable-nls
MAKE_OPT+= $(OPT_FLAGS)
pkg/make.cpio.zst: src/make-$(MAKE_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/make
	mkdir -p tmp/make/bld
	tar -xzf $< -C tmp/make
	cd tmp/make/bld && ../make-$(MAKE_VER)/configure $(MAKE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/make/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/make/ins/usr/bin/make
endif
	mkdir -p pkg && cd tmp/make/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/make
src/make-$(MAKE_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/make/make-$(MAKE_VER).tar.gz && touch $@
