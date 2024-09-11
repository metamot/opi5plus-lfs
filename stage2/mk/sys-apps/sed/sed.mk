SRC+=src/sed-$(SED_VER).tar.xz
PKG+=pkg/sed.cpio.zst
sed: pkg/sed.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
SED_OPT+= --prefix=/usr
SED_OPT+= --disable-nls
SED_OPT+= --disable-i18n
SED_OPT+= $(OPT_FLAGS)
pkg/sed.cpio.zst: src/sed-$(SED_VER).tar.xz pkg/perl.cpio.zst pkg/attr.cpio.zst pkg/acl.cpio.zst
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/sed
	mkdir -p tmp/sed/bld
	tar -xJf $< -C tmp/sed
	cd tmp/sed/bld && ../sed-$(SED_VER)/configure $(SED_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/sed/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/sed/ins/usr/bin/sed
endif
	mkdir -p pkg && cd tmp/sed/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/sed
src/sed-$(SED_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/sed/sed-$(SED_VER).tar.xz && touch $@
