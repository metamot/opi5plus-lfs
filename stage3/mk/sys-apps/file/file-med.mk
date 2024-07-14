# "file.mk" must be included above
#SRC+=src/file-$(FILE_VER).tar.gz
PKG+=pkg/file-med.cpio.zst
file-med: pkg/file-med.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
FILE_MED_OPT+= --prefix=/usr
FILE_MED_OPT+= --disable-libseccomp
FILE_MED_OPT+= $(OPT_FLAGS)
pkg/file-med.cpio.zst: src/file-$(FILE_VER).tar.gz pkg/gzip.cpio.zst pkg/zlib.cpio.zst pkg/bzip2.cpio.zst pkg/xz-utils.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/file-med
	mkdir -p tmp/file-med/bld
	tar -xzf $< -C tmp/file-med
	cd tmp/file-med/bld && ../file-$(FILE_VER)/configure $(FILE_MED_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/file-med/ins/usr/share/man
	rm -f tmp/file-med/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/file-med/ins/usr/bin/file
	strip $(STRIP_BUILD_LIB) tmp/file-med/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/file-med/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/file-med
#src/file-$(FILE_VER).tar.gz: src/.gitignore
#	wget -P src ftp://ftp.astron.com/pub/file/file-$(FILE_VER).tar.gz && touch $@
#--no-check-certificate
