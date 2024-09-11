SRC+=src/libidn2-$(LIBIDN2_VER).tar.gz
PKG+=pkg/libidn2.cpio.zst
libidn2: pkg/libidn2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBIDN2_OPT+= --prefix=/usr
LIBIDN2_OPT+= --disable-static
LIBIDN2_OPT+= --disable-nls
LIBIDN2_OPT+= $(OPT_FLAGS)
pkg/libidn2.cpio.zst: src/libidn2-$(LIBIDN2_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libidn2
	mkdir -p tmp/libidn2/bld
	tar -xzf $< -C tmp/libidn2
	cd tmp/libidn2/bld && ../libidn2-$(LIBIDN2_VER)/configure $(LIBIDN2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/libidn2/ins/usr/share
#	rm -f tmp/libidn2/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/libidn2/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/libidn2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/libidn2
src/libidn2-$(LIBIDN2_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libidn/libidn2-$(LIBIDN2_VER).tar.gz && touch $@
# --no-check-certificate

