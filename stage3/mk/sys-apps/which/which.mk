SRC+=src/which-$(WHICH_VER).tar.gz
PKG+=pkg/which.cpio.zst
which: pkg/which.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
WHICH_OPT+= --prefix=/usr
WHICH_OPT+= $(OPT_FLAGS)
pkg/which.cpio.zst: src/which-$(WHICH_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/which
	mkdir -p tmp/which/bld
	tar -xzf $< -C tmp/which
	cd tmp/which/bld && ../which-$(WHICH_VER)/configure $(WHICH_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/which/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/which/ins/usr/bin/which
endif
	mkdir -p pkg && cd tmp/which/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/which
src/which-$(WHICH_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/which/which-$(WHICH_VER).tar.gz && touch $@
#--no-check-certificate

# -------------------
# "Which" alternative
pkg/which-scr.cpio.zst:
	rm -fr tmp/which
	mkdir -p tmp/which/ins/usr/bin
	echo '#!/bin/bash' > tmp/which/ins/usr/bin/which
	echo 'type -pa "$$@" | head -n 1 ; exit $${PIPESTATUS[0]}' >> tmp/which/ins/usr/bin/which
	chmod -v 755 tmp/which/ins/usr/bin/which
	chown -v root:root tmp/which/ins/usr/bin/which
	mkdir -p pkg && cd tmp/which/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/which

