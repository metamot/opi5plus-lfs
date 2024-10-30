SRC+=src/systemd-$(SYSTEMD_VER).tar.gz
PKG+=pkg/systemd.cpio.zst
systemd: pkg/systemd.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
SYSTEMD_MOPT+= --prefix=/usr
SYSTEMD_MOPT+= --sysconfdir=/etc
SYSTEMD_MOPT+= --localstatedir=/var
SYSTEMD_MOPT+= -Dblkid=true
#SYSTEMD_MOPT+= -Dbuildtype=release
SYSTEMD_MOPT+= -Ddebug=false
SYSTEMD_MOPT+= -Doptimization=$(BASE_OPT_VAL)
SYSTEMD_MOPT+= -Dc_args="$(RK3588_FLAGS)"
SYSTEMD_MOPT+= -Dcpp_args="$(RK3588_FLAGS)"
SYSTEMD_MOPT+= -Ddefault-dnssec=no
SYSTEMD_MOPT+= -Dfirstboot=false
SYSTEMD_MOPT+= -Dinstall-tests=false
SYSTEMD_MOPT+= -Dkmod-path=/usr/bin/kmod
SYSTEMD_MOPT+= -Dmount-path=/usr/bin/mount
SYSTEMD_MOPT+= -Dumount-path=/usr/bin/umount
SYSTEMD_MOPT+= -Dsulogin-path=/usr/sbin/sulogin
SYSTEMD_MOPT+= -Drootlibdir=/usr/lib
SYSTEMD_MOPT+= -Dldconfig=false
SYSTEMD_MOPT+= -Drootprefix=
SYSTEMD_MOPT+= -Dsplit-usr=true
SYSTEMD_MOPT+= -Dsysusers=false
SYSTEMD_MOPT+= -Db_lto=false
SYSTEMD_MOPT+= -Drpmmacrosdir=no
SYSTEMD_MOPT+= -Dhomed=false
SYSTEMD_MOPT+= -Duserdb=false
SYSTEMD_MOPT+= -Ddocdir=/usr/share/doc/systemd-$(SYSTEMD_VER)
SYSTEMD_MOPT+= -Dman=false
SYSTEMD_BUILD_VERB=
ifeq ($(VERB),1)
SYSTEMD_BUILD_VERB=-v
endif
pkg/systemd.cpio.zst: src/systemd-$(SYSTEMD_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/systemd
	mkdir -p tmp/systemd/bld
	tar -xzf $< -C tmp/systemd
	ln -sf /bin/true /usr/bin/xsltproc
	sed -i '177,$$ d' tmp/systemd/systemd-$(SYSTEMD_VER)/src/resolve/meson.build
	sed -i 's/GROUP="render", //' tmp/systemd/systemd-$(SYSTEMD_VER)/rules.d/50-udev-default.rules.in
	cd tmp/systemd/bld && LANG=en_US.UTF-8 meson $(SYSTEMD_MOPT) ../systemd-$(SYSTEMD_VER)/
	cd tmp/systemd/bld && LANG=en_US.UTF-8 ninja $(SYSTEMD_BUILD_VERB)
	cd tmp/systemd/bld && LANG=en_US.UTF-8 DESTDIR=`pwd`/../ins ninja install
	mv -fv tmp/systemd/ins/bin/* tmp/systemd/ins/usr/bin/
	rm -fr tmp/systemd/ins/bin
	mkdir -p tmp/systemd/ins/usr/sbin
	mv -fv tmp/systemd/ins/sbin/* tmp/systemd/ins/usr/sbin/
	rm -fr tmp/systemd/ins/sbin
	cd tmp/systemd/ins/usr/sbin && ln -fs ../bin/resolvectl resolvconf
	cp -far tmp/systemd/ins/lib/* tmp/systemd/ins/usr/lib/
	rm -fr tmp/systemd/ins/lib
	rm -f  tmp/systemd/ins/var/log/README
	rm -f  tmp/systemd/ins/etc/init.d/README
	rm -fr tmp/systemd/ins/usr/share/doc
	rm -fr tmp/systemd/ins/usr/share/locale
ifeq ($(BUILD_STRIP),y)
	cd tmp/systemd/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
#	mkdir -p pkg && cd tmp/systemd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	pv $@ | zstd -d | cpio -iduH newc -D /
#	rm -fr tmp/systemd
#	touch /etc/environment
#	rm -fv /usr/bin/xsltproc
#	systemd-machine-id-setup
#	systemctl preset-all
#	systemctl disable systemd-time-wait-sync.service
#	rm -fv /usr/lib/sysctl.d/50-pid-max.conf 
src/systemd-$(SYSTEMD_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/systemd/systemd/archive/v$(SYSTEMD_VER)/systemd-$(SYSTEMD_VER).tar.gz && touch $@
#--no-check-certificate


