SRC+=src/re2c-$(RE2C_VER).tar.gz
PKG+=pkg/re2c.cpio.zst
re2c: pkg/re2c.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
RE2C_OPT+= --prefix=/usr
RE2C_OPT+= $(OPT_FLAGS)
pkg/re2c.cpio.zst: src/re2c-$(RE2C_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/re2c
	mkdir -p tmp/re2c/bld
	tar -xzf $< -C tmp/re2c
	cd tmp/re2c/re2c-$(RE2C_VER) && autoreconf -i -W all
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/re2c/re2c-$(RE2C_VER)/configure
	cd tmp/re2c/bld && ../re2c-$(RE2C_VER)/configure $(RE2C_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/re2c/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/re2c/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/re2c/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/re2c
src/re2c-$(RE2C_VER).tar.gz: src/.gitignore
	wget -O src/re2c-$(RE2C_VER).tar.gz https://github.com/skvadrik/re2c/archive/refs/tags/$(RE2C_VER).tar.gz && touch $@
#--no-check-certificate

