SRC+=src/Python-$(PYTHON3_VER).tar.xz
PKG+=pkg/python3.cpio.zst
python3pre: pkg/python3pre.cpio.zst
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
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
	cd /usr/bin && ln -sfv idle3 idle
	cd /usr/bin && ln -sfv pydoc3 pydoc
	cd /usr/bin && ln -sfv easy_install-$(PYTHON3_VER0) easy_install
	cd /usr/bin && ln -sfv python$(PYTHON3_VER0)-config python-config
	mv -fv /usr/bin/2to3-3 /usr/bin/2to3
PYTHON3PRE_OPT+= --prefix=/usr
PYTHON3PRE_OPT+= --enable-shared
PYTHON3PRE_OPT+= --with-system-expat
PYTHON3PRE_OPT+= --with-system-ffi
PYTHON3PRE_OPT+= --with-system-libmpdec
PYTHON3PRE_OPT+= --with-ensurepip=yes
#PYTHON3_OPT+= --enable-optimizations
PYTHON3PRE_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
PYTHON3PRE_DEPS+= pkg/libuuid.cpio.zst
PYTHON3PRE_DEPS+= pkg/gdbm.cpio.zst
PYTHON3PRE_DEPS+= pkg/mime-types.cpio.zst
PYTHON3PRE_DEPS+= pkg/mpdecimal.cpio.zst
PYTHON3PRE_DEPS+= pkg/expat.cpio.zst
PYTHON3PRE_DEPS+= pkg/libffi.cpio.zst
PYTHON3PRE_DEPS+= pkg/openssl.cpio.zst
PYTHON3PRE_DEPS+= pkg/readline.cpio.zst
PYTHON3PRE_DEPS+= pkg/pkgconfig.cpio.zst
PYTHON3PRE_DEPS+= pkg/xz-utils.cpio.zst
PYTHON3PRE_DEPS+= pkg/bzip2.cpio.zst
pkg/python3pre.cpio.zst: src/Python-$(PYTHON3_VER).tar.xz $(PYTHON3PRE_DEPS)
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libffi.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mime-types.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/pkgconfig.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpdecimal.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/openssl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gdbm.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/db.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libuuid.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/python3pre
	mkdir -p tmp/python3pre/bld
	tar -xJf $< -C tmp/python3pre
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/python3pre/Python-$(PYTHON3_VER)/configure
	cd tmp/python3pre/bld && sh -c 'CXX="/usr/bin/g++" export PATH=`pwd`/../ins/usr/bin:$$PATH && ../Python-$(PYTHON3_VER)/configure $(PYTHON3PRE_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/python3pre/ins/usr/share
	chmod -v 755 tmp/python3pre/ins/usr/lib/libpython$(PYTHON3_VER0).so
	chmod -v 755 tmp/python3pre/ins/usr/lib/libpython$(PYTHON3_VER00).so
ifeq ($(BUILD_STRIP),y)
	cd tmp/python3pre/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mv -vf tmp/python3pre/ins/usr/bin/2to3 tmp/python3pre/ins/usr/bin/2to3-3
	mkdir -p pkg && cd tmp/python3pre/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/python3pre
src/Python-$(PYTHON3_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://www.python.org/ftp/python/$(PYTHON3_VER)/Python-$(PYTHON3_VER).tar.xz && touch $@

