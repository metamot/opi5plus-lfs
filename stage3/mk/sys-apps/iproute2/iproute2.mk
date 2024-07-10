SRC+=src/iproute2-$(IP_ROUTE2_VER).tar.xz
PKG+=pkg/iproute2.cpio.zst
iproute2: pkg/iproute2.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/iproute2.cpio.zst: src/iproute2-$(IP_ROUTE2_VER).tar.xz
	rm -fr tmp/iproute2
	mkdir -p tmp/iproute2
	tar -xJf $< -C tmp/iproute2
	sed -i 's/.m_ipt.o//' tmp/iproute2/iproute2-$(IP_ROUTE2_VER)/tc/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/iproute2/iproute2-$(IP_ROUTE2_VER)/Makefile
# libc has setns: yes
# ELF support: yes
# need for strlcpy: yes
# libcap support: yes
# Berkeley DB: yes
# libmnl support: yes
### ATM	no
### SELinux support: no
	cd tmp/iproute2/iproute2-$(IP_ROUTE2_VER) && make $(JOBS) V=$(VERB) && make DOCDIR=/usr/share/doc/iproute2-$(IP_ROUTE2_VER) DESTDIR=`pwd`/../ins install
	mv -fv tmp/iproute2/ins/sbin tmp/iproute2/ins/usr/
	rm -fr tmp/iproute2/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/iproute2/ins/usr/sbin/* || true
endif
	mkdir -p pkg && cd tmp/iproute2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/iproute2
src/iproute2-$(IP_ROUTE2_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$(IP_ROUTE2_VER).tar.xz && touch $@
#--no-check-certificate



