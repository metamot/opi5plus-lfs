SRC+=src/libmnl-$(LIBMNL_VER).tar.bz2
PKG+=pkg/libmnl.cpio.zst
libmnl: pkg/libmnl.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBMNL_OPT+= --prefix=/usr
LIBMNL_OPT+= $(OPT_FLAGS)
pkg/libmnl.cpio.zst: src/libmnl-$(LIBMNL_VER).tar.bz2 pkg/bzip2.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libmnl
	mkdir -p tmp/libmnl/bld
	tar -xjf $< -C tmp/libmnl
	cd tmp/libmnl/bld && ../libmnl-$(LIBMNL_VER)/configure $(LIBMNL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f  tmp/libmnl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libmnl/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libmnl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libmnl
src/libmnl-$(LIBMNL_VER).tar.bz2: src/.gitignore
	wget -P src https://netfilter.org/projects/libmnl/files/libmnl-$(LIBMNL_VER).tar.bz2 && touch $@
#--no-check-certificate

