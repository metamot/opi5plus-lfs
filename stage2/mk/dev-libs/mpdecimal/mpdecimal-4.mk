SRC+=src/mpdecimal-$(MPDECIMAL_VER).tar.gz
PKG+=pkg/mpdecimal.cpio.zst
mpdecimal: pkg/mpdecimal.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
MPDECIMAL_OPT+= --prefix=/usr
MPDECIMAL_OPT+= --enable-shared
MPDECIMAL_OPT+= --disable-static
MPDECIMAL_OPT+= --enable-cxx
MPDECIMAL_OPT+= --disable-doc
#MPDECIMAL_OPT+= $(OPT_FLAGS)
MPDECIMAL_OPT+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg/mpdecimal.cpio.zst: src/mpdecimal-$(MPDECIMAL_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/mpdecimal
	mkdir -p tmp/mpdecimal/bld
	tar -xzf $< -C tmp/mpdecimal
	cp -vf tmp/mpdecimal/mpdecimal-$(MPDECIMAL_VER)/configure tmp/mpdecimal/
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/mpdecimal/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/mpdecimal/configure
	cp -vf tmp/mpdecimal/configure tmp/mpdecimal/mpdecimal-$(MPDECIMAL_VER)/
	cd tmp/mpdecimal/bld && ../mpdecimal-$(MPDECIMAL_VER)/configure $(MPDECIMAL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mpdecimal/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_LIB) tmp/mpdecimal/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/mpdecimal/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mpdecimal
src/mpdecimal-$(MPDECIMAL_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-$(MPDECIMAL_VER).tar.gz && touch $@
