SRC+=src/mailcap-$(MIME_TYPES_VER).tar.gz
PKG+=pkg/mime-types.cpio.zst
mime-types: pkg/mime-types.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/mime-types.cpio.zst: src/mailcap-$(MIME_TYPES_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/mime-types
	mkdir -p tmp/mime-types
	tar -xzf $< -C tmp/mime-types
	cd tmp/mime-types/mailcap-$(MIME_TYPES_VER) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mime-types/ins/usr
	mkdir -p pkg && cd tmp/mime-types/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mime-types
src/mailcap-$(MIME_TYPES_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate https://pagure.io/mailcap/archive/$(MIME_TYPES_VER)/mailcap-$(MIME_TYPES_VER).tar.gz && touch $@
