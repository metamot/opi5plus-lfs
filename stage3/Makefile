all: help

include mk/_versions.mk
include mk/_general.mk





include mk/sys-devel/gnuconfig.mk
include mk/app-arch/gzip.mk
include mk/sys-apps/attr.mk
include mk/sys-apps/acl.mk
include mk/sys-devel/patch.mk
include mk/app-arch/bzip2.mk
include mk/app-arch/xz-utils.mk
include mk/app-arch/lz4.mk
include mk/sys-libs/zlib.mk
include mk/app-arch/zstd.mk
include mk/app-arch/cpio.mk
include mk/sys-apps/pv.mk
include mk/app-arch/tar.mk
include mk/sys-apps/file.mk
include mk/sys-apps/diffutils.mk
include mk/sys-apps/grep.mk
include mk/dev-util/pkgconfig.mk
include mk/sys-libs/ncurses.mk
include mk/sys-libs/readline.mk
include mk/sys-devel/m4.mk
include mk/sys-devel/bc.mk
include mk/sys-devel/flex.mk
include mk/dev-lang/tcl.mk
include mk/sys-libs/db.mk
include mk/sys-libs/gdbm.mk
include mk/sys-apps/findutils.mk
include mk/dev-lang/perl.mk
include mk/sys-apps/sed.mk
include mk/sys-devel/bison.mk
include mk/dev-libs/libsigsegv.mk
include mk/app-crypt/libmd.mk
include mk/dev-libs/libbsd.mk
include mk/dev-libs/libedit.mk
include mk/dev-libs/libpcre.mk
include mk/dev-libs/libpcre2.mk
include mk/sys-apps/grep-with-pcre2.mk
include mk/dev-libs/gmp.mk
include mk/dev-libs/isl.mk
include mk/dev-libs/mpfr.mk
include mk/dev-libs/mpc.mk
include mk/sys-apps/gawk.mk
include mk/sys-apps/help2man.mk
include mk/dev-build/autoconf.mk
include mk/dev-build/automake.mk
include mk/dev-libs/elfutils.mk
include mk/dev-tcltk/expect.mk
include mk/sys-apps/texinfo.mk
include mk/dev-util/dejagnu.mk
include mk/dev-libs/libffi.mk
include mk/dev-libs/expat.mk
include mk/dev-libs/openssl.mk
include mk/sys-devel/binutils.mk

include mk/dev-lang/python3.mk
include mk/dev-lang/python2.mk
include mk/net-misc/wget.mk

help:
	@echo VERB=$(VERB)
	@echo JOBS=$(JOBS)
	@echo GIT_RM=$(GIT_RM)
	@echo BUILD_STRIP=$(BUILD_STRIP)
	@echo RUN_TESTS=$(RUN_TESTS)
	@echo RK3588_ARCH=$(RK3588_ARCH)
	@echo RK3588_FLAGS=$(RK3588_FLAGS)
	@echo BASE_OPT_VALUE=$(BASE_OPT_VALUE)
	@echo BASE_OPT_FLAGS=$(BASE_OPT_FLAGS)
	@echo OPT_FLAGS=$(OPT_FLAGS)
	@echo TODAY_CODE=$(TODAY_CODE)
	@echo STRIP_BUILD_BIN=$(STRIP_BUILD_BIN)
	@echo STRIP_BUILD_LIB=$(STRIP_BUILD_LIB)
	@echo STRIP_BUILD_AST=$(STRIP_BUILD_AST)
	@echo SRC=$(SRC)
	@echo PKG=$(PKG)

src: $(SRC)

pkg: $(PKG)
