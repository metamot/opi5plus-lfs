SRC+=src/openldap-$(OPENLDAP_VER).tgz
SRC+=src/openldap-$(OPENLDAP_VER)-consolidated-2.patch
PKG+=pkg/openldap.cpio.zst
openldap: pkg/openldap.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
OPENLDAP_OPT+= --prefix=/usr
OPENLDAP_OPT+= --sysconfdir=/etc
OPENLDAP_OPT+= --localstatedir=/var
OPENLDAP_OPT+= --libexecdir=/usr/lib
OPENLDAP_OPT+= --disable-static
OPENLDAP_OPT+= --disable-debug
OPENLDAP_OPT+= --with-tls=openssl
OPENLDAP_OPT+= --with-cyrus-sasl
OPENLDAP_OPT+= --enable-dynamic
OPENLDAP_OPT+= --enable-crypt
OPENLDAP_OPT+= --enable-spasswd
OPENLDAP_OPT+= --enable-slapd
OPENLDAP_OPT+= --enable-modules
OPENLDAP_OPT+= --enable-rlookups
OPENLDAP_OPT+= --enable-backends=mod
OPENLDAP_OPT+= --disable-ndb
OPENLDAP_OPT+= --disable-sql
OPENLDAP_OPT+= --disable-shell
OPENLDAP_OPT+= --disable-bdb
OPENLDAP_OPT+= --disable-hdb
OPENLDAP_OPT+= --enable-overlays=mod
OPENLDAP_OPT+= $(OPT_FLAGS)
pkg/openldap.cpio.zst: src/openldap-$(OPENLDAP_VER).tgz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	groupadd -g 83 ldap && useradd  -c "OpenLDAP Daemon Owner" -d /var/lib/openldap -u 83 -g ldap -s /bin/false ldap
	rm -fr tmp/openldap
	mkdir -p tmp/openldap/bld
	tar -xzf $< -C tmp/openldap
	cp -far src/openldap-$(OPENLDAP_VER)-consolidated-2.patch tmp/openldap/
	cd tmp/openldap/openldap-$(OPENLDAP_VER) && patch -Np1 -i ../openldap-$(OPENLDAP_VER)-consolidated-2.patch
#	cd tmp/openldap/bld && ../openldap-$(OPENLDAP_VER)/configure $(OPENLDAP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/openldap/ins/usr/share
#	rm -f tmp/openldap/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/openldap/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/openldap/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/openldap
src/openldap-$(OPENLDAP_VER).tgz: src/.gitignore
	wget -P src ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$(OPENLDAP_VER).tgz && touch $@
# --no-check-certificate
src/openldap-$(OPENLDAP_VER)-consolidated-2.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/openldap-$(OPENLDAP_VER)-consolidated-2.patch



