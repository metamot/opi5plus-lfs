SRC+=src/grep-$(GREP_VER).tar.xz
PKG+=pkg/grep.cpio.zst
grep: pkg/grep.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GREP_OPT+= --prefix=/usr
GREP_OPT+= --disable-nls
GREP_OPT+= --disable-perl-regexp
GREP_OPT+= $(OPT_FLAGS)
pkg/grep.cpio.zst: src/grep-$(GREP_VER).tar.xz
	rm -fr tmp/grep
	mkdir -p tmp/grep/bld
	tar -xJf $< -C tmp/grep
	cd tmp/grep/bld && ../grep-$(GREP_VER)/configure $(GREP_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/grep/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/grep/ins/usr/bin/grep
endif
	mkdir -p pkg && cd tmp/grep/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/grep
src/grep-$(GREP_VER).tar.xz: src/.gitignore
	wget --no-check-certificate -P src http://ftp.gnu.org/gnu/grep/grep-$(GREP_VER).tar.xz && touch $@
