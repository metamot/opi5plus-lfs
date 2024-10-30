SRC+=src/pv_$(PV_VER).orig.tar.bz2
PKG+=pkg/pv.cpio.zst
pv: pkg/pv.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PV_OPT+= --prefix=/usr
PV_OPT+= --disable-nls
PV_OPT+= $(OPT_FLAGS)
pkg/pv.cpio.zst: src/pv_$(PV_VER).orig.tar.bz2 pkg/gzip.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/pv
	mkdir -p tmp/pv/bld
	tar -xjf $< -C tmp/pv
	cd tmp/pv/bld && ../pv-$(PV_VER)/configure $(PV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/pv/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/pv/ins/usr/bin/pv
endif
	mkdir -p pkg && cd tmp/pv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/pv
src/pv_$(PV_VER).orig.tar.bz2: src/.gitignore
	wget -P src http://deb.debian.org/debian/pool/main/p/pv/pv_$(PV_VER).orig.tar.bz2 && touch $@
#--no-check-certificate
