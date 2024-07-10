# make
PKG+=bzip2
all: $(PKG)
bzip2:
	cat pkg/bzip2.cpio.zst | zstd -d | cpio -idmH newc --quiet -D / > /dev/null 2>&1
