SRC+=src/meson-$(MESON_VER).tar.gz
PKG+=pkg/meson.cpio.zst
meson: pkg/meson.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/meson.cpio.zst: src/meson-$(MESON_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/meson
	mkdir -p tmp/meson
	tar -xzf $< -C tmp/meson
	cd tmp/meson/meson-$(MESON_VER) && python3 setup.py build && python3 setup.py install --root=OUT
	rm -fr tmp/meson/meson-$(MESON_VER)/OUT/usr/share/man
	mkdir -p tmp/meson/ins
	cp -far tmp/meson/meson-$(MESON_VER)/OUT/usr tmp/meson/ins/
	mkdir -p pkg && cd tmp/meson/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/meson
src/meson-$(MESON_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/mesonbuild/meson/releases/download/$(MESON_VER)/meson-$(MESON_VER).tar.gz && touch $@
#--no-check-certificate
