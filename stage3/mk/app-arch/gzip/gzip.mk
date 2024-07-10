SRC+=src/gzip-$(GZIP_VER).tar.xz
PKG+=pkg/gzip.cpio.zst
gzip: pkg/gzip.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GZIP_OPT+= --prefix=/usr
GZIP_OPT+= $(OPT_FLAGS)
pkg/gzip.cpio.zst: src/gzip-$(GZIP_VER).tar.xz
	rm -fr tmp/gzip
	mkdir -p tmp/gzip/bld
	tar -xJf $< -C tmp/gzip
	cd tmp/gzip/bld && ../gzip-$(GZIP_VER)/configure $(GZIP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gzip/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/gzip/ins/usr/bin/* || true
endif
	mkdir -p pkg &&cd tmp/gzip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gzip
src/gzip-$(GZIP_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VER).tar.xz && touch $@
# --no-check-certificate
