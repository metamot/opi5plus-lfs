SRC+=src/less-$(LESS_VER).tar.gz
PKG+=pkg/less.cpio.zst
less: pkg/less.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LESS_OPT+= --prefix=/usr
LESS_OPT+= --sysconfdir=/etc
LESS_OPT+= $(OPT_FLAGS)
pkg/less.cpio.zst: src/less-$(LESS_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/less
	mkdir -p tmp/less/bld
	tar -xzf $< -C tmp/less
	cd tmp/less/bld && ../less-$(LESS_VER)/configure $(LESS_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/less/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/less/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/less/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/less
src/less-$(LESS_VER).tar.gz: src/.gitignore
	wget -P src http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz && touch $@
#--no-check-certificate

