# groupadd -g 48 rsyncd && useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd -s /bin/false -u 48 rsyncd
SRC+=src/rsync-$(RSYNC_VER).tar.gz
PKG+=pkg/rsync.cpio.zst
rsync: pkg/rsync.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
RSYNC_OPT+= --prefix=/usr
RSYNC_OPT+= --disable-lz4
RSYNC_OPT+= --disable-xxhash
RSYNC_OPT+= --without-included-zlib
RSYNC_OPT+= $(OPT_FLAGS)
pkg/rsync.cpio.zst: src/rsync-$(RSYNC_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/rsync
	mkdir -p tmp/rsync/bld
	tar -xzf $< -C tmp/rsync
	cd tmp/rsync/bld && ../rsync-$(RSYNC_VER)/configure $(RSYNC_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/rsync/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/rsync/ins/usr/bin/rsync
endif
	mkdir -p pkg && cd tmp/rsync/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/rsync
src/rsync-$(RSYNC_VER).tar.gz: src/.gitignore
	wget -P src https://www.samba.org/ftp/rsync/src/rsync-$(RSYNC_VER).tar.gz && touch $@
#--no-check-certificate

