# python3pre.mk must be included above
PKG+=pkg/python3.cpio.zst
python3: pkg/python3.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/openssl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libffi.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpdecimal.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gdbm.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libuuid.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mime-types.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/icu.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libxml2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
	cd /usr/bin && ln -sfv idle3 idle
	cd /usr/bin && ln -sfv pydoc3 pydoc
	cd /usr/bin && ln -sfv easy_install-$(PYTHON3_VER0) easy_install
	cd /usr/bin && ln -sfv python$(PYTHON3_VER0)-config python-config
	mv -fv /usr/bin/2to3-3 /usr/bin/2to3
PYTHON3_OPT+= --prefix=/usr
PYTHON3_OPT+= --enable-shared
PYTHON3_OPT+= --with-system-expat
PYTHON3_OPT+= --with-system-ffi
PYTHON3_OPT+= --with-system-libmpdec
PYTHON3_OPT+= --with-ensurepip=yes
PYTHON3_OPT+= --enable-optimizations
PYTHON3_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
PYTHON3_DEPS+= pkg/libuuid.cpio.zst
PYTHON3_DEPS+= pkg/gdbm.cpio.zst
PYTHON3_DEPS+= pkg/mime-types.cpio.zst
PYTHON3_DEPS+= pkg/mpdecimal.cpio.zst
PYTHON3_DEPS+= pkg/expat.cpio.zst
PYTHON3_DEPS+= pkg/libffi.cpio.zst
PYTHON3_DEPS+= pkg/openssl.cpio.zst
PYTHON3_DEPS+= pkg/readline.cpio.zst
PYTHON3_DEPS+= pkg/pkgconfig.cpio.zst
PYTHON3_DEPS+= pkg/xz-utils.cpio.zst
PYTHON3_DEPS+= pkg/bzip2.cpio.zst
PYTHON3_DEPS+= pkg/libxml2.cpio.zst
PYTHON3_DEPS+= pkg/python3pre.cpio.zst
pkg/python3.cpio.zst: src/Python-$(PYTHON3_VER).tar.xz $(PYTHON3_DEPS)
# python3
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/openssl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libffi.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpdecimal.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gdbm.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libuuid.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mime-types.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/python3pre.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
	cd /usr/bin && ln -sfv idle3 idle
	cd /usr/bin && ln -sfv pydoc3 pydoc
	cd /usr/bin && ln -sfv easy_install-$(PYTHON3_VER0) easy_install
	cd /usr/bin && ln -sfv python$(PYTHON3_VER0)-config python-config
	mv -fv /usr/bin/2to3-3 /usr/bin/2to3
# gcc: for libstdc++
#	cat pkg/zstd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/binutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/isl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/mpc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/gcc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#
	cat pkg/icu.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libxml2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/pkgconfig.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/python3
	mkdir -p tmp/python3/bld
	tar -xJf $< -C tmp/python3
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/python3/Python-$(PYTHON3_VER)/configure
	cd tmp/python3/bld && sh -c 'CXX="/usr/bin/g++" export PATH=`pwd`/../ins/usr/bin:$$PATH && ../Python-$(PYTHON3_VER)/configure $(PYTHON3_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/python3/ins/usr/share
	chmod -v 755 tmp/python3/ins/usr/lib/libpython$(PYTHON3_VER0).so
	chmod -v 755 tmp/python3/ins/usr/lib/libpython$(PYTHON3_VER00).so
ifeq ($(BUILD_STRIP),y)
	cd tmp/python3/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/python3/ins-final
	cat pkg/python3pre.cpio.zst | zstd -d | cpio -idumH newc --quiet -D tmp/python3/ins-final > /dev/null 2>&1
	cp -vfa tmp/python3/ins/usr/lib/libpython$(PYTHON3_VER0).so.1.0 tmp/python3/ins-final/usr/lib/
	cp -vfa tmp/python3/ins/usr/lib/python$(PYTHON3_VER0)/_sysconfigdata__linux_aarch64-linux-gnu.py tmp/python3/ins-final/usr/lib/python$(PYTHON3_VER0)/
	cp -vfa tmp/python3/ins/usr/lib/python$(PYTHON3_VER0)/config-$(PYTHON3_VER0)-aarch64-linux-gnu/Makefile tmp/python3/ins-final/usr/lib/python$(PYTHON3_VER0)/config-$(PYTHON3_VER0)-aarch64-linux-gnu/
#	mv -vf tmp/python3/ins/usr/bin/2to3 tmp/python3/ins/usr/bin/2to3-3
	mkdir -p pkg && cd tmp/python3/ins-final && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/python3
