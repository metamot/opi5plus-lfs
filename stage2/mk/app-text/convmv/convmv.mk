# EXTRA: this pkg reccommended on UnZip LFS-page
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/unzip.html
# see ... Workaround2: Use 'bsdtar -xf' (from libarchive) for unpack zip-files with convmv-fixing
#### The following is an example for the zh_CN.UTF-8 locale:
#### convmv -f cp936 -t utf-8 -r --nosmart --notest </path/to/unzipped/files>
SRC+=src/convmv-$(CONVMV_VER).tar.gz
PKG+=pkg/convmv.cpio.zst
convmv: pkg/convmv.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/convmv.cpio.zst: src/convmv-$(CONVMV_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/convmv
	mkdir -p tmp/convmv
	tar -xzf $< -C tmp/convmv
	mkdir -p tmp/convmv/ins/usr/bin
	cp -f tmp/convmv/convmv-$(CONVMV_VER)/convmv tmp/convmv/ins/usr/bin
	chown root:root tmp/convmv/ins/usr/bin/convmv
# Target is the single PERL file!
	mkdir -p pkg && cd tmp/convmv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/convmv
src/convmv-$(CONVMV_VER).tar.gz: src/.gitignore
	wget -P src https://j3e.de/linux/convmv/convmv-$(CONVMV_VER).tar.gz && touch $@
#--no-check-certificate

