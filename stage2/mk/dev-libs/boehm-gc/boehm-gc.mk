SRC+=src/gc-$(BOEHM_GC_VER).tar.gz
PKG+=pkg/boehm-gc.cpio.zst
boehm-gc: pkg/boehm-gc.cpio.zst
	cat pkg/libatomic_ops.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BOEHM_GC_OPT+= --prefix=/usr
BOEHM_GC_OPT+= --enable-cplusplus
BOEHM_GC_OPT+= --disable-gc-debug
BOEHM_GC_OPT+= --disable-docs
BOEHM_GC_OPT+= --with-libatomic-ops=yes
BOEHM_GC_OPT+= $(OPT_FLAGS)
pkg/boehm-gc.cpio.zst: src/gc-$(BOEHM_GC_VER).tar.gz pkg/gzip.cpio.zst pkg/libatomic_ops.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libatomic_ops.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/boehm_gc
	mkdir -p tmp/boehm_gc/bld
	tar -xzf $< -C tmp/boehm_gc
	cd tmp/boehm_gc/bld && ../gc-$(BOEHM_GC_VER)/configure $(BOEHM_GC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/boehm_gc/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/boehm_gc/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/boehm_gc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/boehm_gc
src/gc-$(BOEHM_GC_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://www.hboehm.info/gc/gc_source/gc-$(BOEHM_GC_VER).tar.gz && touch $@
