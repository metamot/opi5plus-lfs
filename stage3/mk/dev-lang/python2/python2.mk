SRC+=src/Python-$(PYTHON2_VER).tar.xz
PKG+=pkg/python2.cpio.zst
python2: pkg/python2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
python-is-python2: pkg/python2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cd /usr/bin && ln -sfv pip2 pip
	cd /usr/bin && ln -sfv python2 python
PYTHON2_OPT+= --prefix=/usr
PYTHON2_OPT+= --enable-shared
PYTHON2_OPT+= --with-system-expat
PYTHON2_OPT+= --with-system-ffi
PYTHON2_OPT+= --with-ensurepip=yes
PYTHON2_OPT+= --enable-unicode=ucs4
PYTHON2_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg/python2.cpio.zst: src/Python-$(PYTHON2_VER).tar.xz pkg/grep.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst
# pkg/bzip2.cpio.zst pkg/zlib.cpio.zst pkg/readline.cpio.zst pkg/pkgconfig.cpio.zst pkg/expat.cpio.zst 
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/pkgconfig.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/python2
	mkdir -p tmp/python2/bld
	tar -xJf $< -C tmp/python2
	sed -i 's|-O3|$(BASE_OPT_VALUE)|' tmp/python2/Python-$(PYTHON2_VER)/configure
	cd tmp/python2/bld && ../Python-$(PYTHON2_VER)/configure $(PYTHON2_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/python2/ins/usr/share
	chmod -v 755 tmp/python2/ins/usr/lib/libpython2.7.so.1.0
ifeq ($(BUILD_STRIP),y)
	find tmp/python2/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/python2/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
#	mkdir -p pkg && cd tmp/python2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/python2
src/Python-$(PYTHON2_VER).tar.xz: src/.gitignore
	wget -P src https://www.python.org/ftp/python/$(PYTHON2_VER)/Python-$(PYTHON2_VER).tar.xz && touch $@
# --no-check-certificate

