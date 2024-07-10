SRC+=src/popt-$(POPT_VER).tar.gz
PKG+=pkg/popt.cpio.zst
popt: pkg/popt.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
POPT_OPT+= --prefix=/usr
POPT_OPT+= --disable-static
POPT_OPT+= --disable-nls
POPT_OPT+= $(OPT_FLAGS)
pkg/popt.cpio.zst: src/popt-$(POPT_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/popt
	mkdir -p tmp/popt/bld
	tar -xzf $< -C tmp/popt
	cd tmp/popt/bld && ../popt-$(POPT_VER)/configure $(POPT_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/popt/ins/usr/share
	rm -f tmp/popt/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/popt/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/popt/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/popt
src/popt-$(POPT_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.rpm.org/popt/releases/popt-1.x/popt-$(POPT_VER).tar.gz && touch $@
# --no-check-certificate

