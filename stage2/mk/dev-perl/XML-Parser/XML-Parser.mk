SRC+=src/XML-Parser-$(XML_PARSER_VER).tar.gz
PKG+=pkg/XML-Parser.cpio.zst
XML-Parser: pkg/XML-Parser.cpio.zst
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/XML-Parser.cpio.zst: src/XML-Parser-$(XML_PARSER_VER).tar.gz
# pkg/gzip.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/perl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/expat.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/XML-Parser
	mkdir -p tmp/XML-Parser
	tar -xzf $< -C tmp/XML-Parser
	cd tmp/XML-Parser/XML-Parser-$(XML_PARSER_VER) && perl Makefile.PL && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/XML-Parser/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/XML-Parser/ins && strip $(STRIP_BUILD_ELF) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p pkg && cd tmp/XML-Parser/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/XML-Parser
src/XML-Parser-$(XML_PARSER_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-$(XML_PARSER_VER).tar.gz && touch $@
