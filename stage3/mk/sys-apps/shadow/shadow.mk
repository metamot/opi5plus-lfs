SRC+=src/shadow-$(SHADOW_VER).tar.xz
PKG+=pkg/shadow.cpio.zst
shadow: pkg/shadow.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
SHADOW_OPT+= --sysconfdir=/etc
SHADOW_OPT+= --with-group-name-max-length=32
#SHADOW_OPT+= --with-libcrack
SHADOW_OPT+= --disable-nls
SHADOW_OPT+= $(OPT_FLAGS)
pkg/shadow.cpio.zst: src/shadow-$(SHADOW_VER).tar.xz
	rm -fr tmp/shadow
	mkdir -p tmp/shadow/bld
	tar -xJf pkg/shadow-$(SHADOW_VER).tar.xz -C tmp/shadow
	sed -i 's|groups$$(EXEEXT) ||' tmp/shadow/shadow-$(SHADOW_VER)/src/Makefile.in
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	sed -i 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's:/var/spool/mail:/var/mail:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's/1000/999/' tmp/shadow/shadow-$(SHADOW_VER)/etc/useradd
	touch /usr/bin/passwd
	cd tmp/shadow/bld && ../shadow-$(SHADOW_VER)/configure $(SHADOW_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/shadow/ins/usr/share
	mv -f tmp/shadow/ins/bin/* tmp/shadow/ins/usr/bin/
	rm -fr tmp/shadow/ins/bin
	mv -f  tmp/shadow/ins/sbin/* tmp/shadow/ins/usr/sbin/
	rm -fr tmp/shadow/ins/sbin
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/shadow/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/shadow/ins/usr/sbin/* || true
endif
#	pwconv
#	grpconv
#	passwd -d root
#	mkdir -p pkg && cd tmp/shadow/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/shadow
src/shadow-$(SHADOW_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/shadow-maint/shadow/releases/download/$(SHADOW_VER)/shadow-$(SHADOW_VER).tar.xz && touch $@
#--no-check-certificate


