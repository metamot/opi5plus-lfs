SRC+=src/dtc-$(DTC_VER).tar.gz
PKG+=pkg/dtc.cpio.zst
dtc: pkg/dtc.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DTC_MOPT+= --prefix=/usr
DTC_MOPT+= -Dpython=disabled
#DTC_MOPT+= --buildtype=release
DTC_MOPT+= -Ddebug=false
DTC_MOPT+= -Doptimization=$(BASE_OPT_VAL)
DTC_MOPT+= -Dc_args="$(RK3588_FLAGS)"
DTC_MOPT+= -Dcpp_args="$(RK3588_FLAGS)"
DTC_BUILD_VERB=
ifeq ($(VERB),1)
DTC_BUILD_VERB=-v
endif
pkg/dtc.cpio.zst: src/dtc-$(DTC_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/dtc
	mkdir -p tmp/dtc/bld
	tar -xzf $< -C tmp/dtc
	cd tmp/dtc/bld && LANG=en_US.UTF-8 meson setup $(DTC_MOPT) ../dtc-$(DTC_VER)
	cd tmp/dtc/bld && LANG=en_US.UTF-8 ninja $(DTC_BUILD_VERB)
	cd tmp/dtc/bld && LANG=en_US.UTF-8 DESTDIR=`pwd`/../ins ninja install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/dtc/ins/usr/bin/* || true
	strip --strip-unneeded tmp/dtc/ins/usr/lib/*.so*
	strip --strip-debug tmp/dtc/ins/usr/lib/*.a
endif
#	mkdir -p pkg && cd tmp/dtc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cp -far tmp/dtc/ins/usr/lib/*.so* /usr/lib/
#	cp -far tmp/dtc/ins/usr/bin/dtc /usr/bin/
#	rm -fr tmp/dtc
src/dtc-$(DTC_VER).tar.gz: src/.gitignore
	wget -P src https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-$(DTC_VER).tar.gz && touch $@
#--no-check-certificate

