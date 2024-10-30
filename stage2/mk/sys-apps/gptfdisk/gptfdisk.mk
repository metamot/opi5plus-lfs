SRC+=src/gptfdisk-$(GPTFDISK_VER).tar.gz
SRC+=src/gptfdisk-$(GPTFDISK_VER)-convenience-1.patch
PKG+=pkg/gptfdisk.cpio.zst
gptfdisk: pkg/gptfdisk.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/gptfdisk.cpio.zst: src/gptfdisk-$(GPTFDISK_VER).tar.gz src/gptfdisk-$(GPTFDISK_VER)-convenience-1.patch pkg/gzip.cpio.zst pkg/popt.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/popt.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gptfdisk
	mkdir -p tmp/gptfdisk/bld
	tar -xzf $< -C tmp/gptfdisk

#patch -Np1 -i ../gptfdisk-1.0.5-convenience-1.patch &&
#sed -i 's|ncursesw/||' gptcurses.cc &&
#make	

#	cd tmp/attr/bld && ../attr-$(ATTR_VER)/configure $(ATTR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/attr/ins/usr/share
#	rm -f tmp/attr/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/attr/ins/usr/lib/*.so*
#	strip $(STRIP_BUILD_BIN) tmp/attr/ins/usr/bin/* || true
#endif
#	mkdir -p pkg && cd tmp/attr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/attr
src/gptfdisk-$(GPTFDISK_VER).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/gptfdisk/gptfdisk-$(GPTFDISK_VER).tar.gz && touch $@
#--no-check-certificate
src/gptfdisk-$(GPTFDISK_VER)-convenience-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/gptfdisk-$(GPTFDISK_VER)-convenience-1.patch && touch $@

