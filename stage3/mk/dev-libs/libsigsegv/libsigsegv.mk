SRC+=src/libsigsegv-$(LIBSIGSEGV_VER).tar.gz
PKG+=pkg/libsigsegv.cpio.zst
libsigsegv: pkg/libsigsegv.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBSIGSEGV_OPT+= --prefix=/usr
LIBSIGSEGV_OPT+= --enable-shared
LIBSIGSEGV_OPT+= --disable-static
LIBSIGSEGV_OPT+= $(OPT_FLAGS)
pkg/libsigsegv.cpio.zst: src/libsigsegv-$(LIBSIGSEGV_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libsigsegv
	mkdir -p tmp/libsigsegv/bld
	tar -xzf $< -C tmp/libsigsegv
	cd tmp/libsigsegv/bld && ../libsigsegv-$(LIBSIGSEGV_VER)/configure $(LIBSIGSEGV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libsigsegv/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libsigsegv/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libsigsegv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libsigsegv
src/libsigsegv-$(LIBSIGSEGV_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/libsigsegv/libsigsegv-$(LIBSIGSEGV_VER).tar.gz && touch $@
