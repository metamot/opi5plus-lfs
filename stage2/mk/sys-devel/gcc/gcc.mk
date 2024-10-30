# WITHOUT PYTHON RDEP!
SRC+= src/gcc-$(GCC_VER).tar.xz
PKG+= pkg/gcc.cpio.zst
gcc: pkg/gcc.cpio.zst
##	cat pkg/libatomic_ops.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
###	cat pkg/boehm-gc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zstd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/isl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GCC_OPT+= --prefix=/usr
GCC_OPT+= LD=ld
GCC_OPT+= --enable-languages=c,c++
### GCC_OPT+= --enable-languages=c,c++,objc,obc-c++,m2,go,fortran
## GCC_OPT+= --enable-languages=c,c++,objc
## GCC_OPT+= --enable-objc-gc
# ^^ "libatomic_ops" deps!!
#GCC_OPT+= --with-system-libunwind
# ^^ no deps
GCC_OPT+= --disable-multilib
GCC_OPT+= --disable-bootstrap
GCC_OPT+= --with-system-zlib
GCC_OPT+= --disable-nls
GCC_OPT+= $(OPT_FLAGS)
GCC_OPT+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC_OPT+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
## pkg/gcc.cpio.zst: src/gcc-$(GCC_VER).tar.xz pkg/grep.cpio.zst pkg/zstd.cpio.zst pkg/binutils.cpio.zst pkg/boehm-gc.cpio.zst pkg/isl.cpio.zst pkg/mpc.cpio.zst pkg/texinfo.cpio.zst
pkg/gcc.cpio.zst: src/gcc-$(GCC_VER).tar.xz pkg/grep.cpio.zst pkg/zstd.cpio.zst pkg/binutils.cpio.zst pkg/isl.cpio.zst pkg/mpc.cpio.zst pkg/texinfo.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zstd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/libunwind.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/libatomic_ops.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/boehm-gc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/isl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/binutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/texinfo.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/bison.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/pod2man.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/flex.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/gettext.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/gawk.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/python3.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
# libcrypt, libiconv, libintl
	rm -fr tmp/gcc
	mkdir -p tmp/gcc/bld
	tar -xJf $< -C tmp/gcc
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libgcc/Makefile.in
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/Makefile.in
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libgomp/configure
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libitm/configure
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libatomic/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/include/Makefile.in
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/include/Makefile.am
# https://mysqlonarm.github.io/ARM-LSE-and-MySQL/
# Resolve '-march=armv8-a+lse' build error:
# tmp/gcc/gcc-$(GCC_VER)/libatomic/Changelog
# tmp/gcc/gcc-$(GCC_VER)/gcc/doc/invoke.texi
# tmp/gcc/gcc-$(GCC_VER)/gcc/doc/gcc.info
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-cas.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-ldadd.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-ldlogic.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-swp.c
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/config/aarch64/lse.S
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/configure.ac
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/configure
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/Makefile.am
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/Makefile.in
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/configure.ac
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/configure
	cd tmp/gcc/bld && ../gcc-$(GCC_VER)/configure $(GCC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gcc/ins/usr/share/info
	rm -fr tmp/gcc/ins/usr/share/man
	mv -f tmp/gcc/ins/usr/lib64/* tmp/gcc/ins/usr/lib/
	rm -fr tmp/gcc/ins/usr/lib64
	cd tmp/gcc/ins/usr/lib && ln -sf ../bin/cpp cpp
	cd tmp/gcc/ins/usr/bin && ln -sf gcc cc
	find tmp/gcc/ins/usr/ -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	find tmp/gcc/ins/usr -type f -name "*.a" -exec strip $(STRIP_BUILD_AST) {} +
	cd tmp/gcc/ins/usr && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	install -v -dm755 tmp/gcc/ins/usr/lib/bfd-plugins
	cp -f src/config.guess tmp/
	chmod ugo+x tmp/config.guess
	cd tmp/gcc/ins/usr/lib/bfd-plugins && ln -sf ../../libexec/gcc/`../../../../../config.guess`/$(GCC_VER)/liblto_plugin.so liblto_plugin.so
	rm -f tmp/config.guess
	mkdir -p tmp/gcc/ins/usr/share/gdb/auto-load/usr/lib
	mv -f tmp/gcc/ins/usr/lib/*gdb.py tmp/gcc/ins/usr/share/gdb/auto-load/usr/lib/
	cd tmp/gcc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gcc
src/gcc-$(GCC_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VER)/gcc-$(GCC_VER).tar.xz && touch $@
