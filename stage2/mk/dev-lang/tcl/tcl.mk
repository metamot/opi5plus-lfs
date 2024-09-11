SRC+=src/tcl$(TCL_VER)-src.tar.gz
SRC+=src/tcl$(TCL_DOC_VER)-html.tar.gz
PKG+=pkg/tcl.cpio.zst
tcl: pkg/tcl.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
TCL_OPT+= --prefix=/usr
TCL_OPT+= --mandir=/usr/share/man
TCL_OPT+= --with-encoding=utf-8
#TCL_OPT+= --enable-64bit
TCL_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg/tcl.cpio.zst: src/tcl$(TCL_VER)-src.tar.gz src/tcl$(TCL_DOC_VER)-html.tar.gz pkg/gzip.cpio.zst pkg/zlib.cpio.zst pkg/file.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/tcl
	mkdir -p tmp/tcl/bld
	tar -xzf $< -C tmp/tcl
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/unix/configure
	cd tmp/tcl/bld && ../tcl$(TCL_VER)/unix/configure $(TCL_OPT) && make $(JOBS) V=$(VERB)
	sed -i "s|`pwd`/tmp/tcl/bld|/usr/lib|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)|/usr/include|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/generic|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0/generic|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install-private-headers
	rm -fr tmp/tcl/ins/usr/share/man
	cd tmp/tcl/ins/usr/bin && ln -sf tclsh$(TCL_VER_BRIEF) tclsh
	chmod -v u+w tmp/tcl/ins/usr/lib/libtcl$(TCL_VER_BRIEF).so
ifeq ($(BUILD_STRIP),y)
	find tmp/tcl/ins/usr/lib -type f -name "*.a" -exec strip $(STRIP_BUILD_AST) {} +
	strip $(STRIP_BUILD_BIN) tmp/tcl/ins/usr/bin/tclsh$(TCL_VER_BRIEF)
	cd tmp/tcl/ins/usr/lib && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p pkg && cd tmp/tcl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tcl
src/tcl$(TCL_VER)-src.tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://downloads.sourceforge.net/tcl/tcl$(TCL_VER)-src.tar.gz && touch $@
src/tcl$(TCL_DOC_VER)-html.tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://downloads.sourceforge.net/tcl/tcl$(TCL_DOC_VER)-html.tar.gz && touch $@
