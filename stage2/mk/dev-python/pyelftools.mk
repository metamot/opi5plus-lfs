# Extra :: python 'pyelftools' (for uboot)
# https://github.com/eliben/pyelftools/wiki/User's-guide
# https://github.com/eliben/pyelftools
# BUILD_TIME :: 2s
#pkg3/pyelftools-$(PYELFTOOLS_VER).cpio.zst: pkg3/libarchive-$(LIBARCHIVE_VER).cpio.zst
#	rm -fr tmp/pyelftools
#	mkdir -p tmp/pyelftools
#	bsdtar -xf pkg/pyelftools-$(PYELFTOOLS_VER).zip -C tmp/pyelftools
#	cd tmp/pyelftools/pyelftools-$(PYELFTOOLS_VER) && python3 setup.py install
### /usr/lib/python3.8/site-packages/easy-install.pth
### /usr/lib/python3.8/site-packages/pyelftools-0.30-py3.8.egg/
## backward pack from rfs
#	rm -f /usr/lib/python$(PYTHON_VER0)/site-packages/easy-install.pth
#	mkdir -p tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/pyelftools-$(PYELFTOOLS_VER)-py$(PYTHON_VER0).egg
##	cp -f /usr/lib/python$(PYTHON_VER0)/site-packages/easy-install.pth tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cp -far /usr/lib/python$(PYTHON_VER0)/site-packages/pyelftools-$(PYELFTOOLS_VER)-py$(PYTHON_VER0).egg tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cd tmp/pyelftools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#pkg3/pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst:
##	pip3 install pyelftools
#	rm -fr tmp/pyelftools
#	mkdir -p tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages
#	cp -far /usr/lib/python3.8/site-packages/elftools tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cp -far /usr/lib/python3.8/site-packages/pyelftools-$(PYELFTOOLS_VER).dist-info tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cd tmp/pyelftools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
## backward pack from rfs
#tgt-pyelftools: pkg3/pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst

# pip3 install pyelftools
# /usr/lib/python3.8/site-packages/pyelftools-$(PYELFTOOLS_VER)
# /usr/lib/python3.8/site-packages/elftools/*


#SRC+=src/gmp-$(GMP_VER).tar.xz
#PKG+=pkg/gmp.cpio.zst
#gmp: pkg/gmp.cpio.zst
#	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#GMP_OPT+= --prefix=/usr
#GMP_OPT+= --enable-cxx
#GMP_OPT+= --disable-static
#GMP_OPT+= --docdir=/usr/share/doc/gmp-$(GMP_VER)
#GMP_OPT+= $(OPT_FLAGS)
#pkg/gmp.cpio.zst: src/gmp-$(GMP_VER).tar.xz pkg/m4.cpio.zst
#	cat pkg/m4.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	rm -fr tmp/gmp
#	mkdir -p tmp/gmp/bld
#	tar -xJf $< -C tmp/gmp
#	cd tmp/gmp/bld && ../gmp-$(GMP_VER)/configure $(GMP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/gmp/ins/usr/share
#	rm -f tmp/gmp/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip $(STRIP_BUILD_LIB) tmp/gmp/ins/usr/lib/*.so*
#endif
#	mkdir -p pkg && cd tmp/gmp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/gmp
#src/gmp-$(GMP_VER).tar.xz: src/.gitignore
#	wget -P src --no-check-certificate https://ftp.gnu.org/gnu/gmp/gmp-$(GMP_VER).tar.xz && touch $@

