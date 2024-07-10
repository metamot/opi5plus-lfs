SRC+=src/acl-$(ACL_VER).tar.gz
PKG+=pkg/acl.cpio.zst
acl: pkg/acl.cpio.zst
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
ACL_OPT+= --prefix=/usr
ACL_OPT+= --disable-static
ACL_OPT+= --libexecdir=/usr/lib
ACL_OPT+= --disable-nls
ACL_OPT+= $(OPT_FLAGS)
pkg/acl.cpio.zst: src/acl-$(ACL_VER).tar.gz pkg/gzip.cpio.zst pkg/attr.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/acl
	mkdir -p tmp/acl/bld
	tar -xzf $< -C tmp/acl
	cd tmp/acl/bld && ../acl-$(ACL_VER)/configure $(ACL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/acl/ins/usr/share
	rm -f tmp/acl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/acl/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_BIN) tmp/acl/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/acl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/acl
src/acl-$(ACL_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/acl/acl-$(ACL_VER).tar.gz && touch $@
#--no-check-certificate
