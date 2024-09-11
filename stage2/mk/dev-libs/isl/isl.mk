# https://libisl.sourceforge.io
SRC+=src/isl-$(ISL_VER).tar.xz
PKG+=pkg/isl.cpio.zst
isl: pkg/isl.cpio.zst
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ISL_OPT+= --prefix=/usr
ISL_OPT+= --disable-static
ISL_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg/isl.cpio.zst: src/isl-$(ISL_VER).tar.xz pkg/gmp.cpio.zst
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/isl
	mkdir -p tmp/isl/bld
	tar -xJf $< -C tmp/isl
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/isl/isl-$(ISL_VER)/configure
	cd tmp/isl/bld && ../isl-$(ISL_VER)/configure $(ISL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/isl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/isl/ins/usr/lib/*.so* || true
endif
	mkdir -p pkg && cd tmp/isl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/isl
src/isl-$(ISL_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://libisl.sourceforge.io/isl-$(ISL_VER).tar.xz && touch $@
