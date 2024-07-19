SRC+=src/libatomic_ops-$(LIBATOMIC_OPS_VER).tar.gz
PKG+=pkg/libatomic_ops.cpio.zst
libatomic_ops: pkg/libatomic_ops.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBATOMIC_OPS_OPT+= --prefix=/usr
LIBATOMIC_OPS_OPT+= --enable-shared
LIBATOMIC_OPS_OPT+= --disable-static
#LIBATOMIC_OPS_OPT+= --docdir=/usr/share/doc/libatomic_ops-$(LIBATOMIC_OPS_VER)
LIBATOMIC_OPS_OPT+= --disable-docs
LIBATOMIC_OPS_OPT+= $(OPT_FLAGS)
pkg/libatomic_ops.cpio.zst: src/libatomic_ops-$(LIBATOMIC_OPS_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libatomic_ops
	mkdir -p tmp/libatomic_ops/bld
	tar -xJf $< -C tmp/libatomic_ops
	cd tmp/libatomic_ops/bld && ../libatomic_ops-$(LIBATOMIC_OPS_VER)/configure $(LIBATOMIC_OPS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/gmp/ins/usr/share
#	rm -f tmp/gmp/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/gmp/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/gmp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/gmp
src/libatomic_ops-$(LIBATOMIC_OPS_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/ivmai/libatomic_ops/releases/download/v7.8.2/libatomic_ops-$(LIBATOMIC_OPS_VER).tar.gz && touch $@
# --no-check-certificate

