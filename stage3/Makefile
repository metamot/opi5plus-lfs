all: help

include mk/_versions.mk
include mk/_general.mk





include mk/sys-devel/gnuconfig/gnuconfig.mk
include mk/sys-libs/zlib/zlib.mk
include mk/app-arch/gzip/gzip.mk
include mk/app-arch/zstd/zstd.mk
include mk/sys-apps/attr/attr.mk
include mk/sys-apps/acl/acl.mk
include mk/sys-devel/patch/patch.mk
include mk/app-arch/bzip2/bzip2.mk
include mk/app-arch/xz-utils/xz-utils.mk
include mk/app-arch/lz4/lz4.mk
include mk/app-arch/zstd/zstd-max.mk
include mk/app-arch/cpio/cpio.mk
include mk/sys-apps/pv/pv.mk
include mk/app-arch/tar/tar.mk
include mk/sys-apps/file/file.mk
include mk/sys-apps/file/file-med.mk
include mk/sys-apps/diffutils/diffutils.mk
include mk/sys-apps/grep/grep.mk
include mk/dev-util/pkgconfig/pkgconfig.mk
include mk/sys-libs/ncurses/ncurses.mk
include mk/sys-libs/readline/readline.mk
include mk/sys-devel/m4/m4.mk
include mk/dev-libs/gmp/gmp.mk
include mk/dev-libs/isl/isl.mk
include mk/dev-libs/mpfr/mpfr.mk
include mk/dev-libs/mpc/mpc.mk
include mk/sys-devel/bc/bc.mk
include mk/sys-devel/flex/flex.mk
include mk/dev-lang/tcl/tcl.mk
include mk/dev-tcltk/expect/expect.mk
include mk/sys-apps/findutils/findutils.mk
include mk/dev-lang/perl/perl.mk
include mk/sys-apps/sed/sed.mk
include mk/dev-libs/openssl/openssl.mk
include mk/sys-apps/help2man/help2man.mk
include mk/dev-build/autoconf/autoconf.mk
include mk/dev-build/automake/automake.mk
include mk/sys-devel/bison/bison.mk
#include mk/dev-util/byacc
#include mk/dev-util/yacc
#app-alternatives
include mk/sys-devel/binutils/binutils.mk

#include mk/dev-libs/boehm-gc/boehm-gc.mk #libgc1
include mk/sys-devel/gcc/gcc.mk


include mk/sys-apps/gawk/gawk.mk
include mk/sys-apps/texinfo/texinfo.mk
include mk/dev-libs/expat/expat.mk
include mk/sys-devel/gettext/gettext.mk

#include mk/sys-apps/gawk/gawk-max.mk


#include mk/sys-libs/db.mk
#include mk/sys-libs/gdbm.mk
#include mk/dev-libs/libsigsegv.mk
#include mk/app-crypt/libmd.mk
#include mk/dev-libs/libbsd.mk
#include mk/dev-libs/libedit.mk
#include mk/dev-libs/libpcre.mk
#include mk/dev-libs/libpcre2.mk
#include mk/sys-apps/grep-with-pcre2.mk

#include mk/dev-libs/elfutils.mk
#include mk/dev-util/dejagnu.mk
#include mk/dev-libs/libffi.mk

#include mk/dev-lang/python3.mk
#include mk/dev-lang/python2.mk
#include mk/net-misc/wget.mk


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
