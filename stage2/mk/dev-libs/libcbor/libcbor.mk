SRC+=src/libcbor-$(LIBCBOR_VER).zip
PKG+=pkg/libcbor.cpio.zst
libcbor: pkg/libcbor.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBCBOR_CMAKE+= -DCMAKE_BUILD_TYPE=Release
LIBCBOR_CMAKE+= -DCBOR_CUSTOM_ALLOC=ON
LIBCBOR_CMAKE+= -DCMAKE_C_FLAGS_RELEASE="$(BASE_OPT_FLAGS)"
LIBCBOR_CMAKE+= -DCMAKE_VERBOSE_MAKEFILE=true
LIBCBOR_CMAKE+= -DCMAKE_INSTALL_PREFIX=/usr
pkg/libcbor.cpio.zst: src/libcbor-$(LIBCBOR_VER).zip pkg/cmake.cpio.zst
	cat pkg/cmake.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/libcbor
	mkdir -p tmp/libcbor/bld
	bsdtar -xf $< -C tmp/libcbor
	sed -i "s|-O3||" tmp/libcbor/libcbor-$(LIBCBOR_VER)/CMakeLists.txt
	cd tmp/libcbor/bld && cmake $(LIBCBOR_CMAKE) ../libcbor-$(LIBCBOR_VER) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/libcbor/ins/usr/lib/*.so* || true
endif
	mkdir -p pkg && cd tmp/libcbor/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libcbor
src/libcbor-$(LIBCBOR_VER).zip: src/.gitignore
	wget -O $@ https://github.com/PJK/libcbor/archive/refs/tags/v$(LIBCBOR_VER).zip && touch $@

