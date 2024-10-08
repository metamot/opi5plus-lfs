SRC+=src/file-$(FILE_VER).tar.gz
PKG+=pkg/file.cpio.zst
file: pkg/file.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
FILE_OPT+= --prefix=/usr
FILE_OPT+= --disable-zlib
FILE_OPT+= --disable-bzlib
FILE_OPT+= --disable-xzlib
FILE_OPT+= --disable-libseccomp
FILE_OPT+= $(OPT_FLAGS)
pkg/file.cpio.zst: src/file-$(FILE_VER).tar.gz pkg/gzip.cpio.zst pkg/tar.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/attr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/acl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/tar.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/file
	mkdir -p tmp/file/bld
	tar -xzf $< -C tmp/file
	cd tmp/file/bld && ../file-$(FILE_VER)/configure $(FILE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/file/ins/usr/share/man
	rm -f tmp/file/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/file/ins/usr/bin/file
	strip $(STRIP_BUILD_LIB) tmp/file/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/file/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/file
src/file-$(FILE_VER).tar.gz: src/.gitignore
	wget -P src ftp://ftp.astron.com/pub/file/file-$(FILE_VER).tar.gz && touch $@
#--no-check-certificate
