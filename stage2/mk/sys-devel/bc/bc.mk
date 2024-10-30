SRC+= src/bc-$(BC_VER).tar.xz
PKG+= pkg/bc.cpio.zst
bc: pkg/bc.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BC_OPT+= --disable-man-pages
BC_OPT+= --disable-nls
pkg/bc.cpio.zst: src/bc-$(BC_VER).tar.xz pkg/ncurses.cpio.zst pkg/readline.cpio.zst
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/bc
	mkdir -p tmp/bc
	tar -xJf $< -C tmp/bc
	cd tmp/bc/bc-$(BC_VER) && PREFIX=/usr CC=gcc CFLAGS="-std=c99 $(RK3588_FLAGS)" ./configure.sh $(BC_OPT) -G $(BASE_OPT_VALUE) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/bc/ins/usr/bin/bc
endif
	mkdir -p pkg && cd tmp/bc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/bc
src/bc-$(BC_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://github.com/gavinhoward/bc/releases/download/$(BC_VER)/bc-$(BC_VER).tar.xz && touch $@
