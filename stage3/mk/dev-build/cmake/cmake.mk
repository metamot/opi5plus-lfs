SRC+=src/cmake-$(CMAKE_VER).tar.gz
PKG+=pkg/cmake.cpio.zst
cmake: pkg/cmake.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
CMAKE_BOPT+= --prefix=/usr
CMAKE_BOPT+= --system-libs
CMAKE_BOPT+= --mandir=/share/man
CMAKE_BOPT+= --no-system-jsoncpp
CMAKE_BOPT+= --no-system-librhash
CMAKE_BOPT+= --docdir=/share/doc/cmake-$(CMAKE_VER)
CMAKE_BOPT+= --no-system-curl
CMAKE_BOPT+= --no-system-nghttp2
CMAKE_BOPT+= --parallel=$(JOB)
CMAKE_BOPT+= --verbose
pkg/cmake.cpio.zst: src/cmake-$(CMAKE_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/cmake
	mkdir -p tmp/cmake
	tar -xzf $< -C tmp/cmake
	sed -i '/"lib64"/s/64//' tmp/cmake/cmake-$(CMAKE_VER)/Modules/GNUInstallDirs.cmake
	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/cmake/cmake-$(CMAKE_VER)/Modules/Compiler/GNU.cmake
	cd tmp/cmake/cmake-$(CMAKE_VER) && ./bootstrap $(CMAKE_BOPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/cmake/ins/usr/share/doc
	rm -fr tmp/cmake/ins/usr/share/emacs
	rm -fr tmp/cmake/ins/usr/share/vim
	rm -fr tmp/cmake/ins/usr/share/cmake-$(CMAKE_VER0)/Help
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/cmake/ins/usr/bin/*
endif
	mkdir -p pkg && cd tmp/cmake/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/cmake
src/make-$(MAKE_VER).tar.gz: src/.gitignore
	wget -P src https://cmake.org/files/v$(CMAKE_VER0)/cmake-$(CMAKE_VER).tar.gz && touch $@
#--no-check-certificate

