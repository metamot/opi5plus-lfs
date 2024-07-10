SRC+=src/patch-$(PATCH_VER).tar.xz
PKG+=pkg/patch.cpio.zst
patch: pkg/patch.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PATCH_OPT+= --prefix=/usr
PATCH_OPT+= $(OPT_FLAGS)
pkg/patch.cpio.zst: src/patch-$(PATCH_VER).tar.xz pkg/attr.cpio.zst pkg/acl.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/patch
	mkdir -p tmp/patch/bld
	tar -xJf $< -C tmp/patch
	cd tmp/patch/bld && ../patch-$(PATCH_VER)/configure $(PATCH_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/patch/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/patch/ins/usr/bin/patch
endif
	mkdir -p pkg && cd tmp/patch/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/patch
src/patch-$(PATCH_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/patch/patch-$(PATCH_VER).tar.xz && touch $@
