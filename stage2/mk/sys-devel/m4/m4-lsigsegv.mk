#m4.mk must be included above
PKG+= pkg/m4-lsigsegv.cpio.zst
m4-lsigsegv: pkg/m4-lsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
M4_SIGSEGV_OPT+= --prefix=/usr
M4_SIGSEGV_OPT+= $(OPT_FLAGS)
pkg/m4-lsigsegv.cpio.zst: src/m4-$(M4_VER).tar.xz pkg/libsigsegv.cpio.zst
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/m4-lsigsegv
	mkdir -p tmp/m4-lsigsegv/bld
	tar -xJf $< -C tmp/m4-lsigsegv
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/m4-lsigsegv/m4-$(M4_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/m4-lsigsegv/m4-$(M4_VER)/lib/stdio-impl.h
	cd tmp/m4-lsigsegv/bld && ../m4-$(M4_VER)/configure $(M4_SIGSEGV_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/m4-lsigsegv/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/m4-lsigsegv/ins/usr/bin/m4
endif
	mkdir -p pkg && cd tmp/m4-lsigsegv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/m4-lsigsegv
