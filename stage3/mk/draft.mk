SRC+=src/texinfo-$(TEXINFO_VER).tar.xz
PKG+=pkg/texinfo.cpio.zst
texinfo: pkg/texinfo.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/texinfo.cpio.zst: src/texinfo-$(TEXINFO_VER).tar.xz
#	cat pkg/gettext.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
$(STRIP_BUILD_BIN)

src/texinfo-$(TEXINFO_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.xz && touch $@
#--no-check-certificate

