SRC+=src/attr-$(ATTR_VER).tar.gz
PKG+=pkg/attr.cpio.zst
attr: pkg/attr.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ATTR_OPT+= --prefix=/usr
ATTR_OPT+= --disable-static
ATTR_OPT+= --sysconfdir=/etc
ATTR_OPT+= --disable-nls
ATTR_OPT+= $(OPT_FLAGS)
pkg/attr.cpio.zst: src/attr-$(ATTR_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/attr
	mkdir -p tmp/attr/bld
	tar -xzf $< -C tmp/attr
	cd tmp/attr/bld && ../attr-$(ATTR_VER)/configure $(ATTR_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/attr/ins/usr/share
	rm -f tmp/attr/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/attr/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/attr/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/attr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/attr
src/attr-$(ATTR_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/attr/attr-$(ATTR_VER).tar.gz && touch $@
#--no-check-certificate
