SRC+=src/can-utils-v$(CAN_UTILS_VER).zip
PKG+=pkg/can-utils.cpio.zst
can-utils: pkg/can-utils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#GMP_OPT+= --prefix=/usr
#GMP_OPT+= $(OPT_FLAGS)
pkg/can-utils.cpio.zst: src/can-utils-v$(CAN_UTILS_VER).zip
	rm -fr tmp/can-utils
	mkdir -p tmp/can-utils/bld
	bsdtar -xf $< -C tmp/can-utils
#	cd tmp/can-utils/bld && ../gmp-$(GMP_VER)/configure $(GMP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/can-utils/ins/usr/share
#	rm -f tmp/can-utils/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/can-utils/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/can-utils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/can-utils
src/can-utils-v$(CAN_UTILS_VER).zip: src/.gitignore
	wget -O $@ https://github.com/linux-can/can-utils/archive/refs/tags/v$(CAN_UTILS_VER).zip && touch $@
# --no-check-certificate

