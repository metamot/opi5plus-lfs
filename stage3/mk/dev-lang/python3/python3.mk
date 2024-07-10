SRC+=src/Python-$(PYTHON3_VER).tar.xz
PKG+=pkg/python3.cpio.zst
python3: pkg/python3.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
python-is-python3: pkg/python3.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cd /usr/bin && ln -sfv pip3 pip
	cd /usr/bin && ln -sfv python3 python
PYTHON3_OPT+= --prefix=/usr
PYTHON3_OPT+= --enable-shared
PYTHON3_OPT+= --with-system-expat
#PYTHON3_OPT+= --with-system-ffi
PYTHON3_OPT+= --with-ensurepip=yes
PYTHON3_OPT+= --enable-optimizations
PYTHON3_OPT+= $(OPT_FLAGS)
pkg/python3.cpio.zst: src/Python-$(PYTHON3_VER).tar.xz pkg/bzip2.cpio.zst pkg/zlib.cpio.zst pkg/readline.cpio.zst pkg/pkgconfig.cpio.zst pkg/expat.cpio.zst pkg/grep.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst pkg/expat.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/pkgconfig.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/python3
	mkdir -p tmp/python3/bld
	tar -xJf $< -C tmp/python3
	cd tmp/python3/bld && ../Python-$(PYTHON3_VER)/configure $(PYTHON3_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/python3/ins/usr/share
	chmod -v 755 tmp/python3/ins/usr/lib/libpython$(PYTHON3_VER0).so
	chmod -v 755 tmp/python3/ins/usr/lib/libpython$(PYTHON3_VER00).so
	cd tmp/python3/ins/usr/bin && ln -sfv pip3.8 pip3
ifeq ($(BUILD_STRIP),y)
	cd tmp/python3/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
#	mkdir -p pkg && cd tmp/python3/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/python3
src/Python-$(PYTHON3_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://www.python.org/ftp/python/$(PYTHON3_VER)/Python-$(PYTHON3_VER).tar.xz && touch $@
