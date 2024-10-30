SRC+=src/perl-$(PERL_VER).tar.xz
PKG+=pkg/perl.cpio.zst
perl: pkg/perl.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
PERL_POPT+= -des
PERL_POPT+= -Dprefix=/usr
PERL_POPT+= -Dvendorprefix=/usr
PERL_POPT+= -Dprivlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT+= -Darchlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT+= -Dsitelib=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT+= -Dsitearch=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT+= -Dvendorlib=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT+= -Dvendorarch=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT+= -Dman1dir=/usr/share/man/man1
PERL_POPT+= -Dman3dir=/usr/share/man/man3
PERL_POPT+= -Dpager="/usr/bin/less -isR"
PERL_POPT+= -Duseshrplib
PERL_POPT+= -Dusethreads
PERL_POPT+= -Doptimize="$(BASE_OPT_FLAGS)"
pkg/perl.cpio.zst: src/perl-$(PERL_VER).tar.xz pkg/zlib.cpio.zst pkg/bzip2.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst pkg/grep.cpio.zst pkg/db.cpio.zst pkg/gdbm.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/libseccomp.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/libpcre.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
#	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/db.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/ncurses.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/readline.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gdbm.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/perl
	mkdir -p tmp/perl
	tar -xJf $< -C tmp/perl
	cd tmp/perl/perl-$(PERL_VER) && sh Configure $(PERL_POPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/perl/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/perl/ins/usr && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p pkg && cd tmp/perl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/perl
src/perl-$(PERL_VER).tar.xz: src/.gitignore
	wget -P src --no-check-certificate https://www.cpan.org/src/5.0/perl-$(PERL_VER).tar.xz && touch $@
