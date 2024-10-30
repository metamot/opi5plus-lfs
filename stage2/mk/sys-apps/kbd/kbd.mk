SRC+=src/kbd-$(KBD_VER).tar.xz
SRC+=src/kbd-$(KBD_VER)-backspace-1.patch
PKG+=pkg/kbd.cpio.zst
kbd: pkg/kbd.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
KBD_OPT+= --prefix=/usr
KBD_OPT+= --disable-vlock
KBD_OPT+= --disable-nls
KBD_OPT+= CFLAGS="$(RK3588_FLAGS)"
pkg/kbd.cpio.zst: src/kbd-$(KBD_VER).tar.xz src/kbd-$(KBD_VER)-backspace-1.patch
	rm -fr tmp/kbd
	mkdir -p tmp/kbd/bld
	tar -xJf $< -C tmp/kbd
	cp -f pkg/kbd-$(KBD_VER)-backspace-1.patch tmp/kbd/
	cd tmp/kbd/kbd-$(KBD_VER) && patch -Np1 -i ../kbd-$(KBD_VER)-backspace-1.patch
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' tmp/kbd/kbd-$(KBD_VER)/configure
	sed -i 's/resizecons.8 //' tmp/kbd/kbd-$(KBD_VER)/docs/man/man8/Makefile.in
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/m4/libtool.m4
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure.ac
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure
	cd tmp/kbd/bld && ../kbd-$(KBD_VER)/configure $(KBD_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
# warning: remember to run 'libtool --finish /usr/lib'
# This's because DESTDIR install. It's not a problem.
	rm -fr tmp/kbd/ins/usr/share/man
	rm -fr tmp/kbd/ins/usr/lib
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/kbd/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/kbd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/kbd
src/kbd-$(KBD_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/kbd/kbd-$(KBD_VER).tar.xz && touch $@
#--no-check-certificate
src/kbd-$(KBD_VER)-backspace-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/kbd-$(KBD_VER)-backspace-1.patch && touch $@

