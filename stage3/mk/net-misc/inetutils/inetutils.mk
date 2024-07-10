SRC+=src/inetutils-$(INET_UTILS_VER).tar.xz
PKG+=pkg/inetutils.cpio.zst
inetutils: pkg/inetutils.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
INETUTILS_OPT+= --prefix=/usr
INETUTILS_OPT+= --localstatedir=/var
INETUTILS_OPT+= --disable-logger
INETUTILS_OPT+= --disable-whois
INETUTILS_OPT+= --disable-rcp
INETUTILS_OPT+= --disable-rexec
INETUTILS_OPT+= --disable-rlogin
INETUTILS_OPT+= --disable-rsh
INETUTILS_OPT+= --disable-servers
INETUTILS_OPT+= $(OPT_FLAGS)
pkg/inetutils.cpio.zst: src/inetutils-$(INET_UTILS_VER).tar.xz
	rm -fr tmp/inetutils
	mkdir -p tmp/inetutils/bld
	tar -xJf pkg/inetutils-$(INET_UTILS_VER).tar.xz -C tmp/inetutils
	cd tmp/inetutils/bld && ../inetutils-$(INET_UTILS_VER)/configure $(INETUTILS_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/inetutils/ins/usr/share
	rm -fr tmp/inetutils/ins/usr/libexec
# libexec is empty
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/inetutils/ins/usr/bin/* || true
endif
	mkdir -p pkg && cd tmp/inetutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/inetutils
src/inetutils-$(INET_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/inetutils/inetutils-$(INET_UTILS_VER).tar.xz && touch $@
#--no-check-certificate

