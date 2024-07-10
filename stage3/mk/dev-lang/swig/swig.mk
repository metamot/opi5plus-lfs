SRC+=src/swig-$(SWIG_VER).tar.gz
PKG+=pkg/swig.cpio.zst
swig: pkg/swig.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
SWIG_OPT+= --prefix=/usr
SWIG_OPT+= --without-maximum-compile-warnings
SWIG_OPT+= $(OPT_FLAGS)
pkg/swig.cpio.zst: src/swig-$(SWIG_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/swig
	mkdir -p tmp/swig/bld
	tar -xzf $< -C tmp/swig
	cd tmp/swig/bld && ../swig-$(SWIG_VER)/configure $(SWIG_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/swig/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/swig/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/swig
src/swig-$(SWIG_VER).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/swig/swig-$(SWIG_VER).tar.gz && touch $@
# --no-check-certificate

