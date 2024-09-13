SRC+=src/tar-$(TAR_VER).tar.xz
PKG+=pkg/tar.cpio.zst
tar: pkg/tar.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
TAR_OPT+= --prefix=/usr
TAR_OPT+= --disable-nls
TAR_OPT+= $(OPT_FLAGS)
pkg/tar.cpio.zst: src/tar-$(TAR_VER).tar.xz pkg/acl.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/tar
	mkdir -p tmp/tar/bld
	tar -xJf $< -C tmp/tar
	cd tmp/tar/bld && FORCE_UNSAFE_CONFIGURE=1 ../tar-$(TAR_VER)/configure $(TAR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tar/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/tar/ins/usr/libexec/rmt
	strip $(STRIP_BUILD_BIN) tmp/tar/ins/usr/bin/tar
endif
	mkdir -p pkg && cd tmp/tar/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tar
#	rm -fv /boot/zst/tar.cpio.zst
src/tar-$(TAR_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/tar/tar-$(TAR_VER).tar.xz && touch $@
