SRC+=src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz
PKG+=pkg/dosfstools.cpio.zst
dosfstools: pkg/dosfstools.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DOSFSTOOLS_OPT+= --prefix=/usr
DOSFSTOOLS_OPT+= --enable-compat-symlinks
DOSFSTOOLS_OPT+= --mandir=/usr/share/man
DOSFSTOOLS_OPT+= --docdir=/usr/share/doc/dosfstools-$(DOS_FS_TOOLS_VER)
DOSFSTOOLS_OPT+= $(OPT_FLAGS)
pkg/dosfstools.cpio.zst: src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz
	rm -fr tmp/dosfstools
	mkdir -p tmp/dosfstools/bld
	tar -xJf $< -C tmp/dosfstools
	cd tmp/dosfstools/bld && ../dosfstools-$(DOS_FS_TOOLS_VER)/configure $(DOSFSTOOLS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/dosfstools/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/dosfstools/ins/usr/sbin/* || true
endif
	mkdir -p pkg && cd tmp/dosfstools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/dosfstools
src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/dosfstools/dosfstools/releases/download/v$(DOS_FS_TOOLS_VER)/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz && touch $@
#--no-check-certificate

