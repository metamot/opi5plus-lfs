SRC+=src/bash-$(BASH_VER).tar.gz
SRC+=src/bash-$(BASH_VER)-upstream_fixes-1.patch
PKG+=pkg/bash.cpio.zst
bash: pkg/bash.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
BASH_OPT+= --prefix=/usr
BASH_OPT+= --without-bash-malloc
BASH_OPT+= --with-installed-readline
BASH_OPT+= --disable-nls
BASH_OPT+= $(OPT_FLAGS)
pkg/bash.cpio.zst: src/bash-$(BASH_VER).tar.gz src/bash-$(BASH_VER)-upstream_fixes-1.patch pkg/gzip.cpio.zst pkg/grep.cpio.zst pkg/findutils.cpio.zst pkg/file.cpio.zst
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/zlib.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/xz-utils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/grep.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/findutils.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/file.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/bash
	mkdir -p tmp/bash/bld
	tar -xzf pkg/bash-$(BASH_VER).tar.gz -C tmp/bash
	cp pkg/bash-$(BASH_VER)-upstream_fixes-1.patch tmp/bash/
	cd tmp/bash/bash-$(BASH_VER) && patch -Np1 -i ../bash-$(BASH_VER)-upstream_fixes-1.patch
	cd tmp/bash/bld && ../bash-$(BASH_VER)/configure $(BASH_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/bash/ins/usr/share
	cd tmp/bash/ins/usr/bin && ln -sf bash sh
ifeq ($(BUILD_STRIP),y)
	cd tmp/bash/ins/usr && strip $(STRIP_BUILD_BIN) $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p pkg && cd tmp/bash/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/bash
src/bash-$(BASH_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz && touch $@
# --no-check-certificate
src/bash-$(BASH_VER)-upstream_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bash-$(BASH_VER)-upstream_fixes-1.patch && touch $@
# --no-check-certificate


