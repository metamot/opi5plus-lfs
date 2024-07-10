SRC+=src/findutils-$(FIND_UTILS_VER).tar.xz
PKG+=pkg/findutils.cpio.zst
findutils: pkg/findutils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
FINDUTILS_OPT+= --prefix=/usr
FINDUTILS_OPT+= --localstatedir=/var/lib/locate
FINDUTILS_OPT+= --disable-nls
FINDUTILS_OPT+= $(OPT_FLAGS)
pkg/findutils.cpio.zst: src/findutils-$(FIND_UTILS_VER).tar.xz pkg/m4.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/findutils
	mkdir -p tmp/findutils/bld
	tar -xJf $< -C tmp/findutils
	cd tmp/findutils/bld && ../findutils-$(FIND_UTILS_VER)/configure $(FINDUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/findutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/findutils/ins/usr/libexec/frcode
	strip $(STRIP_BUILD_BIN) tmp/findutils/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/findutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/findutils
src/findutils-$(FIND_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/findutils/findutils-$(FIND_UTILS_VER).tar.xz && touch $@
#--no-check-certificate
