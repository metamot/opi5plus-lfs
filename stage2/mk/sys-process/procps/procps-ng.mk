SRC+=src/procps-ng-$(PROCPS_VER).tar.xz
PKG+=pkg/procps-ng.cpio.zst
procps-ng: pkg/procps-ng.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PROCPS_OPT+= --prefix=/usr
PROCPS_OPT+= --exec-prefix=
PROCPS_OPT+= --libdir=/usr/lib
PROCPS_OPT+= --docdir=/usr/share/doc/procps-ng-$(PROCPS_VER)
PROCPS_OPT+= --disable-static
PROCPS_OPT+= --disable-kill
PROCPS_OPT+= --with-systemd
PROCPS_OPT+= --disable-nls
PROCPS_OPT+= $(OPT_FLAGS)
pkg/procps-ng.cpio.zst: src/procps-ng-$(PROCPS_VER).tar.xz
	rm -fr tmp/procps-ng
	mkdir -p tmp/procps-ng/bld
	tar -xJf $< -C tmp/procps-ng
	cd tmp/procps-ng/bld && ../procps-ng-$(PROCPS_VER)/configure $(PROCPS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	mv -f tmp/procps-ng/ins/bin tmp/procps-ng/ins/usr/
	mv -f tmp/procps-ng/ins/sbin tmp/procps-ng/ins/usr/
	rm -fr tmp/procps-ng/ins/usr/share
	rm -f  tmp/procps-ng/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/procps-ng/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/procps-ng/ins/usr/sbin/* || true
	strip $(STRIP_BUILD_LIB) tmp/procps-ng/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/procps-ng/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/procps-ng
src/procps-ng-$(PROCPS_VER).tar.xz: src/.gitignore
	wget -P src https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-$(PROCPS_VER).tar.xz && touch $@
# --no-check-certificate

