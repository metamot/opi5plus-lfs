SRC+=src/util-linux-$(UTIL_LINUX_VER).tar.xz
PKG+=pkg/util-linux.cpio.zst
util-linux: pkg/util-linux.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
UTIL_LINUX_OPT+= ADJTIME_PATH=/var/lib/hwclock/adjtime
UTIL_LINUX_OPT+= --docdir=/usr/share/doc/util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_OPT+= --disable-chfn-chsh
UTIL_LINUX_OPT+= --disable-login
UTIL_LINUX_OPT+= --disable-nologin
UTIL_LINUX_OPT+= --disable-su
UTIL_LINUX_OPT+= --disable-setpriv
UTIL_LINUX_OPT+= --disable-runuser
UTIL_LINUX_OPT+= --disable-pylibmount
UTIL_LINUX_OPT+= --disable-static
UTIL_LINUX_OPT+= --without-python
UTIL_LINUX_OPT+= --disable-nls
UTIL_LINUX_OPT+= $(OPT_FLAGS)
pkg/util-linux.cpio.zst: src/util-linux-$(UTIL_LINUX_VER).tar.xz
	rm -fr tmp/util-linux
	mkdir -p tmp/util-linux/bld
	tar -xJf $< -C tmp/util-linux
	mkdir -pv /var/lib/hwclock
	cd tmp/util-linux/bld && ../util-linux-$(UTIL_LINUX_VER)/configure $(UTIL_LINUX_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/util-linux/ins/bin/* tmp/util-linux/ins/usr/bin/
	cp -far tmp/util-linux/ins/sbin/* tmp/util-linux/ins/usr/sbin/
	cp -far tmp/util-linux/ins/lib/* tmp/util-linux/ins/usr/lib/
	rm -fr tmp/util-linux/ins/bin
	rm -fr tmp/util-linux/ins/lib
	rm -fr tmp/util-linux/ins/sbin
	rm -fr tmp/util-linux/ins/usr/share/doc
	rm -fr tmp/util-linux/ins/usr/share/man
	rm -f  tmp/util-linux/ins/usr/lib/*.la
	cd tmp/util-linux/ins/usr/lib && ln -sfv libblkid.so.1.1.0 libblkid.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libfdisk.so.1.1.0 libfdisk.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libmount.so.1.1.0 libmount.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libsmartcols.so.1.1.0 libsmartcols.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libuuid.so.1.3.0 libuuid.so
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/util-linux/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/util-linux/ins/usr/sbin/* || true
	strip $(STRIP_BUILD_LIB) tmp/util-linux/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/util-linux/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/util-linux
src/util-linux-$(UTIL_LINUX_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_VER)/util-linux-$(UTIL_LINUX_VER).tar.xz && touch $@
#--no-check-certificate

