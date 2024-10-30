SRC+=src/libcap-$(LIBCAP_VER).tar.xz
PKG+=pkg/libcap.cpio.zst
libcap: pkg/libcap.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/libcap.cpio.zst: src/libcap-$(LIBCAP_VER).tar.xz
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libcap
	mkdir -p tmp/libcap/ins/lib
	tar -xJf $< -C tmp/libcap
	sed -i '/install -m.*STACAPLIBNAME/d' tmp/libcap/libcap-$(LIBCAP_VER)/libcap/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/libcap/libcap-$(LIBCAP_VER)/Make.Rules
	cd tmp/libcap/libcap-$(LIBCAP_VER) && make $(JOBS) V=$(VERB) CC=gcc lib=lib && make CC=gcc lib=lib DESTDIR=`pwd`/../ins PKGCONFIGDIR=/usr/lib/pkgconfig install
	mv -f tmp/libcap/ins/lib/* tmp/libcap/ins/usr/lib/
	rm -fr tmp/libcap/ins/lib
	rm -fr tmp/libcap/ins/usr/share
	chmod 755 tmp/libcap/ins/usr/lib/libcap.so.$(LIBCAP_VER)
	mv -f tmp/libcap/ins/sbin tmp/libcap/ins/usr/
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_AST) tmp/libcap/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/libcap/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/libcap/ins/usr/sbin/*
endif
	mkdir -p pkg && cd tmp/libcap/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libcap
src/libcap-$(LIBCAP_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(LIBCAP_VER).tar.xz && touch $@
