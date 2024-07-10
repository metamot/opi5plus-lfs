SRC+=src/db-$(DB_VER).tar.gz
PKG+=pkg/db.cpio.zst
db: pkg/db.cpio.zst
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
DB_OPT+= --prefix=/usr
DB_OPT+= --enable-compat185
DB_OPT+= --enable-dbm
DB_OPT+= --disable-static
DB_OPT+= --enable-cxx
DB_OPT+= --enable-tcl
DB_OPT+= --with-tcl=/usr/lib
DB_OPT+= $(OPT_FLAGS)
pkg/db.cpio.zst: src/db-$(DB_VER).tar.gz pkg/gzip.cpio.zst src/config.guess src/config.sub pkg/tcl.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	cat pkg/tcl.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/db
	mkdir -p tmp/db/bld
	tar -xzf $< -C tmp/db
	sed -i 's/\(__atomic_compare_exchange\)/\1_db/' tmp/db/db-$(DB_VER)/src/dbinc/atomic.h
	cp -f src/config.guess tmp/db/db-$(DB_VER)/dist/
	chmod ugo+x tmp/db/db-$(DB_VER)/dist/config.guess
	cp -f src/config.sub tmp/db/db-$(DB_VER)/dist/
	chmod ugo+x tmp/db/db-$(DB_VER)/dist/config.sub
	cd tmp/db/bld && ../db-$(DB_VER)/dist/configure $(DB_OPT) && make $(JOBS) V=$(VERB) && make docdir=/usr/share/doc/db-$(DB_VER) DESTDIR=`pwd`/../ins install
	rm -fr tmp/db/ins/usr/share
	rm -f  tmp/db/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/db/ins/usr/bin/* || true
	strip $(STRIP_BUILD_LIB) tmp/db/ins/usr/lib/*.so*
endif
	mkdir -p pkg && cd tmp/db/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/db
src/db-$(DB_VER).tar.gz: src/.gitignore
	wget -P src --no-check-certificate http://anduin.linuxfromscratch.org/BLFS/bdb/db-$(DB_VER).tar.gz && touch $@
