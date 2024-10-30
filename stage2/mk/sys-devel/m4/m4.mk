SRC+= src/m4-$(M4_VER).tar.xz
PKG+= pkg/m4.cpio.zst
m4: pkg/m4.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
M4_OPT+= --prefix=/usr
M4_OPT+= --without-libsigsegv-prefix
M4_OPT+= $(OPT_FLAGS)
pkg/m4.cpio.zst: src/m4-$(M4_VER).tar.xz
	rm -fr tmp/m4
	mkdir -p tmp/m4/bld
	tar -xJf $< -C tmp/m4
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/m4/m4-$(M4_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/m4/m4-$(M4_VER)/lib/stdio-impl.h
	cd tmp/m4/bld && ../m4-$(M4_VER)/configure $(M4_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/m4/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/m4/ins/usr/bin/m4
endif
	mkdir -p pkg && cd tmp/m4/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/m4
src/m4-$(M4_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate http://ftp.gnu.org/gnu/m4/m4-$(M4_VER).tar.xz && touch $@
