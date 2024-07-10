SRC+=src/e2fsprogs-$(E2FSPROGS_VER).tar.gz
PKG+=pkg/e2fsprogs.cpio.zst
e2fsprogs: pkg/e2fsprogs.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
E2FSPROGS_OPT+= --prefix=/usr
E2FSPROGS_OPT+= --bindir=/usr/bin
E2FSPROGS_OPT+= --libdir=/usr/lib
E2FSPROGS_OPT+= --sbindir=/usr/sbin
E2FSPROGS_OPT+= --with-root-prefix=""
E2FSPROGS_OPT+= --enable-elf-shlibs
E2FSPROGS_OPT+= --disable-libblkid
E2FSPROGS_OPT+= --disable-libuuid
E2FSPROGS_OPT+= --disable-uuidd
E2FSPROGS_OPT+= --disable-fsck
E2FSPROGS_OPT+= --disable-nls
E2FSPROGS_OPT+= $(OPT_FLAGS)
pkg/e2fsprogs.cpio.zst: src/e2fsprogs-$(E2FSPROGS_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/e2fsprogs
	mkdir -p tmp/e2fsprogs/bld
	tar -xzf $< -C tmp/e2fsprogs
	cd tmp/e2fsprogs/bld && ../e2fsprogs-$(E2FSPROGS_VER)/configure $(E2FSPROGS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/e2fsprogs/ins/lib/* tmp/e2fsprogs/ins/usr/lib/
	rm -fr tmp/e2fsprogs/ins/lib
	rm -fr tmp/e2fsprogs/ins/usr/share/info
	rm -fr tmp/e2fsprogs/ins/usr/share/man
	chmod -v u+w tmp/e2fsprogs/ins/usr/lib/*.a
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/e2fsprogs/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/e2fsprogs/ins/usr/sbin/* || true
	strip $(STRIP_BUILD_AST)    tmp/e2fsprogs/ins/usr/lib/*.a
	strip $(STRIP_BUILD_LIB) tmp/e2fsprogs/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_LIB) tmp/e2fsprogs/ins/usr/lib/e2initrd_helper
endif
	mkdir -p pkg && cd tmp/e2fsprogs/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/e2fsprogs
src/e2fsprogs-$(E2FSPROGS_VER).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz && touch $@
#--no-check-certificate

