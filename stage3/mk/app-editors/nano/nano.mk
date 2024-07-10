SRC+=src/nano-$(NANO_VER).tar.xz
PKG+=pkg/nano.cpio.zst
nano: pkg/nano.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
NANO_OPT+= --prefix=/usr
NANO_OPT+= --sysconfdir=/etc
NANO_OPT+= --enable-utf8
NANO_OPT+= --docdir=/usr/share/doc/nano-$(NANO_VER)
NANO_OPT+= --disable-nls
NANO_OPT+= $(OPT_FLAGS)
pkg/nano.cpio.zst: src/nano-$(NANO_VER).tar.xz
	rm -fr tmp/nano
	mkdir -p tmp/nano/bld
	tar -xJf $< -C tmp/nano
	cd tmp/nano/bld && ../nano-$(NANO_VER)/configure $(NANO_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/nano/ins/usr/share/doc
	rm -fr tmp/nano/ins/usr/share/info
	rm -fr tmp/nano/ins/usr/share/man
	mkdir -p tmp/nano/ins/etc
	echo 'set autoindent' > tmp/nano/ins/etc/nanorc
	echo 'set linenumbers' >> tmp/nano/ins/etc/nanorc
	echo 'set smooth' >> tmp/nano/ins/etc/nanorc
	echo 'set mouse' >> tmp/nano/ins/etc/nanorc
	echo 'set tabsize 4' >> tmp/nano/ins/etc/nanorc
	echo 'set titlecolor red,green' >> tmp/nano/ins/etc/nanorc
#	echo 'set constantshow' >> tmp/nano/ins/etc/nanorc
#	echo 'set fill 72' >> tmp/nano/ins/etc/nanorc
#	echo 'set historylog' >> tmp/nano/ins/etc/nanorc
#	echo 'set multibuffer' >> tmp/nano/ins/etc/nanorc
#	echo 'set positionlog' >> tmp/nano/ins/etc/nanorc
#	echo 'set quickblank' >> tmp/nano/ins/etc/nanorc
#	echo 'set regexp' >> tmp/nano/ins/etc/nanorc
#	echo 'set suspend' >> tmp/nano/ins/etc/nanorc
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/nano/ins/usr/bin/nano
endif
	mkdir -p pkg && cd tmp/nano/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/nano
src/nano-$(NANO_VER).tar.xz: src/.gitignore
#	wget -P src https://www.nano-editor.org/dist/v5/nano-$(NANO_VER).tar.xz && touch $@
	wget -P src https://ftp.gnu.org/gnu/nano/nano-$(NANO_VER).tar.xz && touch $@
#--no-check-certificate

