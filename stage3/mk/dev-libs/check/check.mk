SRC+=src/check-$(CHECK_VER).tar.gz
PKG+=pkg/check.cpio.zst
check: pkg/check.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
CHECK_OPT+= --prefix=/usr
CHECK_OPT+= --disable-static
CHECK_OPT+= $(OPT_FLAGS)
pkg/gmp.cpio.zst: src/check-$(CHECK_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/check
	mkdir -p tmp/check/bld
	tar -xzf $< -C tmp/check
	cd tmp/check/bld && ../check-$(CHECK_VER)/configure $(CHECK_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/check/ins/usr/share/doc
	rm -fr tmp/check/ins/usr/share/info
	rm -fr tmp/check/ins/usr/share/man
	rm -f  tmp/check/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/check/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/check/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/check
src/check-$(CHECK_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/libcheck/check/releases/download/$(CHECK_VER)/check-$(CHECK_VER).tar.gz && touch $@
# --no-check-certificate


