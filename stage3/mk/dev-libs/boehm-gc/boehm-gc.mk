SRC+=src/gc-$(BOEHM_GC_VER).tar.gz
PKG+=pkg/boehm_gc.cpio.zst
boehm_gc: pkg/boehm_gc.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BOEHM_GC_OPT+= --prefix=/usr
BOEHM_GC_OPT+= $(OPT_FLAGS)
pkg/boehm_gc.cpio.zst: src/gc-$(BOEHM_GC_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/boehm_gc
	mkdir -p tmp/boehm_gc/bld
	tar -xJf $< -C tmp/boehm_gc
	cd tmp/boehm_gc/bld && ../gc-$(BOEHM_GC_VER)/configure $(BOEHM_GC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/gmp/ins/usr/share
#	rm -f tmp/gmp/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/gmp/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/gmp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/gmp
src/gc-$(BOEHM_GC_VER).tar.gz: src/.gitignore
	wget -P src https://www.hboehm.info/gc/gc_source/gc-$(BOEHM_GC_VER).tar.gz && touch $@
# --no-check-certificate

