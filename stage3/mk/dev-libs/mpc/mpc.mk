SRC+=src/mpc-$(MPC_VER).tar.gz
PKG+=pkg/mpc.cpio.zst
mpc: pkg/mpc.cpio.zst
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
MPC_OPT+= --prefix=/usr
MPC_OPT+= --disable-static
MPC_OPT+= --docdir=/usr/share/doc/mpc-$(MPC_VER)
MPC_OPT+= $(OPT_FLAGS)
pkg/mpc.cpio.zst: src/mpc-$(MPC_VER).tar.gz pkg/gzip.cpio.zst pkg/gmp.cpio.zst pkg/mpfr.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/mpc
	mkdir -p tmp/mpc/bld
	tar -xzf $< -C tmp/mpc
	cd tmp/mpc/bld && ../mpc-$(MPC_VER)/configure $(MPC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mpc/ins/usr/share
	rm -fr tmp/mpc/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/mpc/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/mpc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mpc
src/mpc-$(MPC_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/mpc/mpc-$(MPC_VER).tar.gz && touch $@
