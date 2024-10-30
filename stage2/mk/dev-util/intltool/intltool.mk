SRC+=src/intltool-$(INTL_TOOL_VER).tar.gz
PKG+=pkg/intltool.cpio.zst
intltool: pkg/intltool.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
INTLTOOL_OPT+= --prefix=/usr
#INTLTOOL_OPT+= $(OPT_FLAGS)
pkg/intltool.cpio.zst: src/intltool-$(INTL_TOOL_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/intltool
	mkdir -p tmp/intltool/bld
	tar -xzf $< -C tmp/intltool
	sed -i 's:\\\$${:\\\$$\\{:' tmp/intltool/intltool-$(INTL_TOOL_VER)/intltool-update.in
	cd tmp/intltool/bld && ../intltool-$(INTL_TOOL_VER)/configure $(INTLTOOL_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/intltool/ins/usr/share/man
	mkdir -p pkg && cd tmp/intltool/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/intltool
src/intltool-$(INTL_TOOL_VER).tar.gz: src/.gitignore
	wget -P src https://launchpad.net/intltool/trunk/$(INTL_TOOL_VER)/+download/intltool-$(INTL_TOOL_VER).tar.gz && touch $@
#--no-check-certificate

