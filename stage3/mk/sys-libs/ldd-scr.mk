PKG+=pkg/ldd-scr.cpio.zst
ldd-scr: pkg/ldd-scr.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/ldd-scr.cpio.zst:
	rm -fr tmp/ldd
	mkdir -p tmp/ldd
	echo '#!/bin/sh' > tmp/ldd/ldd
	echo 'for file in "$$@"; do' >> tmp/ldd/ldd
	echo '  case $$file in' >> tmp/ldd/ldd
	echo '  --version) echo $$(/lib/libc.so.6|awk "NF>1{print $$NF; exit }")' >> tmp/ldd/ldd
	echo '	break' >> tmp/ldd/ldd
	echo '	;;' >> tmp/ldd/ldd
	echo '  */*) true' >> tmp/ldd/ldd
	echo '	;;' >> tmp/ldd/ldd
	echo '  *) file=./$$file' >> tmp/ldd/ldd
	echo '	;;' >> tmp/ldd/ldd
	echo '  esac' >> tmp/ldd/ldd
	echo 'echo EXAMINE ::: $$file' >> tmp/ldd/ldd
	echo 'LD_TRACE_LOADED_OBJECTS=1 /lib/ld-linux* "$$file"' >> tmp/ldd/ldd
	echo 'done' >> tmp/ldd/ldd
	chmod ugo+x tmp/ldd/ldd
	mkdir -p pkg && cd tmp/ldd && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../$@
	rm -fr tmp/ldd

