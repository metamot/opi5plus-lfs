SRC+=src/expect$(EXPECT_VER).tar.gz
PKG+=pkg/expect.cpio.zst
expect: pkg/expect.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
EXPECT_OPT+= --prefix=/usr
EXPECT_OPT+= --with-tcl=/usr/lib
EXPECT_OPT+= --enable-shared
EXPECT_OPT+= --mandir=/usr/share/man
EXPECT_OPT+= --enable-64bit
EXPECT_OPT+= --with-tclinclude=/usr/include
EXPECT_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg/expect.cpio.zst: src/expect$(EXPECT_VER).tar.gz src/config.guess src/config.sub pkg/gzip.cpio.zst pkg/tcl.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/expect
	mkdir -p tmp/expect/bld
	tar -xzf $< -C tmp/expect
	cp -fv src/config.guess tmp/expect/expect$(EXPECT_VER)/tclconfig/
	cp -fv src/config.sub tmp/expect/expect$(EXPECT_VER)/tclconfig/
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/expect/expect$(EXPECT_VER)/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/expect/expect$(EXPECT_VER)/testsuite/configure
	cd tmp/expect/bld && ../expect$(EXPECT_VER)/configure $(EXPECT_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/expect/ins/usr/share
	cd tmp/expect/ins/usr/lib && ln -svf expect$(EXPECT_VER)/libexpect$(EXPECT_VER).so libexpect$(EXPECT_VER).so
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/expect/ins/usr/lib/expect$(EXPECT_VER)/libexpect$(EXPECT_VER).so
	strip $(STRIP_BUILD_BIN) tmp/expect/ins/usr/bin/expect
endif
	mkdir -p pkg && cd tmp/expect/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/expect
src/expect$(EXPECT_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://prdownloads.sourceforge.net/expect/expect$(EXPECT_VER).tar.gz && touch $@
