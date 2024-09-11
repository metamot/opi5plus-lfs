SRC+=src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz
SRC+=src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch
PKG+=pkg/net-tools.cpio.zst
net-tools: pkg/net-tools.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/net-tools.cpio.zst: src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch pkg/gzip.cpio.zst 
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/net-tools
	mkdir -p tmp/net-tools
	tar -xzf $< -C tmp/net-tools
	cp -far src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch tmp/net-tools/
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && patch -Np1 -i ../net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch
	sed -i '/#include <netinet\/ip.h>/d' tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER)/iptunnel.c
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER)/Makefile
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && yes "" | make config
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && make $(JOBS)
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && make BASEDIR=`pwd`/../ins update
	rm -fr tmp/net-tools/ins/usr/share
	mv tmp/net-tools/ins/bin tmp/net-tools/ins/usr/
	mv tmp/net-tools/ins/sbin tmp/net-tools/ins/usr/
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/net-tools/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/net-tools/ins/usr/sbin/* || true
endif
	mkdir -p pkg && cd tmp/net-tools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/net-tools
src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz: src/.gitignore
	wget -P src http://anduin.linuxfromscratch.org/BLFS/net-tools/net-tools-CVS_$(NET_TOOLS_VER).tar.gz && touch $@
#--no-check-certificate
src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch && touch $@

