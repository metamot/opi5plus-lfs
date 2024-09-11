SRC+=src/ninja-$(NINJA_VER).tar.gz
PKG+=pkg/ninja.cpio.zst
ninja: pkg/ninja.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
pkg/ninja.cpio.zst: src/ninja-$(NINJA_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/ninja
	mkdir -p tmp/ninja
	tar -xzf $< -C tmp/ninja
	sed -i '/int Guess/a   int   j = 0;  char* jobs = getenv( "NINJAJOBS" );  if ( jobs != NULL ) j = atoi( jobs );  if ( j > 0 ) return j;' tmp/ninja/ninja-$(NINJA_VER)/src/ninja.cc
	sed -i 's/-O2/$(BASE_OPT_VALUE)/' tmp/ninja/ninja-$(NINJA_VER)/configure.py
# FROM:
## int GuessParallelism() {
##  switch (int processors = GetProcessorCount()) {
#   TO:
## int GuessParallelism() {
#> int   j = 0;  char* jobs = getenv( "NINJAJOBS" );  if ( jobs != NULL ) j = atoi( jobs );  if ( j > 0 ) return j;
##  switch (int processors = GetProcessorCount()) {
### ----------
	cd tmp/ninja/ninja-$(NINJA_VER) && sh -c 'export NINJAJOBS=$(JOB) && CFLAGS=$(RK3588_FLAGS) python3 -v configure.py --bootstrap --verbose'
	mkdir -p tmp/ninja/ins/usr/bin
	mkdir -p tmp/ninja/ins/usr/share/bash-completion/completions/ninja
	mkdir -p tmp/ninja/ins/usr/share/zsh/site-functions/_ninja
	install -vm755 tmp/ninja/ninja-$(NINJA_VER)/ninja tmp/ninja/ins/usr/bin
	install -vDm644 tmp/ninja/ninja-$(NINJA_VER)/misc/bash-completion tmp/ninja/ins/usr/share/bash-completion/completions/ninja
	install -vDm644 tmp/ninja/ninja-$(NINJA_VER)/misc/zsh-completion tmp/ninja/ins/usr/share/zsh/site-functions/_ninja
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/ninja/ins/usr/bin/ninja
endif
	mkdir -p pkg && cd tmp/ninja/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/ninja
src/ninja-$(NINJA_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/ninja-build/ninja/archive/v$(NINJA_VER)/ninja-$(NINJA_VER).tar.gz && touch $@
#--no-check-certificate
