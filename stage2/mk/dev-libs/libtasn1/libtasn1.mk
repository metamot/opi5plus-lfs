SRC+=src/libtasn1-$(LIBTASN1_VER).tar.gz
PKG+=pkg/libtasn1.cpio.zst
libtasn1: pkg/libtasn1.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBTASN1_OPT+= --prefix=/usr
LIBTASN1_OPT+= --disable-static
LIBTASN1_OPT+= $(OPT_FLAGS)
pkg/libtasn1.cpio.zst: src/libtasn1-$(LIBTASN1_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libtasn1
	mkdir -p tmp/libtasn1/bld
	tar -xzf $< -C tmp/libtasn1
	cd tmp/libtasn1/bld && ../libtasn1-$(LIBTASN1_VER)/configure $(LIBTASN1_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/libtasn1/ins/usr/share
#	rm -f tmp/libtasn1/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/libtasn1/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/libtasn1/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/libtasn1
src/libtasn1-$(LIBTASN1_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libtasn1/libtasn1-$(LIBTASN1_VER).tar.gz && touch $@
# --no-check-certificate

