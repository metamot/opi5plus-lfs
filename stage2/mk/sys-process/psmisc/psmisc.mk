SRC+=src/psmisc-$(PSMISC_VER).tar.xz
PKG+=pkg/psmisc.cpio.zst
psmisc: pkg/psmisc.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PSMISC_OPT+= --prefix=/usr
PSMISC_OPT+= --disable-nls
PSMISC_OPT+= $(OPT_FLAGS)
pkg/psmisc.cpio.zst: src/psmisc-$(PSMISC_VER).tar.xz
	rm -fr tmp/psmisc
	mkdir -p tmp/psmisc/bld
	tar -xJf pkg/psmisc-$(PSMISC_VER).tar.xz -C tmp/psmisc
	cd tmp/psmisc/bld && ../psmisc-$(PSMISC_VER)/configure $(PSMISC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/psmisc/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/psmisc/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/psmisc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/psmisc
src/psmisc-$(PSMISC_VER).tar.xz: src/.gitignore
	wget -P src https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-$(PSMISC_VER).tar.xz && touch $@
# --no-check-certificate

