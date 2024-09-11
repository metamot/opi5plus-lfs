SRC+=src/cyrus-sasl-$(CYRUS_SASL_VER).tar.gz
SRC+=src/cyrus-sasl-$(CYRUS_SASL_VER)-doc_fixes-1.patch
PKG+=pkg/cyrus-sasl.cpio.zst
cyrus-sasl: pkg/cyrus-sasl.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
CYRUS_SASL_OPT+= $(OPT_FLAGS)
CYRUS_SASL_OPT+= --prefix=/usr
CYRUS_SASL_OPT+= --sysconfdir=/etc
CYRUS_SASL_OPT+= --enable-auth-sasldb 
CYRUS_SASL_OPT+= --with-dbpath=/var/lib/sasl/sasldb2
CYRUS_SASL_OPT+= --with-saslauthd=/var/run/saslauthd
CYRUS_SASL_OPT+= $(OPT_FLAGS)
pkg/cyrus-sasl.cpio.zst: src/cyrus-sasl-$(CYRUS_SASL_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/cyrus-sasl
	mkdir -p tmp/cyrus-sasl/bld
	tar -xzf $< -C tmp/cyrus-sasl
	cp -far src/cyrus-sasl-$(CYRUS_SASL_VER)-doc_fixes-1.patch tmp/sasl/
	cd tmp/cyrus-sasl/cyrus-sasl-$(CYRUS_SASL_VER) && patch -Np1 -i ../cyrus-sasl-$(CYRUS_SASL_VER)-doc_fixes-1.patch
	cd tmp/cyrus-sasl/bld && ../cyrus-sasl-$(CYRUS_SASL_VER)/configure $(CYRUS_SASL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/cyrus-sasl/ins/usr/lib/*.la
	rm -f tmp/cyrus-sasl/ins/usr/lib/sasl2/*.la
	rm -fr tmp/cyrus-sasl/ins/usr/share
	install -v -dm700 tmp/cyrus-sasl/ins/var/lib/sasl
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/cyrus-sasl/ins/usr/lib/*.so* || true
	strip $(STRIP_BUILD_LIB) tmp/cyrus-sasl/ins/usr/lib/sasl2/*.so* || true
	strip $(STRIP_BUILD_BIN) tmp/cyrus-sasl/ins/usr/sbin/* || true
endif
#	mkdir -p pkg && cd tmp/cyrus-sasl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/cyrus-sasl
src/cyrus-sasl-$(CYRUS_SASL_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-$(CYRUS_SASL_VER)/cyrus-sasl-$(CYRUS_SASL_VER).tar.gz && touch $@
# --no-check-certificate
src/cyrus-sasl-$(CYRUS_SASL_VER)-doc_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/cyrus-sasl-$(CYRUS_SASL_VER)-doc_fixes-1.patch
