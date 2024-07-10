SRC+=src/gperf-$(GPERF_VER).tar.gz
PKG+=pkg/gperf.cpio.zst
gperf: pkg/gperf.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GPERF_OPT+= --prefix=/usr
GPERF_OPT+= --docdir=/usr/share/doc/gperf-$(GPERF_VER)
GPERF_OPT+= $(OPT_FLAGS)
pkg/gperf.cpio.zst: src/gperf-$(GPERF_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gperf
	mkdir -p tmp/gperf/bld
	tar -xzf $< -C tmp/gperf
	cd tmp/gperf/bld && ../gperf-$(GPERF_VER)/configure $(GPERF_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gperf/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/gperf/ins/usr/bin/gperf
endif
	mkdir -p pkg && cd tmp/gperf/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gperf
src/gperf-$(GPERF_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gperf/gperf-$(GPERF_VER).tar.gz && touch $@
#--no-check-certificate

