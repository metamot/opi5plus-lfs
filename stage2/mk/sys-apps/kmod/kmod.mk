SRC+=src/kmod-$(KMOD_VER).tar.xz
PKG+=pkg/kmod.cpio.zst
kmod: pkg/kmod.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
KMOD_OPT+= --prefix=/usr
#KMOD_OPT+= --bindir=/bin
KMOD_OPT+= --sysconfdir=/etc
KMOD_OPT+= --with-rootlibdir=/usr/lib
KMOD_OPT+= --with-xz
KMOD_OPT+= --with-zlib
KMOD_OPT+= $(OPT_FLAGS)
pkg/kmod.cpio.zst: src/kmod-$(KMOD_VER).tar.xz
	rm -fr tmp/kmod
	mkdir -p tmp/kmod/bld
	tar -xJf $< -C tmp/kmod
	cd tmp/kmod/bld && ../kmod-$(KMOD_VER)/configure $(KMOD_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/kmod/ins/usr/share/man
	rm -f  tmp/kmod/ins/usr/lib/*.la
	mkdir -p tmp/kmod/ins/usr/sbin
	cd tmp/kmod/ins/usr/sbin && ln -sf ../bin/kmod depmod && ln -sf ../bin/kmod insmod && ln -sf ../bin/kmod lsmod && ln -sf ../bin/kmod modinfo && ln -sf ../bin/kmod modprobe && ln -sf ../bin/kmod rmmod
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/kmod/ins/usr/bin/kmod
	strip $(STRIP_BUILD_LIB) tmp/kmod/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/kmod/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/kmod
src/kmod-$(KMOD_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$(KMOD_VER).tar.xz && touch $@
#--no-check-certificate
