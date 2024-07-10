SRC+=src/openssl-$(OPEN_SSL_VER).tar.gz
PKG+=pkg/openssl.cpio.zst
openssl: pkg/openssl.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
OPENSSL_OPT+= --prefix=/usr
OPENSSL_OPT+= --openssldir=/etc/ssl
OPENSSL_OPT+= --libdir=lib
OPENSSL_OPT+= shared
#OPENSSL_OPT+= zlib-dynamic
OPENSSL_OPT+= zlib
OPENSSL_OPT+= $(OPT_FLAGS)
pkg/openssl.cpio.zst: src/openssl-$(OPEN_SSL_VER).tar.gz pkg/gzip.cpio.zst pkg/zlib.cpio.zst pkg/grep.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst pkg/perl.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/openssl
	mkdir -p tmp/openssl/bld
	tar -xzf $< -C tmp/openssl
	cd tmp/openssl/bld && ../openssl-$(OPEN_SSL_VER)/config $(OPENSSL_OPT) && make $(JOBS) V=$(VERB)
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' tmp/openssl/bld/Makefile
	cd tmp/openssl/bld && make MANSUFFIX=ssl DESTDIR=`pwd`/../ins install
	rm -fr tmp/openssl/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/openssl/ins/usr/bin/openssl
	strip $(STRIP_BUILD_AST) tmp/openssl/ins/usr/lib/*.a || true
	cd tmp/openssl/ins/usr/lib && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p pkg && cd tmp/openssl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/openssl
src/openssl-$(OPEN_SSL_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://www.openssl.org/source/openssl-$(OPEN_SSL_VER).tar.gz && touch $@
