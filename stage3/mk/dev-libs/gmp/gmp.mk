SRC+=src/gmp-$(GMP_VER).tar.xz
PKG+=pkg/gmp.cpio.zst
gmp: pkg/gmp.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GMP_OPT+= --prefix=/usr
GMP_OPT+= --enable-cxx
GMP_OPT+= --disable-static
GMP_OPT+= --docdir=/usr/share/doc/gmp-$(GMP_VER)
GMP_OPT+= $(OPT_FLAGS)
pkg/gmp.cpio.zst: src/gmp-$(GMP_VER).tar.xz pkg/m4.cpio.zst
	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/gmp
	mkdir -p tmp/gmp/bld
	tar -xJf $< -C tmp/gmp
	cd tmp/gmp/bld && ../gmp-$(GMP_VER)/configure $(GMP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gmp/ins/usr/share
	rm -f tmp/gmp/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/gmp/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/gmp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gmp
src/gmp-$(GMP_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/gmp/gmp-$(GMP_VER).tar.xz && touch $@
