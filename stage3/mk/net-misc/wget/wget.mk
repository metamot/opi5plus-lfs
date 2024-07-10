SRC+=src/wget-$(WGET_VER).tar.gz
PKG+=pkg/wget.cpio.zst
wget: pkg/wget.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
WGET_OPT+= --prefix=/usr
WGET_OPT+= --sysconfdir=/etc
WGET_OPT+= --with-ssl=openssl
WGET_OPT+= --disable-nls
WGET_OPT+= $(OPT_FLAGS)
pkg/wget.cpio.zst: src/wget-$(WGET_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/wget
	mkdir -p tmp/wget/bld
	tar -xzf $< -C tmp/wget
	cd tmp/wget/bld && ../wget-$(WGET_VER)/configure $(WGET_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/wget/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/wget/ins/usr/bin/wget
endif
#	mkdir -p pkg && cd tmp/wget/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/wget
src/wget-$(WGET_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/wget/wget-$(WGET_VER).tar.gz && touch $@
