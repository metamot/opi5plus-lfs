SRC+=src/dejagnu-$(DEJAGNU_VER).tar.gz
PKG+=pkg/dejagnu.cpio.zst
dejagnu: pkg/dejagnu.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DEJAGNU_OPT+= --prefix=/usr
DEJAGNU_OPT+= $(OPT_FLAGS)
pkg/dejagnu.cpio.zst: src/dejagnu-$(DEJAGNU_VER).tar.gz pkg/gzip.cpio.zst pkg/expect.cpio.zst pkg/gawk.cpio.zst pkg/texinfo.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expect.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/libsigsegv.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gmp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/mpfr.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/texinfo.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/dejagnu
	mkdir -p tmp/dejagnu/bld
	tar -xzf $< -C tmp/dejagnu
	cd tmp/dejagnu/bld && ../dejagnu-$(DEJAGNU_VER)/configure $(DEJAGNU_OPT)
	cd tmp/dejagnu/bld && makeinfo --html --no-split -o doc/dejagnu.html ../dejagnu-$(DEJAGNU_VER)/doc/dejagnu.texi
	cd tmp/dejagnu/bld && makeinfo --plaintext       -o doc/dejagnu.txt  ../dejagnu-$(DEJAGNU_VER)/doc/dejagnu.texi
	cd tmp/dejagnu/bld && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/dejagnu/ins/usr/share/info
	rm -fr tmp/dejagnu/ins/usr/share/man
	rm -fr tmp/dejagnu/ins/usr/share/dejagnu/baseboards/README
	rm -fr tmp/dejagnu/ins/usr/share/dejagnu/config/README
#	mkdir -p pkg && cd tmp/dejagnu/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/dejagnu
src/dejagnu-$(DEJAGNU_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/dejagnu/dejagnu-$(DEJAGNU_VER).tar.gz && touch $@
#--no-check-certificate

