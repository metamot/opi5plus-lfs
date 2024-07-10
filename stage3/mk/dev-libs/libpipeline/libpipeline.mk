SRC+=src/libpipeline-$(LIBPIPILINE_VER).tar.gz
PKG+=pkg/libpipeline.cpio.zst
libpipeline: pkg/libpipeline.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBPIPILINE_OPT+= --prefix=/usr
LIBPIPILINE_OPT+= $(OPT_FLAGS)
pkg/libpipeline.cpio.zst: src/libpipeline-$(LIBPIPILINE_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libpipeline
	mkdir -p tmp/libpipeline/bld
	tar -xzf $< -C tmp/libpipeline
	cd tmp/libpipeline/bld && ../libpipeline-$(LIBPIPILINE_VER)/configure $(LIBPIPILINE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libpipeline/ins/usr/share
	rm -f  tmp/libpipeline/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libpipeline/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/libpipeline/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libpipeline
src/libpipeline-$(LIBPIPILINE_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/libpipeline/libpipeline-$(LIBPIPILINE_VER).tar.gz && touch $@
# --no-check-certificate

