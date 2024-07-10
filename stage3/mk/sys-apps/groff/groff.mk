SRC+=src/groff-$(GROFF_VER).tar.gz
PKG+=pkg/groff.cpio.zst
groff: pkg/groff.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
GROFF_PREP_OPT+= PAGE=A4
GROFF_OPT+= --prefix=/usr
GROFF_OPT+= $(OPT_FLAGS)
pkg/groff.cpio.zst: src/groff-$(GROFF_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/groff
	mkdir -p tmp/groff/bld
	tar -xzf $< -C tmp/groff
	cd tmp/groff/bld && $(GROFF_PREP_OPT) ../groff-$(GROFF_VER)/configure $(GROFF_OPT) && make -j1 V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/groff/ins/usr/share/doc
	rm -fr tmp/groff/ins/usr/share/info
	rm -fr tmp/groff/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/groff/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/groff/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/groff
src/groff-$(GROFF_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/groff/groff-$(GROFF_VER).tar.gz && touch $@
#--no-check-certificate



