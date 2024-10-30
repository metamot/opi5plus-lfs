SRC+=src/sharutils-$(SHARUTILS_VER).tar.xz
PKG+=pkg/sharutils.cpio.zst
sharutils: pkg/sharutils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
SHARUTILS_OPT+= --prefix=/usr
SHARUTILS_OPT+= --disable-nls
SHARUTILS_OPT+= $(OPT_FLAGS)
pkg/sharutils.cpio.zst: src/sharutils-$(SHARUTILS_VER).tar.xz
	rm -fr tmp/sharutils
	mkdir -p tmp/sharutils/bld
	tar -xJf $< -C tmp/sharutils
	sed -i 's/BUFSIZ/rw_base_size/' tmp/sharutils/sharutils-$(SHARUTILS_VER)/src/unshar.c
	sed -i '/program_name/s/^/extern /' tmp/sharutils/sharutils-$(SHARUTILS_VER)/src/*opts.h
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/sharutils/sharutils-$(SHARUTILS_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/sharutils/sharutils-$(SHARUTILS_VER)/lib/stdio-impl.h
	cd tmp/sharutils/bld && ../sharutils-$(SHARUTILS_VER)/configure $(SHARUTILS_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/sharutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/sharutils/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/sharutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/sharutils
src/sharutils-$(SHARUTILS_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/sharutils/sharutils-$(SHARUTILS_VER).tar.xz && touch $@
#--no-check-certificate

