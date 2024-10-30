SRC+=src/wget2-v$(WGET2_VER).tar.bz2
PKG+=pkg/wget2.cpio.zst
wget2: pkg/wget2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
WGET2_OPT+= --prefix=/usr
WGET2_OPT+= $(OPT_FLAGS)
pkg/wget2.cpio.zst: src/wget2-v$(WGET2_VER).tar.bz2 pkg/bzip2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/wget2
	mkdir -p tmp/wget2/bld
	tar -xjf $< -C tmp/wget2
	
#	cd tmp/inetutils/bld && ../inetutils-$(INET_UTILS_VER)/configure $(INETUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/inetutils/ins/usr/share
#	rm -fr tmp/inetutils/ins/usr/libexec
# libexec is empty
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_BIN) tmp/inetutils/ins/usr/bin/* || true
#endif
#	mkdir -p pkg && cd tmp/inetutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/inetutils
src/inetutils-$(INET_UTILS_VER).tar.xz: src/.gitignore
	wget -P src https://gitlab.com/gnuwget/wget2/-/archive/v$(WGET2_VER)/wget2-v$(WGET2_VER).tar.bz2 && touch $@
#--no-check-certificate

