SRC+=src/dbus-$(DBUS_VER).tar.gz
PKG+=pkg/dbus.cpio.zst
dbus: pkg/dbus.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DBUS_OPT+= --prefix=/usr
DBUS_OPT+= --sysconfdir=/etc
DBUS_OPT+= --localstatedir=/var
DBUS_OPT+= --disable-static
DBUS_OPT+= --disable-doxygen-docs
DBUS_OPT+= --disable-xml-docs
DBUS_OPT+= --docdir=/usr/share/doc/dbus-$(DBUS_VER)
DBUS_OPT+= --with-console-auth-dir=/run/console
DBUS_OPT+= $(OPT_FLAGS)
pkg/dbus.cpio.zst: src/dbus-$(DBUS_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/dbus
	mkdir -p tmp/dbus/bld
	tar -xzf $< -C tmp/dbus
	cd tmp/dbus/bld && ../dbus-$(DBUS_VER)/configure $(DBUS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/dbus/ins/lib/* tmp/dbus/ins/usr/lib/
	rm -fr tmp/dbus/ins/lib
	rm -fr tmp/dbus/ins/usr/share/doc
	rm -f  tmp/dbus/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	cd tmp/dbus/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	sed -i 's:/var/run:/run:' tmp/dbus/ins/usr/lib/systemd/system/dbus.socket
	mv -f tmp/dbus/ins/var/run tmp/dbus/ins/
	cd tmp/dbus/ins/var/lib/dbus && ln -sf /etc/machine-id machine-id
	mkdir -p pkg && cd tmp/dbus/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/dbus
src/dbus-$(DBUS_VER).tar.gz: src/.gitignore
	wget -P src https://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS_VER).tar.gz && touch $@
#--no-check-certificate

