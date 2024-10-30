SRC+=src/libidn-$(LIBIDN_VER).tar.gz
PKG+=pkg/libidn.cpio.zst
libidn: pkg/libidn.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBIDN_OPT+= --prefix=/usr
LIBIDN_OPT+= --disable-static
LIBIDN_OPT+= --disable-nls
LIBIDN_OPT+= $(OPT_FLAGS)
pkg/libidn.cpio.zst: src/libidn-$(LIBIDN_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libidn
	mkdir -p tmp/libidn/bld
	tar -xzf $< -C tmp/libidn
	cd tmp/libidn/bld && ../libidn-$(LIBIDN_VER)/configure $(LIBIDN_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/libidn/ins/usr/share
#	rm -f tmp/libidn/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/libidn/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/libidn/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/libidn
src/libidn-$(LIBIDN_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libidn/libidn-$(LIBIDN_VER).tar.gz && touch $@
# --no-check-certificate
