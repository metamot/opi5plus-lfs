SRC+=src/libffi-$(LIBFFI_VER).tar.gz
PKG+=pkg/libffi.cpio.zst
libffi: pkg/libffi.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBFFI_OPT+= --prefix=/usr
LIBFFI_OPT+= --disable-static
LIBFFI_OPT+= --libdir=/usr/lib
LIBFFI_OPT+= --disable-multi-os-directory
LIBFFI_OPT+= --with-gcc-arch=native
LIBFFI_OPT+= $(OPT_FLAGS)
pkg/libffi.cpio.zst: src/libffi-$(LIBFFI_VER).tar.gz pkg/gzip.cpio.zst pkg/grep.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libffi
	mkdir -p tmp/libffi/bld
	tar -xzf $< -C tmp/libffi
	cd tmp/libffi/bld && ../libffi-$(LIBFFI_VER)/configure $(LIBFFI_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libffi/ins/usr/share
	rm -f  tmp/libffi/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libffi/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libffi/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libffi
src/libffi-$(LIBFFI_VER).tar.gz: src/.gitignore
	wget -P src ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz && touch $@
#--no-check-certificate
