SRC+=src/libxml2-$(LIBXML2_VER).tar.gz
PKG+=pkg/libxml2.cpio.zst
libxml2: pkg/libxml2.cpio.zst
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
	cat pkg/python3.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
# ^^ warning! Usual python3 (not python3pre)
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
	cd /usr/bin && ln -sfv idle3 idle
	cd /usr/bin && ln -sfv pydoc3 pydoc
	cd /usr/bin && ln -sfv easy_install-$(PYTHON3_VER0) easy_install
	cd /usr/bin && ln -sfv python$(PYTHON3_VER0)-config python-config
	mv -fv /usr/bin/2to3-3 /usr/bin/2to3
# gcc: for libstdc++
##	cat pkg/binutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/isl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/mpc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
##	cat pkg/zstd.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/gcc.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#
	cat pkg/icu.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
LIBXML2_OPT+= --prefix=/usr
LIBXML2_OPT+= --disable-static
LIBXML2_OPT+= --with-history
LIBXML2_OPT+= --with-icu
LIBXML2_OPT+= --with-threads
LIBXML2_OPT+= --without-debug
LIBXML2_OPT+= --with-python=/usr/bin/python3
LIBXML2_OPT+= $(OPT_FLAGS)
LIBXML2_DEP+= pkg/zlib.cpio.zst
LIBXML2_DEP+= pkg/bzip2.cpio.zst
LIBXML2_DEP+= pkg/xz-utils.cpio.zst
LIBXML2_DEP+= pkg/readline.cpio.zst
LIBXML2_DEP+= pkg/python3pre.cpio.zst
LIBXML2_DEP+= pkg/icu.cpio.zst
pkg/libxml2.cpio.zst: src/libxml2-$(LIBXML2_VER).tar.gz $(LIBXML2_DEP)
# pkg/readline.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/icu.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#
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
# ^^ warning: python3pre (pre-step for usual python3)
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
	cd /usr/bin && ln -sfv idle3 idle
	cd /usr/bin && ln -sfv pydoc3 pydoc
	cd /usr/bin && ln -sfv easy_install-$(PYTHON3_VER0) easy_install
	cd /usr/bin && ln -sfv python$(PYTHON3_VER0)-config python-config
	mv -fv /usr/bin/2to3-3 /usr/bin/2to3
#
	rm -fr tmp/libxml2
	mkdir -p tmp/libxml2/bld
	tar -xzf $< -C tmp/libxml2
	cd tmp/libxml2/bld && ../libxml2-$(LIBXML2_VER)/configure $(LIBXML2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libxml2/ins/usr/share/doc
	rm -fr tmp/libxml2/ins/usr/share/gtk-doc
	rm -fr tmp/libxml2/ins/usr/share/man
	rm -f  tmp/libxml2/ins/usr/lib/*.la
	rm -f  tmp/libxml2/ins/usr/lib/python$(PYTHON3_VER0)/site-packages/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/libxml2/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/libxml2/ins/usr/lib/*.so*
	strip $(STRIP_BUILD_LIB) tmp/libxml2/ins/usr/lib/python$(PYTHON3_VER0)/site-packages/*.so*
endif
	mkdir -p pkg && cd tmp/libxml2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libxml2
src/libxml2-$(LIBXML2_VER).tar.gz: src/.gitignore
	wget -P src http://xmlsoft.org/sources/libxml2-$(LIBXML2_VER).tar.gz && touch $@
# --no-check-certificate
