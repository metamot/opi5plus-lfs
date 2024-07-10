help:
	@clear
	@echo '================================================================================'
	@echo 'WARNING1: Your system must be Orange5/5b/5+ with Debian11/Ubuntu22.04 host'
	@echo '  (original Xunlong or Armbian or JoshuaRiek distros can be used).'
	@echo '================================================================================'
	@echo ''
	@echo 'sudo dpkg-reconfigure dash'
	@echo ''
	@echo '^^^ Say "NO" to dash(debian/ubuntu ash), this will select "bash".'
	@echo ''
	@echo 'make host'
	@echo ''
	@echo "make src"
	@echo ''
	@echo 'Please, Open 3 terminals.'
	@echo '3rd run "btop". 2nd run "watch ls tmp". 1st run commands below...'
	@echo ''
	@echo 'time make img 2>&1 | tee 0.txt'
	@echo ''
	@echo 'make img_help (for future help)'


host: host-check.txt deps longsudo
	@echo '================================================================================'
	@echo 'WARNING5: We will need tmp(temporary catalog). Because chroot will be used      '
	@echo 'it can not link to upward dir. So we will create "lfs-chroot/opt/mysdk/tmp".    '
	@echo '  At 1st stage, the "tmp" is symlink used for host-build purposes.'
	@echo '  At 2nd stage, the "tmp" is natively-tmp-catalog under chroot.'
	@echo 'PLEASE: do not remove upward-tmp or downward-tmp at all.'
	@echo 'PLEASE: examine it content and delete parts manually.'
	@echo ''
	@echo '================================================================================'
	@echo 'Please, use the next commands for help:'
	@echo ''
	@echo 'make'
	@echo ''
	@echo 'OR'
	@echo ''
	@echo "make help"


host-check.sh: Makefile
	sudo dpkg-reconfigure dash
	echo '#!/bin/bash' > $@
	echo '# Simple script to list version numbers of critical development tools' >> $@
	echo '# https://www.linuxfromscratch.org/lfs/view/10.0-systemd' >> $@
	echo 'export LC_ALL=C' >> $@
	echo 'bash --version | head -n1 | cut -d" " -f2-4' >> $@
	echo 'MYSH=$$(readlink -f /bin/sh)' >> $@
	echo 'echo "/bin/sh -> $$MYSH"' >> $@
	echo 'echo $$MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"' >> $@
	echo 'unset MYSH' >> $@
	echo 'echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-' >> $@
	echo 'bison --version | head -n1' >> $@
	echo 'if [ -h /usr/bin/yacc ]; then' >> $@
	echo '  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";' >> $@
	echo 'elif [ -x /usr/bin/yacc ]; then' >> $@
	echo '  echo yacc is `/usr/bin/yacc --version | head -n1`' >> $@
	echo 'else' >> $@
	echo '  echo "yacc not found" ' >> $@
	echo 'fi' >> $@
	echo 'bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-' >> $@
	echo 'echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2' >> $@
	echo 'diff --version | head -n1' >> $@
	echo 'find --version | head -n1' >> $@
	echo 'gawk --version | head -n1' >> $@
	echo 'if [ -h /usr/bin/awk ]; then' >> $@
	echo '  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";' >> $@
	echo 'elif [ -x /usr/bin/awk ]; then' >> $@
	echo '  echo awk is `/usr/bin/awk --version | head -n1`' >> $@
	echo 'else ' >> $@
	echo '  echo "awk not found" ' >> $@
	echo 'fi' >> $@
	echo 'gcc --version | head -n1' >> $@
	echo 'g++ --version | head -n1' >> $@
	echo 'ldd --version | head -n1 | cut -d" " -f2-  # glibc version' >> $@
	echo 'grep --version | head -n1' >> $@
	echo 'gzip --version | head -n1' >> $@
	echo 'cat /proc/version' >> $@
	echo 'm4 --version | head -n1' >> $@
	echo 'make --version | head -n1' >> $@
	echo 'patch --version | head -n1' >> $@
	echo 'echo Perl `perl -V:version`' >> $@
	echo 'python3 --version' >> $@
	echo 'sed --version | head -n1' >> $@
	echo 'tar --version | head -n1' >> $@
	echo 'makeinfo --version | head -n1  # texinfo version' >> $@
	echo 'xz --version | head -n1' >> $@
	echo 'echo "int main(){}" > dummy.c && g++ -o dummy dummy.c' >> $@
	echo 'if [ -x dummy ]' >> $@
	echo '  then echo "g++ compilation OK";' >> $@
	echo '  else echo "g++ compilation failed"; fi' >> $@
	echo 'rm -f dummy.c dummy' >> $@
	chmod ugo+x $@

host-check.txt: host-check.sh
	@echo '================================================================================'
	@echo 'WARNING2: Now we will create "host-check.txt". Please check it before build.'
	@echo '================================================================================'
	@read -p 'Press ENTER if you reads this message and AGREE to continue...'
	./$< > host-check.txt
	@echo '================================================================================'
	cat ./$@
	@echo '================================================================================'
	@read -p 'Please read above info. Press ENTER if all is OK, or strike Ctrl-C ...'

deps:
	@echo '================================================================================'
	@echo 'WARNING3: Here is we will install host build dependicies via "sudo apt install".'
#	@echo '"libgmp-dev libmpc-dev libmpfr-dev texinfo gawk gettext zstd pv btop cpio"'
	@echo '"libgmp-dev libmpc-dev libmpfr-dev texinfo gawk gettext zstd cpio btop"'
	@echo '================================================================================'
	@read -p 'Press ENTER if you reads this message and AGREE, or stroke Ctrl-C to cancel...'
	sudo apt install -y libgmp-dev libmpc-dev libmpfr-dev texinfo gawk gettext zstd cpio btop

longsudo:
	@echo '================================================================================'
	@echo 'WARNING4: This Operation add YOU(as user) to sudo group!'
	@echo 'So you will may not enter sudo password in future!'
	@echo 'The sudo password expiries after 5 minutes by-default.'
	@echo 'The build process will need to ENTERING chroot-environment(need sudo) at first'
	@echo 'stages and need to ENTERING sudo in last stages.So 5min period is not sufficient.'
	@echo 'You also can not elapse time with "time make ..." command.'
	@echo 'So, we reccommend you to disable sudo password to make it automatic.'
	@echo 'If you beware this, you can disable this feature by:'
	@echo '  1) Pressing Ctrl-C now and ivoke build process as usual'
	@echo '  2) Edit this make-file. Find "host:" target (about 20 lines from start)'
	@echo 'end remove word "longsudo" at the end of this line.'
	@echo '  3) You can restore your sudo-password invocation in future if you remove'
	@echo '    file with user-name from "/etc/sudoers.d"'
	@echo 'Are you ready?'
	@read -p 'Press ENTER if you reads this message and AGREE, or stroke Ctrl-C to cancel...'
	@echo ''
	sudo /sbin/usermod -a -G sudo $$(whoami)
	sudo touch /etc/sudoers.d/$$(whoami)
	echo `whoami` 'ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/`whoami`

dummy-clean:
	rm -f host-check.*
	rm -f *.txt

clean: dummy-clean
	rm -fr lfs-cross
	rm -fr pkg0
	rm -fr tmp
	sudo rm -fr lfs-chroot

distclean: clean
	rm -fr src

# #############################################################################

VERB=1
JOB=12
JOBS=-j$(JOB)
GIT_RM=y
BUILD_STRIP=y
RUN_TESTS=n
RK3588_AFLG = +crypto
RK3588_MCPU = cortex-a76.cortex-a55$(RK3588_AFLG)
RK3588_ARCH = armv8.2-a+lse+rdma+crc+fp16+rcpc+dotprod$(RK3588_AFLG)
RK3588_FLAGS = -mcpu=$(RK3588_MCPU)
# OPTIMIZATION FLAG: s (only for size - other optimizations -- see at STAGE3!!!)
BASE_OPT_VAL=s
BASE_OPT_VALUE= -O$(BASE_OPT_VAL)

ifeq ($(BASE_OPT_VALUE),-O3)
$(error BASE_OPT_VALUE = -O3 : is not supported, only -Os is supported)
endif

ifeq ($(BASE_OPT_VALUE),-O2)
$(error BASE_OPT_VALUE = -O2 : is not supported, only -Os is supported)
endif

ifeq ($(BASE_OPT_VALUE),-O1)
$(error BASE_OPT_VALUE = -O1 : is not supported, only -Os is supported)
endif

ifeq ($(BASE_OPT_VALUE),-O0)
$(error BASE_OPT_VALUE = -O0 : is not supported, only -Os is supported)
endif

BASE_OPT_FLAGS = $(RK3588_FLAGS) $(BASE_OPT_VALUE)
OPT_FLAGS = CFLAGS="$(BASE_OPT_FLAGS)" CPPFLAGS="$(BASE_OPT_FLAGS)" CXXFLAGS="$(BASE_OPT_FLAGS)"

TODAY_CODE=$(shell date +"%Y%m%d")

LFS=$(shell pwd)/lfs-cross
LFS_TGT=aarch64-lfs-linux-gnu
LFS_VER=10.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd

UBOOT_VER=v2024.04
CAN_UTILS_VER=v2020.12.0

# LFS-packages versions:
ACL_VER=2.2.53
ATTR_VER=2.4.48
AUTOCONF_VER=2.69
AUTOMAKE_VER=1.16.2
# AUTOMAKE_VER=1.16.3 = Debian11
AUTOMAKE_VER0=1.16
BASH_VER=5.0
# BASH_VER=5.1 = Debian11
BC_VER=3.1.5
BINUTILS_VER=2.35
# BINUTILS_VER=2.35.2 = Debian11
BISON_VER=3.7.1
# BISON_VER=3.7.5 = Debian11
BZIP2_VER=1.0.8
CHECK_VER=0.15.2
CMAKE_VER0=3.18
CMAKE_VER=3.18.1
CONVMV_VER=2.05
CORE_UTILS_VER=8.32
CPIO_VER=2.13
DB_BERKELEY_VER=5.3.28
DBUS_VER=1.12.20
# DBUS_VER=1.12.24 = Debian11
DEJAGNU_VER=1.6.2
DIFF_UTILS_VER=3.7
DOS_FS_TOOLS_VER=4.1
# DOS_FS_TOOLS_VER=4.1 = Debian11
#DTC_VER=1.6.1
DTC_VER=1.7.0
E2FSPROGS_VER=1.45.6
# E2FSPROGS_VER=1.46.2 = Debian11
ELF_UTILS_VER=0.180
# EXPAT_VER=2.2.9
# ^^^ is unaviable now(01.01.24) for download. Original expat-site say to replace it with 2.5.0.
#EXPAT_VER=2.5.0
# ^^^ is unaviable now(15.03.24) for download. Original expat-site say to replace it with 2.6.2.
EXPAT_VER=2.6.2
EXPECT_VER=5.45.4
FILE_VER=5.39
FIND_UTILS_VER=4.7.0
# FIND_UTILS_VER=4.8.0 = Debian11
FLEX_VER=2.6.4
GAWK_VER=5.1.0
GCC_VER=10.2.0
# GCC_VER=10.2.1 = Debian11
GDBM_VER=1.18.1
GETTEXT_VER=0.21
GLIBC_VER=2.32
GMP_VER=6.2.0
GPERF_VER=3.1
GREP_VER=3.4
# GPEP_VER=3.6 = Debian11
GROFF_VER=1.22.4
GZIP_VER=1.10
IANA_ETC_VER=20200821
INET_UTILS_VER=1.9.4
INTL_TOOL_VER=0.51.0
IP_ROUTE2_VER=5.8.0
# IP_ROUTE2_VER=5.10.0 =Debian11
IP_TABLES_VER=1.8.5
# IP_TABLES_VER=1.8.7 = Debian11
ISL_VER=0.23
KBD_VER=2.3.0
KMOD_VER=27
#KMOD_VER=28 = Debian11
LESS_VER=551
LIBARCHIVE_VER=3.4.3
LIBCAP_VER=2.42
# LIBCAP_VER=2.44 = Debian11
LIBCBOR_VER=0.7.0
LIBEDIT_VER=20240517-3.1
LIBEDIT_BULLSEYE_VER=3.1-20191231
LIBFFI_VER=3.3
LIBIDN2_VER=2.3.0
LIBMD_VER=1.0.3
LIBMNL_VER=1.0.4
LIBPIPILINE_VER=1.5.3
LIBTASN1_VER=4.16.0
LIBTOOL_VER=2.4.6
LIBUNISTRING_VER=0.9.10
LIBUSB_VER=1.0.23
# LIBUSB_VER=1.0.24 = Debian11
LIBUV_VER=v1.38.1
# LIBUV_VER=v1.40.0 = Debian11
M4_VER=1.4.18
MAKE_VER=4.3
MAKE_CA_VER=1.7
MAN_DB_VER=2.9.3
# MAN_DB_VER=2.9.4 = Debian11
MAN_PAGES_VER=5.08
MESON_VER=0.55.0
MICROCOM_VER=2023.09.0
MPC_VER=1.1.0
MPFR_VER=4.1.0
NANO_VER=5.2
NCURSES_VER=6.2
NET_TOOLS_VER=20101030
NFTABLES_VER=1.0.9
NINJA_VER=1.10.0
NGHTTP2_VER=1.41.0
OPEN_SSL_VER=1.1.1g
#OPEN_SSL_VER=1.1.1n = Debian11
OPENLDAP_VER=2.4.51
###OPENSLP_VER=2.0.0
OPENSSH_VER=8.3p1
PARTED_VER=3.3
# PARTED_VER=3.4 = Debian11
PATCH_VER=2.7.6
PCRE_VER=8.44
PERL_VER=5.32.0
# PERL_VER=5.32.1 = Debian11
PERL_VER0=5.32
PKG_CONFIG_VER=0.29.2
POPT_VER=1.18
PROCPS_VER=3.3.16
#PSMISC_VER=23.3
# ^^ undowladable now: 2024.03
PSMISC_VER=23.4
#PV_VER=1.8.5
#PV_VER=1.6.6 = Debian11
#PV_VER=1.6.20
PYELFTOOLS_VER=0.30
PYTHON_VER=3.8.5
# PYTHON_VER=3.9.2 = Debian11
PYTHON_DOC_VER=$(PYTHON_VER)
PYTHON_VER0=3.8
PYTHON_VER00=3
PYTHON2_VER=2.7.18
RE2C_VER=3.1
READLINE_VER=8.0
# READLINE_VER=8.1 = Debian11
RSYNC_VER=3.2.3
SASL_VER=2.1.27
SED_VER=4.8
# SED_VER=4.7 = Debian11
SHADOW_VER=4.8.1
SHARUTILS_VER=4.15.2
SWIG_VER=4.0.2
SYSTEMD_VER=246
# SYSTEMD_VER=247.3 = Debian11
TAR_VER=1.32
# TAR_VER=1.34 = Debian11
# TCL_VER=8.6.11 = Debian11
TCL_VER_BRIEF=8.6
TCL_VER=$(TCL_VER_BRIEF).10
TCL_DOC_VER=$(TCL_VER)
TCL_VER_THREAD_VER=2.8.5
TCL_VER_ITCL_VER=4.2.0
TCL_VER_SQLITE_VER=3.30.1.2
TCL_VER_TDBC_VER=1.1.1
TEXINFO_VER=6.7
TIME_ZONE_DATA_VER=2020a
UNZIP_VER0=60
UNZIP_VER=6.0
USB_UTILS_VER=012
# USB_UTILS_VER=013 = Debian11
UTIL_LINUX_VER=2.36
WGET_VER=1.20.3
# WGET_VER=1.21 = Debian11
WHICH_VER=2.21
XML_PARSER_VER=2.46
XZ_VER=5.2.5
ZIP_VER0=30
ZIP_VER=3.0
#ZLIB_VER=1.2.11
#ZLIB_VER=1.3
ZLIB_VER=1.3.1
ZSTD_VER=1.4.5

# Incremental rule for download:
SRC+=src/bash-$(BASH_VER)-upstream_fixes-1.patch
SRC+=src/bzip2-$(BZIP2_VER)-install_docs-1.patch
SRC+=src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch
SRC+=src/glibc-$(GLIBC_VER)-fhs-1.patch
SRC+=src/kbd-$(KBD_VER)-backspace-1.patch
SRC+=src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch
SRC+=src/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch
SRC+=src/cyrus-sasl-$(SASL_VER)-doc_fixes-1.patch
SRC+=src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch
SRC+=src/openldap-$(OPENLDAP_VER)-consolidated-2.patch

SRC+=src/acl-$(ACL_VER).tar.gz
SRC+=src/attr-$(ATTR_VER).tar.gz
SRC+=src/autoconf-$(AUTOCONF_VER).tar.xz
SRC+=src/automake-$(AUTOMAKE_VER).tar.xz
SRC+=src/bash-$(BASH_VER).tar.gz
SRC+=src/bc-$(BC_VER).tar.xz
SRC+=src/binutils-$(BINUTILS_VER).tar.xz
SRC+=src/bison-$(BISON_VER).tar.xz	
SRC+=src/bzip2-$(BZIP2_VER).tar.gz
SRC+=src/check-$(CHECK_VER).tar.gz
SRC+=src/cmake-$(CMAKE_VER).tar.gz
SRC+=src/convmv-$(CONVMV_VER).tar.gz
SRC+=src/coreutils-$(CORE_UTILS_VER).tar.xz
SRC+=src/cpio-$(CPIO_VER).tar.bz2
SRC+=src/db-$(DB_BERKELEY_VER).tar.gz
SRC+=src/dbus-$(DBUS_VER).tar.gz
SRC+=src/dejagnu-$(DEJAGNU_VER).tar.gz
SRC+=src/diffutils-$(DIFF_UTILS_VER).tar.xz
SRC+=src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz
SRC+=src/dtc-$(DTC_VER).tar.gz
SRC+=src/e2fsprogs-$(E2FSPROGS_VER).tar.gz
SRC+=src/elfutils-$(ELF_UTILS_VER).tar.bz2
SRC+=src/expat-$(EXPAT_VER).tar.xz
SRC+=src/expect$(EXPECT_VER).tar.gz
SRC+=src/file-$(FILE_VER).tar.gz
SRC+=src/findutils-$(FIND_UTILS_VER).tar.xz
SRC+=src/flex-$(FLEX_VER).tar.gz
SRC+=src/gawk-$(GAWK_VER).tar.xz
SRC+=src/gcc-$(GCC_VER).tar.xz
SRC+=src/gdbm-$(GDBM_VER).tar.gz
SRC+=src/gettext-$(GETTEXT_VER).tar.xz
SRC+=src/glibc-$(GLIBC_VER).tar.xz
SRC+=src/gmp-$(GMP_VER).tar.xz
SRC+=src/gperf-$(GPERF_VER).tar.gz
SRC+=src/grep-$(GREP_VER).tar.xz
SRC+=src/groff-$(GROFF_VER).tar.gz
SRC+=src/gzip-$(GZIP_VER).tar.xz
SRC+=src/iana-etc-$(IANA_ETC_VER).tar.gz
SRC+=src/inetutils-$(INET_UTILS_VER).tar.xz
SRC+=src/intltool-$(INTL_TOOL_VER).tar.gz
SRC+=src/iproute2-$(IP_ROUTE2_VER).tar.xz
SRC+=src/iptables-$(IP_TABLES_VER).tar.bz2
SRC+=src/isl-$(ISL_VER).tar.xz
SRC+=src/kbd-$(KBD_VER).tar.xz
SRC+=src/kmod-$(KMOD_VER).tar.xz
SRC+=src/less-$(LESS_VER).tar.gz
SRC+=src/libarchive-$(LIBARCHIVE_VER).tar.xz
SRC+=src/libcap-$(LIBCAP_VER).tar.xz
SRC+=src/libcbor-$(LIBCBOR_VER).zip
SRC+=src/libedit-$(LIBEDIT_VER).tar.gz
SRC+=src/libedit_bullsyey_$(LIBEDIT_BULLSEYE_VER).orig.tar.gz
SRC+=src/libffi-$(LIBFFI_VER).tar.gz
SRC+=src/libidn2-$(LIBIDN2_VER).tar.gz
SRC+=src/libmd-$(LIBMD_VER).tar.xz
SRC+=src/libmnl-$(LIBMNL_VER).tar.bz2
SRC+=src/libpipeline-$(LIBPIPILINE_VER).tar.gz
SRC+=src/libtasn1-$(LIBTASN1_VER).tar.gz
SRC+=src/libtool-$(LIBTOOL_VER).tar.xz
SRC+=src/libunistring-$(LIBUNISTRING_VER).tar.xz
SRC+=src/libusb-$(LIBUSB_VER).tar.bz2
SRC+=src/libuv-$(LIBUV_VER).tar.gz
SRC+=src/m4-$(M4_VER).tar.xz
SRC+=src/make-$(MAKE_VER).tar.gz
SRC+=src/make-ca-$(MAKE_CA_VER).tar.xz
SRC+=src/man-db-$(MAN_DB_VER).tar.xz
SRC+=src/man-pages-$(MAN_PAGES_VER).tar.xz
SRC+=src/meson-$(MESON_VER).tar.gz
SRC+=src/microcom-$(MICROCOM_VER).tar.gz
SRC+=src/mpc-$(MPC_VER).tar.gz
SRC+=src/mpfr-$(MPFR_VER).tar.xz
SRC+=src/nano-$(NANO_VER).tar.xz
SRC+=src/ncurses-$(NCURSES_VER).tar.gz
SRC+=src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz
SRC+=src/nftables-$(NFTABLES_VER).tar.xz
SRC+=src/ninja-$(NINJA_VER).tar.gz
SRC+=src/nghttp2-$(NGHTTP2_VER).tar.xz
SRC+=src/openssl-$(OPEN_SSL_VER).tar.gz
SRC+=src/openldap-$(OPENLDAP_VER).tgz
SRC+=src/openssh-$(OPENSSH_VER).tar.gz
SRC+=src/parted-$(PARTED_VER).tar.xz
SRC+=src/patch-$(PATCH_VER).tar.xz
SRC+=src/pcre-$(PCRE_VER).tar.gz
SRC+=src/perl-$(PERL_VER).tar.xz
SRC+=src/pkg-config-$(PKG_CONFIG_VER).tar.gz
SRC+=src/popt-$(POPT_VER).tar.gz
SRC+=src/procps-ng-$(PROCPS_VER).tar.xz
SRC+=src/psmisc-$(PSMISC_VER).tar.xz
#SRC+=src/pv_$(PV_VER).orig.tar.bz2
SRC+=src/pyelftools-$(PYELFTOOLS_VER).zip
SRC+=src/Python-$(PYTHON_VER).tar.xz
SRC+=src/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2
SRC+=src/Python-$(PYTHON2_VER).tar.xz
SRC+=src/re2c-$(RE2C_VER).tar.gz
SRC+=src/readline-$(READLINE_VER).tar.gz
SRC+=src/rsync-$(RSYNC_VER).tar.gz
SRC+=src/cyrus-sasl-$(SASL_VER).tar.gz
SRC+=src/sed-$(SED_VER).tar.xz
SRC+=src/shadow-$(SHADOW_VER).tar.xz
SRC+=src/sharutils-$(SHARUTILS_VER).tar.xz
SRC+=src/swig-$(SWIG_VER).tar.gz
SRC+=src/systemd-$(SYSTEMD_VER).tar.gz
SRC+=src/tar-$(TAR_VER).tar.xz
SRC+=src/tcl$(TCL_VER)-src.tar.gz
SRC+=src/tcl$(TCL_DOC_VER)-html.tar.gz
SRC+=src/texinfo-$(TEXINFO_VER).tar.xz
SRC+=src/tzdata$(TIME_ZONE_DATA_VER).tar.gz
SRC+=src/unzip$(UNZIP_VER0).tar.gz
SRC+=src/usbutils-$(USB_UTILS_VER).tar.xz
SRC+=src/util-linux-$(UTIL_LINUX_VER).tar.xz
SRC+=src/wget-$(WGET_VER).tar.gz
SRC+=src/which-$(WHICH_VER).tar.gz
SRC+=src/XML-Parser-$(XML_PARSER_VER).tar.gz
SRC+=src/xz-$(XZ_VER).tar.xz
SRC+=src/zlib-$(ZLIB_VER).tar.xz
SRC+=src/zip$(ZIP_VER0).tar.gz
SRC+=src/zstd-$(ZSTD_VER).tar.gz

SRC+=src/config.guess
SRC+=src/config.sub

# Opi5 additional downloads:
SRC+=src/orangepi5-rkbin-only_rk3588.cpio.zst
SRC+=src/rockchip-rk35-atf.src.cpio.zst
SRC+=src/uboot-$(UBOOT_VER).src.cpio.zst
SRC+=src/orangepi5-uboot.src.cpio.zst
SRC+=src/rkdeveloptool.src.cpio.zst
SRC+=src/orangepi5-linux510.src.cpio.zst
SRC+=src/can-utils-$(CAN_UTILS_VER).src.cpio.zst
SRC+=src/usb.ids.cpio.zst

src: $(SRC)
# 20min at usual internet connection

src/.gitignore:
	mkdir -p lfs-chroot/opt/mysdk/tmp
	ln -sfv lfs-chroot/opt/mysdk/tmp tmp
	mkdir -p src &&	touch $@
src/glibc-$(GLIBC_VER)-fhs-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/glibc-$(GLIBC_VER)-fhs-1.patch && touch $@
src/bash-$(BASH_VER)-upstream_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bash-$(BASH_VER)-upstream_fixes-1.patch && touch $@
src/bzip2-$(BZIP2_VER)-install_docs-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bzip2-$(BZIP2_VER)-install_docs-1.patch && touch $@
src/coreutils-$(CORE_UTILS_VER)-i18n-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/coreutils-$(CORE_UTILS_VER)-i18n-1.patch && touch $@
src/kbd-$(KBD_VER)-backspace-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/kbd-$(KBD_VER)-backspace-1.patch && touch $@
src/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch && touch $@
src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch && touch $@
src/cyrus-sasl-$(SASL_VER)-doc_fixes-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/cyrus-sasl-$(SASL_VER)-doc_fixes-1.patch && touch $@
src/openldap-$(OPENLDAP_VER)-consolidated-2.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/openldap-$(OPENLDAP_VER)-consolidated-2.patch && touch $@
src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch: src/.gitignore
	wget -P src http://www.linuxfromscratch.org/patches/blfs/$(LFS_VER)/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch && touch $@

src/acl-$(ACL_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/acl/acl-$(ACL_VER).tar.gz && touch $@
src/attr-$(ATTR_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/attr/attr-$(ATTR_VER).tar.gz && touch $@
src/autoconf-$(AUTOCONF_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_VER).tar.xz && touch $@
src/automake-$(AUTOMAKE_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_VER).tar.xz && touch $@
src/bash-$(BASH_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz && touch $@
src/bc-$(BC_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/gavinhoward/bc/releases/download/$(BC_VER)/bc-$(BC_VER).tar.xz && touch $@
src/binutils-$(BINUTILS_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.xz && touch $@
src/bison-$(BISON_VER).tar.xz: src/.gitignore	
	wget -P src http://ftp.gnu.org/gnu/bison/bison-$(BISON_VER).tar.xz && touch $@
src/bzip2-$(BZIP2_VER).tar.gz: src/.gitignore
	wget -P src https://www.sourceware.org/pub/bzip2/bzip2-$(BZIP2_VER).tar.gz && touch $@
src/check-$(CHECK_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/libcheck/check/releases/download/$(CHECK_VER)/check-$(CHECK_VER).tar.gz && touch $@
src/cmake-$(CMAKE_VER).tar.gz: src/.gitignore
	wget -P src https://cmake.org/files/v$(CMAKE_VER0)/cmake-$(CMAKE_VER).tar.gz && touch $@
src/convmv-$(CONVMV_VER).tar.gz: src/.gitignore
	wget -P src https://j3e.de/linux/convmv/convmv-$(CONVMV_VER).tar.gz && touch $@
src/coreutils-$(CORE_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/coreutils/coreutils-$(CORE_UTILS_VER).tar.xz && touch $@
src/cpio-$(CPIO_VER).tar.bz2: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/cpio/cpio-$(CPIO_VER).tar.bz2 && touch $@
src/db-$(DB_BERKELEY_VER).tar.gz: src/.gitignore
	wget -P src http://anduin.linuxfromscratch.org/BLFS/bdb/db-$(DB_BERKELEY_VER).tar.gz && touch $@
src/dbus-$(DBUS_VER).tar.gz: src/.gitignore
	wget -P src https://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS_VER).tar.gz && touch $@
src/dejagnu-$(DEJAGNU_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/dejagnu/dejagnu-$(DEJAGNU_VER).tar.gz && touch $@
src/diffutils-$(DIFF_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/diffutils/diffutils-$(DIFF_UTILS_VER).tar.xz && touch $@
src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz: src/.gitignore 	
	wget -P src https://github.com/dosfstools/dosfstools/releases/download/v$(DOS_FS_TOOLS_VER)/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz && touch $@
src/dtc-$(DTC_VER).tar.gz: src/.gitignore 
	wget -P src https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/dtc-$(DTC_VER).tar.gz && touch $@
src/e2fsprogs-$(E2FSPROGS_VER).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz && touch $@
src/elfutils-$(ELF_UTILS_VER).tar.bz2: src/.gitignore
	wget -P src https://sourceware.org/ftp/elfutils/$(ELF_UTILS_VER)/elfutils-$(ELF_UTILS_VER).tar.bz2 && touch $@
src/expat-$(EXPAT_VER).tar.xz: src/.gitignore
	wget -P src https://prdownloads.sourceforge.net/expat/expat-$(EXPAT_VER).tar.xz && touch $@
src/expect$(EXPECT_VER).tar.gz: src/.gitignore
	wget -P src https://prdownloads.sourceforge.net/expect/expect$(EXPECT_VER).tar.gz && touch $@
src/file-$(FILE_VER).tar.gz: src/.gitignore
	wget -P src ftp://ftp.astron.com/pub/file/file-$(FILE_VER).tar.gz && touch $@
src/findutils-$(FIND_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/findutils/findutils-$(FIND_UTILS_VER).tar.xz && touch $@
src/flex-$(FLEX_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/westes/flex/releases/download/v$(FLEX_VER)/flex-$(FLEX_VER).tar.gz && touch $@
src/gawk-$(GAWK_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gawk/gawk-$(GAWK_VER).tar.xz && touch $@
src/gcc-$(GCC_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VER)/gcc-$(GCC_VER).tar.xz && touch $@
src/gdbm-$(GDBM_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gdbm/gdbm-$(GDBM_VER).tar.gz && touch $@
src/gettext-$(GETTEXT_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gettext/gettext-$(GETTEXT_VER).tar.xz && touch $@
src/glibc-$(GLIBC_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/glibc/glibc-$(GLIBC_VER).tar.xz && touch $@
src/gmp-$(GMP_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/gmp/gmp-$(GMP_VER).tar.xz && touch $@
src/gperf-$(GPERF_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gperf/gperf-$(GPERF_VER).tar.gz && touch $@
src/grep-$(GREP_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/grep/grep-$(GREP_VER).tar.xz && touch $@
src/groff-$(GROFF_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/groff/groff-$(GROFF_VER).tar.gz && touch $@
src/gzip-$(GZIP_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VER).tar.xz && touch $@
src/iana-etc-$(IANA_ETC_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/Mic92/iana-etc/releases/download/$(IANA_ETC_VER)/iana-etc-$(IANA_ETC_VER).tar.gz && touch $@
src/inetutils-$(INET_UTILS_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/inetutils/inetutils-$(INET_UTILS_VER).tar.xz && touch $@
src/intltool-$(INTL_TOOL_VER).tar.gz: src/.gitignore
	wget -P src https://launchpad.net/intltool/trunk/$(INTL_TOOL_VER)/+download/intltool-$(INTL_TOOL_VER).tar.gz && touch $@
src/iproute2-$(IP_ROUTE2_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$(IP_ROUTE2_VER).tar.xz && touch $@
src/iptables-$(IP_TABLES_VER).tar.bz2: src/.gitignore
	wget -P src http://www.netfilter.org/projects/iptables/files/iptables-$(IP_TABLES_VER).tar.bz2 && touch $@
src/isl-$(ISL_VER).tar.xz: src/.gitignore
	wget -P src https://libisl.sourceforge.io/isl-$(ISL_VER).tar.xz && touch $@
src/kbd-$(KBD_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/kbd/kbd-$(KBD_VER).tar.xz && touch $@
src/kmod-$(KMOD_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$(KMOD_VER).tar.xz && touch $@
src/less-$(LESS_VER).tar.gz: src/.gitignore
	wget -P src http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz && touch $@
src/libarchive-$(LIBARCHIVE_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/libarchive/libarchive/releases/download/v$(LIBARCHIVE_VER)/libarchive-$(LIBARCHIVE_VER).tar.xz && touch $@
src/libcap-$(LIBCAP_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(LIBCAP_VER).tar.xz && touch $@
src/libcbor-$(LIBCBOR_VER).zip: src/.gitignore
	wget -O $@ https://github.com/PJK/libcbor/archive/refs/tags/v$(LIBCBOR_VER).zip && touch $@
src/libedit-$(LIBEDIT_VER).tar.gz: src/.gitignore
	wget -P src https://www.thrysoee.dk/editline/libedit-$(LIBEDIT_VER).tar.gz && touch $@
src/libedit_bullsyey_$(LIBEDIT_BULLSEYE_VER).orig.tar.gz: src/.gitignore
	wget -O $@ http://deb.debian.org/debian/pool/main/libe/libedit/libedit_$(LIBEDIT_BULLSEYE_VER).orig.tar.gz && touch $@
src/libffi-$(LIBFFI_VER).tar.gz: src/.gitignore
	wget -P src ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz && touch $@
src/libidn2-$(LIBIDN2_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libidn/libidn2-$(LIBIDN2_VER).tar.gz && touch $@
src/libmd-$(LIBMD_VER).tar.xz: src/.gitignore
	wget -P src https://archive.hadrons.org/software/libmd/libmd-$(LIBMD_VER).tar.xz && touch $@
src/libmnl-$(LIBMNL_VER).tar.bz2: src/.gitignore
	wget -P src https://netfilter.org/projects/libmnl/files/libmnl-$(LIBMNL_VER).tar.bz2 && touch $@
src/libpipeline-$(LIBPIPILINE_VER).tar.gz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/libpipeline/libpipeline-$(LIBPIPILINE_VER).tar.gz && touch $@
src/libtasn1-$(LIBTASN1_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libtasn1/libtasn1-$(LIBTASN1_VER).tar.gz && touch $@
src/libtool-$(LIBTOOL_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/libtool/libtool-$(LIBTOOL_VER).tar.xz && touch $@
src/libunistring-$(LIBUNISTRING_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/libunistring/libunistring-$(LIBUNISTRING_VER).tar.xz && touch $@
src/libusb-$(LIBUSB_VER).tar.bz2: src/.gitignore
	wget -P src https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VER)/libusb-$(LIBUSB_VER).tar.bz2 && touch $@
src/libuv-$(LIBUV_VER).tar.gz: src/.gitignore
	wget -P src https://dist.libuv.org/dist/$(LIBUV_VER)/libuv-$(LIBUV_VER).tar.gz && touch $@
src/m4-$(M4_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/m4/m4-$(M4_VER).tar.xz && touch $@
src/make-$(MAKE_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/make/make-$(MAKE_VER).tar.gz && touch $@
src/make-ca-$(MAKE_CA_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/djlucas/make-ca/releases/download/v$(MAKE_CA_VER)/make-ca-$(MAKE_CA_VER).tar.xz && touch $@
src/man-db-$(MAN_DB_VER).tar.xz: src/.gitignore
	wget -P src http://download.savannah.gnu.org/releases/man-db/man-db-$(MAN_DB_VER).tar.xz && touch $@
src/man-pages-$(MAN_PAGES_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/docs/man-pages/man-pages-$(MAN_PAGES_VER).tar.xz && touch $@
src/meson-$(MESON_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/mesonbuild/meson/releases/download/$(MESON_VER)/meson-$(MESON_VER).tar.gz && touch $@
src/microcom-$(MICROCOM_VER).tar.gz: src/.gitignore
	wget -O src/microcom-$(MICROCOM_VER).tar.gz https://github.com/pengutronix/microcom/archive/refs/tags/v$(MICROCOM_VER).tar.gz && touch $@
src/mpc-$(MPC_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/mpc/mpc-$(MPC_VER).tar.gz && touch $@
src/mpfr-$(MPFR_VER).tar.xz: src/.gitignore
	wget -P src https://www.mpfr.org/mpfr-$(MPFR_VER)/mpfr-$(MPFR_VER).tar.xz && touch $@
src/nano-$(NANO_VER).tar.xz: src/.gitignore
#	wget -P src https://www.nano-editor.org/dist/v5/nano-$(NANO_VER).tar.xz && touch $@
	wget -P src https://ftp.gnu.org/gnu/nano/nano-$(NANO_VER).tar.xz && touch $@
src/ncurses-$(NCURSES_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz && touch $@
src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz: src/.gitignore
	wget -P src http://anduin.linuxfromscratch.org/BLFS/net-tools/net-tools-CVS_$(NET_TOOLS_VER).tar.gz && touch $@
src/nftables-$(NFTABLES_VER).tar.xz: src/.gitignore
	wget -P src https://netfilter.org/projects/nftables/files/nftables-$(NFTABLES_VER).tar.xz && touch $@
src/ninja-$(NINJA_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/ninja-build/ninja/archive/v$(NINJA_VER)/ninja-$(NINJA_VER).tar.gz && touch $@
src/nghttp2-$(NGHTTP2_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/nghttp2/nghttp2/releases/download/v$(NGHTTP2_VER)/nghttp2-$(NGHTTP2_VER).tar.xz && touch $@
src/openssl-$(OPEN_SSL_VER).tar.gz: src/.gitignore
	wget -P src https://www.openssl.org/source/openssl-$(OPEN_SSL_VER).tar.gz && touch $@
src/openldap-$(OPENLDAP_VER).tgz: src/.gitignore
	wget -P src ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$(OPENLDAP_VER).tgz && touch $@
src/openssh-$(OPENSSH_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz && touch $@
src/parted-$(PARTED_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz && touch $@
src/patch-$(PATCH_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/patch/patch-$(PATCH_VER).tar.xz && touch $@
src/pcre-$(PCRE_VER).tar.gz: src/.gitignore
#	wget -P src https://deac-fra.dl.sourceforge.net/project/pcre/pcre/$(PCRE_VER)/pcre-$(PCRE_VER).tar.gz && touch $@
	wget -P src https://sourceforge.net/projects/pcre/files/pcre/$(PCRE_VER)/pcre-$(PCRE_VER).tar.gz && touch $@
src/perl-$(PERL_VER).tar.xz: src/.gitignore
	wget -P src https://www.cpan.org/src/5.0/perl-$(PERL_VER).tar.xz && touch $@
src/pkg-config-$(PKG_CONFIG_VER).tar.gz: src/.gitignore
	wget -P src https://pkg-config.freedesktop.org/releases/pkg-config-$(PKG_CONFIG_VER).tar.gz && touch $@
src/popt-$(POPT_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.rpm.org/popt/releases/popt-1.x/popt-$(POPT_VER).tar.gz && touch $@
src/procps-ng-$(PROCPS_VER).tar.xz: src/.gitignore
	wget -P src https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-$(PROCPS_VER).tar.xz && touch $@
src/psmisc-$(PSMISC_VER).tar.xz: src/.gitignore
	wget -P src https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-$(PSMISC_VER).tar.xz && touch $@
#src/pv_$(PV_VER).orig.tar.bz2: src/.gitignore
#	wget -P src https://www.ivarch.com/programs/sources/pv-$(PV_VER).tar.gz && touch $@
#	wget -P src http://deb.debian.org/debian/pool/main/p/pv/pv_$(PV_VER).orig.tar.bz2 && touch $@
src/pyelftools-$(PYELFTOOLS_VER).zip: src/.gitignore
	wget -O $@ https://github.com/eliben/pyelftools/archive/refs/tags/v$(PYELFTOOLS_VER).zip && touch $@
src/Python-$(PYTHON_VER).tar.xz: src/.gitignore
	wget -P src https://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tar.xz && touch $@
src/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2: src/.gitignore
	wget -P src https://www.python.org/ftp/python/doc/$(PYTHON_DOC_VER)/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2 && touch $@
src/Python-$(PYTHON2_VER).tar.xz: src/.gitignore
	wget -P src https://www.python.org/ftp/python/$(PYTHON2_VER)/Python-$(PYTHON2_VER).tar.xz && touch $@
src/re2c-$(RE2C_VER).tar.gz: src/.gitignore
	wget -O src/re2c-$(RE2C_VER).tar.gz https://github.com/skvadrik/re2c/archive/refs/tags/$(RE2C_VER).tar.gz && touch $@
src/readline-$(READLINE_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/readline/readline-$(READLINE_VER).tar.gz && touch $@
src/rsync-$(RSYNC_VER).tar.gz: src/.gitignore
	wget -P src https://www.samba.org/ftp/rsync/src/rsync-$(RSYNC_VER).tar.gz && touch $@
src/cyrus-sasl-$(SASL_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-$(SASL_VER)/cyrus-sasl-$(SASL_VER).tar.gz && touch $@
src/sed-$(SED_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/sed/sed-$(SED_VER).tar.xz && touch $@
src/shadow-$(SHADOW_VER).tar.xz: src/.gitignore
	wget -P src https://github.com/shadow-maint/shadow/releases/download/$(SHADOW_VER)/shadow-$(SHADOW_VER).tar.xz && touch $@
src/sharutils-$(SHARUTILS_VER).tar.xz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/sharutils/sharutils-$(SHARUTILS_VER).tar.xz && touch $@
src/swig-$(SWIG_VER).tar.gz: src/.gitignore	
	wget -P src https://downloads.sourceforge.net/swig/swig-$(SWIG_VER).tar.gz && touch $@
src/systemd-$(SYSTEMD_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/systemd/systemd/archive/v$(SYSTEMD_VER)/systemd-$(SYSTEMD_VER).tar.gz && touch $@
src/tar-$(TAR_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/tar/tar-$(TAR_VER).tar.xz && touch $@
src/tcl$(TCL_VER)-src.tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/tcl/tcl$(TCL_VER)-src.tar.gz && touch $@
src/tcl$(TCL_DOC_VER)-html.tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/tcl/tcl$(TCL_DOC_VER)-html.tar.gz && touch $@
src/texinfo-$(TEXINFO_VER).tar.xz: src/.gitignore
	wget -P src http://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.xz && touch $@
src/tzdata$(TIME_ZONE_DATA_VER).tar.gz: src/.gitignore
	wget -P src https://www.iana.org/time-zones/repository/releases/tzdata$(TIME_ZONE_DATA_VER).tar.gz && touch $@
src/unzip$(UNZIP_VER0).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/infozip/unzip$(UNZIP_VER0).tar.gz && touch $@
src/usbutils-$(USB_UTILS_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/usb/usbutils/usbutils-$(USB_UTILS_VER).tar.xz && touch $@
src/util-linux-$(UTIL_LINUX_VER).tar.xz: src/.gitignore
	wget -P src https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_VER)/util-linux-$(UTIL_LINUX_VER).tar.xz && touch $@
src/wget-$(WGET_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/wget/wget-$(WGET_VER).tar.gz && touch $@
src/which-$(WHICH_VER).tar.gz: src/.gitignore
	wget -P src https://ftp.gnu.org/gnu/which/which-$(WHICH_VER).tar.gz && touch $@
src/XML-Parser-$(XML_PARSER_VER).tar.gz: src/.gitignore
	wget -P src https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-$(XML_PARSER_VER).tar.gz && touch $@
src/xz-$(XZ_VER).tar.xz: src/.gitignore
	wget -P src https://tukaani.org/xz/xz-$(XZ_VER).tar.xz && touch $@
src/zip$(ZIP_VER0).tar.gz: src/.gitignore
	wget -P src https://downloads.sourceforge.net/infozip/zip$(ZIP_VER0).tar.gz && touch $@
src/zlib-$(ZLIB_VER).tar.xz: src/.gitignore
	wget -P src https://zlib.net/zlib-$(ZLIB_VER).tar.xz && touch $@
src/zstd-$(ZSTD_VER).tar.gz: src/.gitignore
	wget -P src https://github.com/facebook/zstd/releases/download/v$(ZSTD_VER)/zstd-$(ZSTD_VER).tar.gz && touch $@
src/config.guess: src/.gitignore
	wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess" -O $@
	chmod ugo+x $@
src/config.sub: src/.gitignore
	wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub" -O $@
	chmod ugo+x $@
### +++++++++++++++++++++++++++++++++++++++++++++ Git clones
# GIT: armbian/rkbin = be3d2004d019b42cbecb001f5d7dd1e361d41e05
src/orangepi5-rkbin-only_rk3588.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/tmp
	rm -fr tmp/orangepi5-rkbin && mkdir -p tmp/orangepi5-rkbin/git
	git clone https://github.com/armbian/rkbin tmp/orangepi5-rkbin/git
	cd tmp/orangepi5-rkbin/git && git checkout be3d2004d019b42cbecb001f5d7dd1e361d41e05
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-rkbin/git/.git
endif
	cd tmp/orangepi5-rkbin/git/rk35 && find rk3588* -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../orangepi5-rkbin-only_rk3588.cpio.zst
	mkdir -p src && mv -fv tmp/orangepi5-rkbin/orangepi5-rkbin-only_rk3588.cpio.zst src/
	rm -fr tmp/orangepi5-rkbin
	rm -fr tmp/tmp
# GIT: ATF = 21840
src/rockchip-rk35-atf.src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/rockchip-rk35-atf && mkdir -p tmp/rockchip-rk35-atf/git
	git clone https://review.trustedfirmware.org/TF-A/trusted-firmware-a tmp/rockchip-rk35-atf/git
	cd tmp/rockchip-rk35-atf/git && git fetch https://review.trustedfirmware.org/TF-A/trusted-firmware-a refs/changes/40/21840/5 && git checkout -b change-21840 FETCH_HEAD
ifeq ($(GIT_RM),y)
	rm -fr tmp/rockchip-rk35-atf/git/.git
endif
	cd tmp/rockchip-rk35-atf/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../rockchip-rk35-atf.src.cpio.zst
	mkdir -p src && mv -fv tmp/rockchip-rk35-atf/rockchip-rk35-atf.src.cpio.zst src/
	rm -fr tmp/rockchip-rk35-atf
	rm -fr tmp/tmp
# GIT : UBOOT=v2024.01
# https://docs.u-boot.org/en/latest/build/source.html
# https://source.denx.de/u-boot/u-boot
# https://github.com/u-boot/u-boot
# note1: github is a full-mirror of source.denx.de (gitlab based)
# note2: Opi5 is supported at "2024" version, so release "2023.10" has no configs for orange-pi-5.
src/uboot-$(UBOOT_VER).src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/uboot && mkdir -p tmp/uboot/git
	git clone https://github.com/u-boot/u-boot tmp/uboot/git
	cd tmp/uboot/git && git checkout $(UBOOT_VER)
ifeq ($(GIT_RM),y)
	rm -fr tmp/uboot/git/.git
endif
	cd tmp/uboot/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../uboot-$(UBOOT_VER).src.cpio.zst
	mkdir -p src && mv -fv tmp/uboot/uboot-$(UBOOT_VER).src.cpio.zst src/
	rm -fr tmp/uboot
	rm -fr tmp/tmp
# GIT: orangepi5=UBOOT = v2017.09-rk3588
src/orangepi5-uboot.src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/orangepi5-uboot && mkdir -p tmp/orangepi5-uboot/git
	git clone https://github.com/orangepi-xunlong/u-boot-orangepi.git -b v2017.09-rk3588 tmp/orangepi5-uboot/git
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-uboot/git/.git
endif
	cd tmp/orangepi5-uboot/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../orangepi5-uboot.src.cpio.zst
	mkdir -p src && mv -fv tmp/orangepi5-uboot/orangepi5-uboot.src.cpio.zst src/
	rm -fr tmp/orangepi5-uboot
	rm -fr tmp/tmp
# GIT: can-utils
src/can-utils-$(CAN_UTILS_VER).src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/can-utils && mkdir -p tmp/can-utils/git
	git clone https://github.com/linux-can/can-utils tmp/can-utils/git
	cd tmp/can-utils/git && git checkout $(CAN_UTILS_VER)
ifeq ($(GIT_RM),y)
	rm -fr tmp/can-utils/git/.git
endif
	cd tmp/can-utils/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../can-utils-$(CAN_UTILS_VER).src.cpio.zst
	mkdir -p src && mv -fv tmp/can-utils/can-utils-$(CAN_UTILS_VER).src.cpio.zst src/
	rm -fr tmp/can-utils
	rm -fr tmp/tmp
# GIT: rkdeveloptool :: 46bb4c073624226c3f05b37b9ecc50bbcf543f5a
src/rkdeveloptool.src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/rkdeveloptool && mkdir -p tmp/rkdeveloptool/git
	git clone https://github.com/rockchip-linux/rkdeveloptool tmp/rkdeveloptool/git
	cd tmp/rkdeveloptool/git && git checkout 46bb4c073624226c3f05b37b9ecc50bbcf543f5a
	sed -i "1491s/buffer\[5\]/buffer\[558\]/" tmp/rkdeveloptool/git/main.cpp
ifeq ($(GIT_RM),y)
	rm -fr tmp/rkdeveloptool/git/.git
endif
	cd tmp/rkdeveloptool/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../rkdeveloptool.src.cpio.zst
	mkdir -p src && mv -fv tmp/rkdeveloptool/rkdeveloptool.src.cpio.zst src/
	rm -fr tmp/rkdeveloptool
	rm -fr tmp/tmp
# GIT: Linux-xunlong :: 5.10.110
src/orangepi5-linux510.src.cpio.zst:
	mkdir -p lfs-chroot/opt/mysdk/tmp && ln -sf lfs-chroot/opt/mysdk/tmp
	rm -fr tmp/orangepi5-linux && mkdir -p tmp/orangepi5-linux/git
	git clone https://github.com/orangepi-xunlong/linux-orangepi.git -b orange-pi-5.10-rk3588 tmp/orangepi5-linux/git
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-linux/git/.git
endif
	cd tmp/orangepi5-linux/git && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../orangepi5-linux510.src.cpio.zst
	mkdir -p src && mv -fv tmp/orangepi5-linux/orangepi5-linux510.src.cpio.zst src/
	rm -fr tmp/orangepi5-linux
	rm -fr tmp/tmp
#USB.IDS
src/usb.ids.cpio.zst:
	rm -fr tmp/usb-ids
	mkdir -p tmp/usb-ids/dl
	mkdir -p tmp/usb-ids/src
	cd tmp/usb-ids/dl && wget http://www.linux-usb.org/usb.ids && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	cp -f tmp/usb-ids/$@ src/
	rm -fr tmp/usb-ids
# --- END OF DOWNLOAD SECTION -------------------------------------------------

# MOST IMPORTANT(!) ENVIROMENT SETTINGS FOR HOST BUILD(!)
PRE_CMD=set +h && export PATH=$(LFS)/tools/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin && export LC_ALL=POSIX

# =============================================================================
# BEGIN OF HOST BUILD (aka cross-compile tools)
# =============================================================================

# === extra
build-host.txt: src/config.guess
	cd src && chmod ugo+x config.guess && ./config.guess > ../$@

pkg0/.gitignore: build-host.txt
	mkdir -p lfs-chroot/opt/mysdk/tmp
	ln -sfv lfs-chroot/opt/mysdk/tmp tmp
	mkdir -p pkg0 && touch $@

# === LFS-10.0-systemd :: 5.4. Linux API Headers :: "make hst-headers"
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/linux-headers.html
# BUILD_TIME :: 1 m 32s
pkg0/lfs-kernel-headers.cpio.zst: src/orangepi5-linux510.src.cpio.zst pkg0/.gitignore
	rm -fr tmp
	rm -fr lfs-chroot
	mkdir -p lfs-chroot/opt/mysdk/tmp
	ln -sf lfs-chroot/opt/mysdk/tmp tmp
	rm -fr tmp/kernel-headers
	mkdir -p tmp/kernel-headers/src
	cat $< | zstd -d | cpio -iduH newc --quiet -D tmp/kernel-headers/src
	find tmp/kernel-headers/src -name "Makefile" -exec sed -i "s|-O2|$(BASE_OPT_VALUE)|" {} +
	mkdir -p tmp/kernel-headers/bld
	cd tmp/kernel-headers/src && make V=$(VERB) O=../bld rockchip_linux_defconfig
	cd tmp/kernel-headers/bld && make kernelversion > ../kerver.txt
	sed -i '/make/d' tmp/kernel-headers/kerver.txt
	cp -f tmp/kernel-headers/kerver.txt .
	cd tmp/kernel-headers/bld && make V=$(VERB) INSTALL_HDR_PATH=../ins/usr headers_install
	mkdir -p tmp/kernel-headers/pkg0 && cd tmp/kernel-headers/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
#	mkdir -p pkg0
	mv -f tmp/kernel-headers/$@ pkg0/
	rm -fr tmp/kernel-headers
	mkdir -p lfs-cross
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-headers: pkg0/lfs-kernel-headers.cpio.zst

# === LFS-10.0-systemd :: 5.2. Binutils - Pass 1 :: "make hst-binutils1" (deps : Linux Kernel Headers)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/binutils-pass1.html
# BUILD_TIME :: 1m 45s
BINUTILS1_OPT0+= --with-sysroot=$(LFS)
BINUTILS1_OPT0+= --prefix=$(LFS)/tools
BINUTILS1_OPT0+= --target=$(LFS_TGT)
BINUTILS1_OPT0+= --disable-nls
BINUTILS1_OPT0+= --disable-werror
BINUTILS1_OPT0+= $(OPT_FLAGS)
BINUTILS1_OPT0+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst: src/binutils-$(BINUTILS_VER).tar.xz pkg0/lfs-kernel-headers.cpio.zst
	rm -fr tmp/lfs-hst-binutils1
	mkdir -p tmp/lfs-hst-binutils1/bld
	tar -xJf $< -C tmp/lfs-hst-binutils1
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/lfs-hst-binutils1/binutils-$(BINUTILS_VER)/ld/Makefile.in
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils1/bld && ../binutils-$(BINUTILS_VER)/configure $(BINUTILS1_OPT0)' && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils1/bld && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-binutils1/ins$(LFS)/tools/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-binutils1/ins$(LFS)/tools/$(LFS_TGT)/bin/* || true
	strip --strip-unneeded tmp/lfs-hst-binutils1/ins$(LFS)/tools/bin/* || true
endif
	mkdir -p tmp/lfs-hst-binutils1/pkg0
	cd tmp/lfs-hst-binutils1/ins$(LFS) && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../../$@
	mv -f tmp/lfs-hst-binutils1/$@ pkg0/
	rm -fr tmp/lfs-hst-binutils1
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-binutils1: pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst

# === LFS-10.0-systemd :: 5.3. GCC - Pass 1 :: "make hst-gcc1" (deps : hst-binutils1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/gcc-pass1.html
# BUILD_TIME :: 9m 6s (incremental 12m 15s)
GCC1_OPT0+= --with-sysroot=$(LFS)
GCC1_OPT0+= --prefix=$(LFS)/tools
GCC1_OPT0+= --target=$(LFS_TGT)
GCC1_OPT0+= --with-glibc-version=2.11
GCC1_OPT0+= --with-newlib
GCC1_OPT0+= --without-headers
GCC1_OPT0+= --enable-initfini-array
GCC1_OPT0+= --disable-nls
GCC1_OPT0+= --disable-shared
GCC1_OPT0+= --disable-multilib
GCC1_OPT0+= --disable-decimal-float
GCC1_OPT0+= --disable-threads
GCC1_OPT0+= --disable-libatomic
GCC1_OPT0+= --disable-libgomp
GCC1_OPT0+= --disable-libquadmath
GCC1_OPT0+= --disable-libssp
GCC1_OPT0+= --disable-libvtv
GCC1_OPT0+= --disable-libstdcxx
GCC1_OPT0+= --enable-languages=c,c++
GCC1_OPT0+= $(OPT_FLAGS)
GCC1_OPT0+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC1_OPT0+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg0/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst: src/gcc-$(GCC_VER).tar.xz src/gmp-$(GMP_VER).tar.xz src/mpfr-$(MPFR_VER).tar.xz src/mpc-$(MPC_VER).tar.gz pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst
	rm -fr tmp/lfs-hst-gcc1
	mkdir -p tmp/lfs-hst-gcc1
	tar -xJf src/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-gcc1
	tar -xJf src/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf src/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf src/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/libgcc/Makefile.in
	mkdir -p tmp/lfs-hst-gcc1/bld && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gcc1/bld && ../gcc-$(GCC_VER)/configure $(GCC1_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	cat tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/limitx.h tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/glimits.h tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/limity.h > tmp/lfs-hst-gcc1/ins$(LFS)/tools/lib/gcc/$(LFS_TGT)/$(GCC_VER)/install-tools/include/limits.h
	rm -fr tmp/lfs-hst-gcc1/ins$(LFS)/tools/share
	rm -fr tmp/lfs-hst-gcc1/ins$(LFS)/tools/include
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools -name "README" -delete
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools/lib -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-gcc1/ins$(LFS)/tools && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-gcc1/pkg0
	cd tmp/lfs-hst-gcc1/ins$(LFS) && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../../$@
	mv -f tmp/lfs-hst-gcc1/$@ pkg0/
	rm -fr tmp/lfs-hst-gcc1
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-gcc1: pkg0/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst

# === LFS-10.0-systemd :: 5.5. Glibc-2.32 :: "make hst-glibc" (deps : hst-gcc1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/glibc.html
# BUILD_TIME :: 5m 46s
GLIBC_OPT0+= --prefix=/usr
GLIBC_OPT0+= --host=$(LFS_TGT)
GLIBC_OPT0+= --enable-kernel=3.2
GLIBC_OPT0+= --with-headers=$(LFS)/usr/include
GLIBC_OPT0+= libc_cv_slibdir=/lib
GLIBC_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-glibc-$(GLIBC_VER).cpio.zst: src/glibc-$(GLIBC_VER).tar.xz src/glibc-$(GLIBC_VER)-fhs-1.patch pkg0/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst
	rm -fr tmp/lfs-hst-glibc
	mkdir -p tmp/lfs-hst-glibc
	cp -far src/glibc-$(GLIBC_VER)-fhs-1.patch tmp/lfs-hst-glibc
	tar -xJf $< -C tmp/lfs-hst-glibc
	cd tmp/lfs-hst-glibc/glibc-$(GLIBC_VER) && patch -Np1 -i ../glibc-$(GLIBC_VER)-fhs-1.patch
	sed -i '30 a DIAG_PUSH_NEEDS_COMMENT;' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	sed -i '31 a DIAG_IGNORE_Os_NEEDS_COMMENT (8, "-Wmaybe-uninitialized");' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	sed -i '33 a DIAG_POP_NEEDS_COMMENT;' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/scripts/config.guess > lfs-cross/tools/build-host.txt
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/Makerules
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/Makeconfig
	mkdir -p tmp/lfs-hst-glibc/bld && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-glibc/bld && ../glibc-$(GLIBC_VER)/configure $(GLIBC_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
ifeq ($(BUILD_STRIP),y)
	find tmp/lfs-hst-glibc/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-glibc/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	rm -fr tmp/lfs-hst-glibc/ins/usr/share/info
	rm -fr tmp/lfs-hst-glibc/ins/usr/share/locale/*
	cp -far tmp/lfs-hst-glibc/ins/usr/share/i18n/charmaps/UTF-8.gz tmp/lfs-hst-glibc/ins/usr/share/i18n/
	rm -fr tmp/lfs-hst-glibc/ins/usr/share/i18n/charmaps/*
	mv tmp/lfs-hst-glibc/ins/usr/share/i18n/UTF-8.gz tmp/lfs-hst-glibc/ins/usr/share/i18n/charmaps/
	cp -far tmp/lfs-hst-glibc/ins/usr/share/i18n/locales/en_US tmp/lfs-hst-glibc/ins/usr/share/i18n/
	cp -far tmp/lfs-hst-glibc/ins/usr/share/i18n/locales/POSIX tmp/lfs-hst-glibc/ins/usr/share/i18n/
	rm -fr tmp/lfs-hst-glibc/ins/usr/share/i18n/locales/*
	mv tmp/lfs-hst-glibc/ins/usr/share/i18n/en_US tmp/lfs-hst-glibc/ins/usr/share/i18n/locales/
	mv tmp/lfs-hst-glibc/ins/usr/share/i18n/POSIX tmp/lfs-hst-glibc/ins/usr/share/i18n/locales/
	cd tmp/lfs-hst-glibc/ins/usr && ln -sf lib lib64
	mv tmp/lfs-hst-glibc/ins/lib/* tmp/lfs-hst-glibc/ins/usr/lib/
	rm -fr tmp/lfs-hst-glibc/ins/lib
	cd tmp/lfs-hst-glibc/ins && ln -sf usr/lib lib && ln -sf usr/lib lib64
	mv tmp/lfs-hst-glibc/ins/sbin/* tmp/lfs-hst-glibc/ins/usr/sbin/
	rm -fr tmp/lfs-hst-glibc/ins/sbin
	cd tmp/lfs-hst-glibc/ins && ln -sf usr/bin bin && ln -sf usr/sbin sbin
	mkdir -p tmp/lfs-hst-glibc/pkg0
	cd tmp/lfs-hst-glibc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-glibc/$@ pkg0/
	rm -fr tmp/lfs-hst-glibc
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-glibc: pkg0/lfs-hst-glibc-$(GLIBC_VER).cpio.zst

# === LFS-10.0-systemd :: 5.6. Libstdc++ from GCC-10.2.0, Pass 1 :: "make hst-libcpp1" (deps : hst-glibc)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/gcc-libstdc++-pass1.html
# BUILD_TIME :: 2m 10s
LIBCPP1_OPT0+= --host=$(LFS_TGT)
LIBCPP1_OPT0+= --prefix=/usr
LIBCPP1_OPT0+= --disable-multilib
LIBCPP1_OPT0+= --disable-nls
LIBCPP1_OPT0+= --disable-libstdcxx-pch
LIBCPP1_OPT0+= --with-gxx-include-dir=/tools/$(LFS_TGT)/include/c++/$(GCC_VER)
LIBCPP1_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-libcpp.pass1.cpio.zst: src/gcc-$(GCC_VER).tar.xz src/gmp-$(GMP_VER).tar.xz src/mpfr-$(MPFR_VER).tar.xz src/mpc-$(MPC_VER).tar.gz pkg0/lfs-hst-glibc-$(GLIBC_VER).cpio.zst
	lfs-cross/tools/libexec/gcc/$(LFS_TGT)/$(GCC_VER)/install-tools/mkheaders
	rm -fr tmp/lfs-hst-libcpp1
	mkdir -p tmp/lfs-hst-libcpp1
	tar -xJf src/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-libcpp1
	tar -xJf src/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf src/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf src/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	sed -i 's|-O1|$(BASE_OPT_VALUE)|' tmp/lfs-hst-libcpp1/gcc-$(GCC_VER)/libstdc++-v3/configure
	mkdir -p tmp/lfs-hst-libcpp1/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-libcpp1/bld && ../gcc-$(GCC_VER)/libstdc++-v3/configure --build=`cat $(shell pwd)/build-host.txt` $(LIBCPP1_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	find tmp/lfs-hst-libcpp1/ins -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	find tmp/lfs-hst-libcpp1/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-libcpp1/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-libcpp1/ins/usr/lib
	mv tmp/lfs-hst-libcpp1/ins/usr/lib64/* tmp/lfs-hst-libcpp1/ins/usr/lib/
	rm -fr tmp/lfs-hst-libcpp1/ins/usr/lib64
	mkdir -p tmp/lfs-hst-libcpp1/pkg0
	cd tmp/lfs-hst-libcpp1/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-libcpp1/$@ pkg0/
	rm -fr tmp/lfs-hst-libcpp1
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-libcpp1: pkg0/lfs-hst-libcpp.pass1.cpio.zst

# === LFS-10.0-systemd :: 6.2. M4-1.4.18 :: "make hst-m4" (deps : hst-libcpp1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/m4.html
# BUILD_TIME :: 56s
M4_OPT0+= --prefix=/usr
M4_OPT0+= --host=$(LFS_TGT)
M4_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-m4-$(M4_VER).cpio.zst: src/m4-$(M4_VER).tar.xz pkg0/lfs-hst-libcpp.pass1.cpio.zst
	rm -fr tmp/lfs-hst-m4
	mkdir -p tmp/lfs-hst-m4
	tar -xJf $< -C tmp/lfs-hst-m4
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/lfs-hst-m4/m4-$(M4_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/lfs-hst-m4/m4-$(M4_VER)/lib/stdio-impl.h
	mkdir -p tmp/lfs-hst-m4/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-m4/bld && ../m4-$(M4_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(M4_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-m4/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-m4/ins/usr/bin/m4
endif
	mkdir -p tmp/lfs-hst-m4/pkg0
	cd tmp/lfs-hst-m4/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-m4/$@ pkg0/
	rm -fr tmp/lfs-hst-m4
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-m4: pkg0/lfs-hst-m4-$(M4_VER).cpio.zst

# === LFS-10.0-systemd :: 6.3. Ncurses-6.2 :: "make hst-ncurses" (deps : hst-m4)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/ncurses.html
# BUILD_TIME :: 2m 30s
NCURSES_OPT0+= --prefix=/usr
NCURSES_OPT0+= --host=$(LFS_TGT)
NCURSES_OPT0+= --mandir=/usr/share/man
NCURSES_OPT0+= --with-manpage-format=normal
NCURSES_OPT0+= --without-manpages
NCURSES_OPT0+= --with-default-terminfo-dir=/usr/share/terminfo
NCURSES_OPT0+= --with-shared
NCURSES_OPT0+= --without-debug
NCURSES_OPT0+= --without-ada
NCURSES_OPT0+= --without-normal
NCURSES_OPT0+= --with-termlib
NCURSES_OPT0+= --with-ticlib
NCURSES_OPT0+= --enable-widec
NCURSES_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst: src/ncurses-$(NCURSES_VER).tar.gz pkg0/lfs-hst-m4-$(M4_VER).cpio.zst
	rm -fr tmp/lfs-hst-ncurses
	mkdir -p tmp/lfs-hst-ncurses
	tar -xzf $< -C tmp/lfs-hst-ncurses
	sed -i s/mawk// tmp/lfs-hst-ncurses/ncurses-$(NCURSES_VER)/configure
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/lfs-hst-ncurses/ncurses-$(NCURSES_VER)/configure
	mkdir -p tmp/lfs-hst-ncurses/bld-tic
	cd tmp/lfs-hst-ncurses/bld-tic && ../ncurses-$(NCURSES_VER)/configure && make -C include && make -C progs tic
	mkdir -p tmp/lfs-hst-ncurses/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-ncurses/bld && ../ncurses-$(NCURSES_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(NCURSES_OPT0) && make $(JOBS) V=$(VERB) && make TIC_PATH=`pwd`/../bld-tic/progs/tic LD_LIBRARY_PATH=`pwd`/../bld-tic/lib DESTDIR=`pwd`/../ins install'
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-ncurses/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	echo "INPUT(-lncursesw)" > tmp/lfs-hst-ncurses/ins/usr/lib/libncurses.so
	mkdir -p tmp/lfs-hst-ncurses/pkg0
	cd tmp/lfs-hst-ncurses/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-ncurses/$@ pkg0/
	rm -fr tmp/lfs-hst-ncurses
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-ncurses: pkg0/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst

# === LFS-10.0-systemd :: 6.4. Bash-5.0 :: "make hst-bash" (deps : hst-ncurses)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/bash.html
# BUILD_TIME :: 1m 26s
BASH_OPT0+= --prefix=/usr
BASH_OPT0+= --host=$(LFS_TGT)
BASH_OPT0+= --without-bash-malloc
BASH_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-bash-$(BASH_VER).cpio.zst: src/bash-$(BASH_VER).tar.gz pkg0/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst
	rm -fr tmp/lfs-hst-bash
	mkdir -p tmp/lfs-hst-bash/bld
	tar -xzf $< -C tmp/lfs-hst-bash
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-bash/bld && ../bash-$(BASH_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(BASH_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-bash/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-bash/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/lfs-hst-bash/ins/usr/bin && ln -sf bash sh
	mkdir -p tmp/lfs-hst-bash/pkg0
	cd tmp/lfs-hst-bash/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-bash/$@ pkg0/
	rm -fr tmp/lfs-hst-bash
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-bash: pkg0/lfs-hst-bash-$(BASH_VER).cpio.zst

# === LFS-10.0-systemd :: 6.5. Coreutils-8.32 :: "make hst-coreutils" (deps : hst-bash)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/coreutils.html
# BUILD_TIME :: 2m 28s
COREUTILS_OPT0+= --prefix=/usr
COREUTILS_OPT0+= --host=$(LFS_TGT)
COREUTILS_OPT0+= --enable-install-program=hostname
COREUTILS_OPT0+= --enable-no-install-program=kill,uptime
COREUTILS_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst: src/coreutils-$(CORE_UTILS_VER).tar.xz pkg0/lfs-hst-bash-$(BASH_VER).cpio.zst
	rm -fr tmp/lfs-hst-coreutils
	mkdir -p tmp/lfs-hst-coreutils/bld
	tar -xJf $< -C tmp/lfs-hst-coreutils
	sed -i "s/SYS_getdents/SYS_getdents64/" tmp/lfs-hst-coreutils/coreutils-$(CORE_UTILS_VER)/src/ls.c
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-coreutils/bld && ../coreutils-$(CORE_UTILS_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(COREUTILS_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-coreutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-coreutils/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-coreutils/pkg0
	cd tmp/lfs-hst-coreutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-coreutils/$@ pkg0/
	rm -fr tmp/lfs-hst-coreutils
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-coreutils: pkg0/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst

# === LFS-10.0-systemd :: 6.6. Diffutils-3.7 :: "make hst-diffutils" (deps : hst-coreutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/diffutils.html
# BUILD_TIME :: 56s
DIFFUTILS_OPT0+= --prefix=/usr
DIFFUTILS_OPT0+= --host=$(LFS_TGT)
DIFFUTILS_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst: src/diffutils-$(DIFF_UTILS_VER).tar.xz pkg0/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-diffutils
	mkdir -p tmp/lfs-hst-diffutils/bld
	tar -xJf $< -C tmp/lfs-hst-diffutils
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-diffutils/bld && ../diffutils-$(DIFF_UTILS_VER)/configure $(DIFFUTILS_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-diffutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-diffutils/ins/usr/bin/*
endif
	mkdir -p tmp/lfs-hst-diffutils/pkg0
	cd tmp/lfs-hst-diffutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-diffutils/$@ pkg0/
	rm -fr tmp/lfs-hst-diffutils
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-diffutils: pkg0/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst

# === LFS-10.0-systemd :: 6.7. File-5.39 :: "make hst-file" (deps : hst-diffutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/file.html
# BUILD_TIME :: 30s
FILE_OPT0+= --prefix=/usr
FILE_OPT0+= --host=$(LFS_TGT)
FILE_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-file-$(FILE_VER).cpio.zst: src/file-$(FILE_VER).tar.gz pkg0/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-file
	mkdir -p tmp/lfs-hst-file/bld
	tar -xzf $< -C tmp/lfs-hst-file
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-file/bld && ../file-$(FILE_VER)/configure $(FILE_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-file/ins/usr/share/man
	find tmp/lfs-hst-file/ins -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-file/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-file/pkg0
	cd tmp/lfs-hst-file/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-file/$@ pkg0/
	rm -fr tmp/lfs-hst-file
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-file: pkg0/lfs-hst-file-$(FILE_VER).cpio.zst

# === LFS-10.0-systemd :: 6.8. Findutils-4.7.0 :: "make hst-findutils" (deps : hst-file)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/findutils.html
# BUILD_TIME :: 1m 30s
FINDUTILS_OPT0+= --prefix=/usr
FINDUTILS_OPT0+= --host=$(LFS_TGT)
FINDUTILS_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst: src/findutils-$(FIND_UTILS_VER).tar.xz pkg0/lfs-hst-file-$(FILE_VER).cpio.zst
	rm -fr tmp/lfs-hst-findutils
	mkdir -p tmp/lfs-hst-findutils/bld
	tar -xJf $< -C tmp/lfs-hst-findutils
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-findutils/bld && ../findutils-$(FIND_UTILS_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(FINDUTILS_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-findutils/ins/usr/var
	rm -fr tmp/lfs-hst-findutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-findutils/ins/usr/bin/* || true
	strip --strip-unneeded tmp/lfs-hst-findutils/ins/usr/libexec/*
endif
	mkdir -p tmp/lfs-hst-findutils/pkg0
	cd tmp/lfs-hst-findutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-findutils/$@ pkg0/
	rm -fr tmp/lfs-hst-findutils
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-findutils: pkg0/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst

# === LFS-10.0-systemd :: 6.9. Gawk-5.1.0 :: "make hst-gawk" (deps : hst-findutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gawk.html
# BUILD_TIME :: 59s
GAWK_OPT0+= --prefix=/usr
GAWK_OPT0+= --host=$(LFS_TGT)
GAWK_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-gawk-$(GAWK_VER).cpio.zst: src/gawk-$(GAWK_VER).tar.xz pkg0/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-gawk
	mkdir -p tmp/lfs-hst-gawk/bld
	tar -xJf $< -C tmp/lfs-hst-gawk
	sed -i 's/extras//' tmp/lfs-hst-gawk/gawk-$(GAWK_VER)/Makefile.in
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gawk/bld && ../gawk-$(GAWK_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(GAWK_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/info
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/locale
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-gawk/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-gawk/pkg0
	cd tmp/lfs-hst-gawk/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-gawk/$@ pkg0/
	rm -fr tmp/lfs-hst-gawk
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-gawk: pkg0/lfs-hst-gawk-$(GAWK_VER).cpio.zst

# === LFS-10.0-systemd :: 6.10. Grep-3.4 :: "make hst-grep" (deps : hst-gawk)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/grep.html
# BUILD_TIME :: 1m 2s
GREP_OPT0+= --prefix=/usr
GREP_OPT0+= --host=$(LFS_TGT)
GREP_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-grep-$(GREP_VER).cpio.zst: src/grep-$(GREP_VER).tar.xz pkg0/lfs-hst-gawk-$(GAWK_VER).cpio.zst
	rm -fr tmp/lfs-hst-grep
	mkdir -p tmp/lfs-hst-grep/bld
	tar -xJf $< -C tmp/lfs-hst-grep
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-grep/bld && ../grep-$(GREP_VER)/configure $(GREP_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-grep/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-grep/ins/usr/bin/grep
endif
	mkdir -p tmp/lfs-hst-grep/pkg0
	cd tmp/lfs-hst-grep/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-grep/$@ pkg0/
	rm -fr tmp/lfs-hst-grep
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-grep: pkg0/lfs-hst-grep-$(GREP_VER).cpio.zst

# === LFS-10.0-systemd :: 6.11. Gzip-1.10 :: "make hst-gzip" (deps : hst-grep)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gzip.html
# BUILD_TIME :: 38s
GZIP_OPT0+= --prefix=/usr
GZIP_OPT0+= --host=$(LFS_TGT)
GZIP_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-gzip-$(GZIP_VER).cpio.zst: src/gzip-$(GZIP_VER).tar.xz pkg0/lfs-hst-grep-$(GREP_VER).cpio.zst
	rm -fr tmp/lfs-hst-gzip
	mkdir -p tmp/lfs-hst-gzip/bld
	tar -xJf $< -C tmp/lfs-hst-gzip
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gzip/bld && ../gzip-$(GZIP_VER)/configure $(GZIP_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gzip/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-gzip/ins/usr/bin/* || true
endif
	mkdir -p tmp/lfs-hst-gzip/pkg0
	cd tmp/lfs-hst-gzip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-gzip/$@ pkg0/
	rm -fr tmp/lfs-hst-gzip
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-gzip: pkg0/lfs-hst-gzip-$(GZIP_VER).cpio.zst

# === LFS-10.0-systemd :: 6.12. Make-4.3 :: "make hst-make" (deps : hst-gzip)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/make.html
# BUILD_TIME :: 33s
MAKE_OPT0+= --prefix=/usr
MAKE_OPT0+= --without-guile
MAKE_OPT0+= --host=$(LFS_TGT)
MAKE_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-make-$(MAKE_VER).cpio.zst: src/make-$(MAKE_VER).tar.gz pkg0/lfs-hst-gzip-$(GZIP_VER).cpio.zst
	rm -fr tmp/lfs-hst-make
	mkdir -p tmp/lfs-hst-make/bld
	tar -xzf $< -C tmp/lfs-hst-make
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-make/bld && ../make-$(MAKE_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(MAKE_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-make/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-make/ins/usr/bin/make
endif
	mkdir -p tmp/lfs-hst-make/pkg0
	cd tmp/lfs-hst-make/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-make/$@ pkg0/
	rm -fr tmp/lfs-hst-make
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-make: pkg0/lfs-hst-make-$(MAKE_VER).cpio.zst

# === LFS-10.0-systemd :: 6.13. Patch-2.7.6 :: "make hst-patch" (deps : hst-make)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/patch.html
# BUILD_TIME :: 1m 10s
PATCH_OPT0+= --prefix=/usr
PATCH_OPT0+= --host=$(LFS_TGT)
PATCH_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-patch-$(PATCH_VER).cpio.zst: src/patch-$(PATCH_VER).tar.xz pkg0/lfs-hst-make-$(MAKE_VER).cpio.zst
	rm -fr tmp/lfs-hst-patch
	mkdir -p tmp/lfs-hst-patch/bld
	tar -xJf $< -C tmp/lfs-hst-patch
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-patch/bld && ../patch-$(PATCH_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(PATCH_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-patch/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-patch/ins/usr/bin/*
endif
	mkdir -p tmp/lfs-hst-patch/pkg0
	cd tmp/lfs-hst-patch/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-patch/$@ pkg0/
	rm -fr tmp/lfs-hst-patch
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-patch: pkg0/lfs-hst-patch-$(PATCH_VER).cpio.zst

# === LFS-10.0-systemd :: 6.14. Sed-4.8 :: "make hst-sed" (deps : hst-patch)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/sed.html
# BUILD_TIME :: 55s
SED_OPT0+= --prefix=/usr
SED_OPT0+= --host=$(LFS_TGT)
SED_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-sed-$(SED_VER).cpio.zst: src/sed-$(SED_VER).tar.xz pkg0/lfs-hst-patch-$(PATCH_VER).cpio.zst
	rm -fr tmp/lfs-hst-sed
	mkdir -p tmp/lfs-hst-sed/bld
	tar -xJf $< -C tmp/lfs-hst-sed
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-sed/bld && ../sed-$(SED_VER)/configure $(SED_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-sed/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-sed/ins/usr/bin/*
endif
	mkdir -p tmp/lfs-hst-sed/pkg0
	cd tmp/lfs-hst-sed/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-sed/$@ pkg0/
	rm -fr tmp/lfs-hst-sed
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-sed: pkg0/lfs-hst-sed-$(SED_VER).cpio.zst

# === LFS-10.0-systemd :: 6.15. Tar-1.32 :: "make hst-tar" (deps : hst-sed)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/tar.html
# BUILD_TIME :: 1m 14s
TAR_OPT0+= --prefix=/usr
TAR_OPT0+= --host=$(LFS_TGT)
TAR_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-tar-$(TAR_VER).cpio.zst: src/tar-$(TAR_VER).tar.xz pkg0/lfs-hst-sed-$(SED_VER).cpio.zst
	rm -fr tmp/lfs-hst-tar
	mkdir -p tmp/lfs-hst-tar/bld
	tar -xJf $< -C tmp/lfs-hst-tar
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-tar/bld && ../tar-$(TAR_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(TAR_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-tar/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-tar/ins/usr/bin/*
	strip --strip-unneeded tmp/lfs-hst-tar/ins/usr/libexec/*
endif
	mkdir -p tmp/lfs-hst-tar/pkg0
	cd tmp/lfs-hst-tar/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-tar/$@ pkg0/
	rm -fr tmp/lfs-hst-tar
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-tar: pkg0/lfs-hst-tar-$(TAR_VER).cpio.zst

# === LFS-10.0-systemd :: 6.16. Xz-5.2.5 :: "make hst-xz" (deps : hst-tar)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/xz.html
# BUILD_TIME :: 35s
XZ_OPT0+= --prefix=/usr
XZ_OPT0+= --host=$(LFS_TGT)
XZ_OPT0+= --disable-static
XZ_OPT0+= --docdir=/usr/share/doc/xz-$(XZ_VER)
XZ_OPT0+= $(OPT_FLAGS)
pkg0/lfs-hst-xz-$(XZ_VER).cpio.zst: src/xz-$(XZ_VER).tar.xz pkg0/lfs-hst-tar-$(TAR_VER).cpio.zst
	rm -fr tmp/lfs-hst-xz
	mkdir -p tmp/lfs-hst-xz/bld
	tar -xJf $< -C tmp/lfs-hst-xz
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-xz/bld && ../xz-$(XZ_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(XZ_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-xz/ins/usr/share
	find tmp/lfs-hst-xz/ins -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-xz/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-xz/pkg0
	cd tmp/lfs-hst-xz/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-xz/$@ pkg0/
	rm -fr tmp/lfs-hst-xz
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-xz: pkg0/lfs-hst-xz-$(XZ_VER).cpio.zst

# === extra :: zstd :: "make hst-zstd" (deps : hst-xz)
#
# BUILD_TIME :: 1m 19s
ZSTD1_L_OPT = CC=$(LFS_TGT)-gcc ZSTD_LIB_MINIFY=1 ZSTD_LIB_DICTBUILDER=0 MOREFLAGS=$(RK3588_FLAGS) prefix=/usr DESTDIR=../../ins
ZSTD1_P_OPT = CC=$(LFS_TGT)-gcc HAVE_PTHREAD=0 HAVE_THREAD=0 MOREFLAGS=$(RK3588_FLAGS) prefix=/usr DESTDIR=../../ins
pkg0/lfs-hst-zstd-$(ZSTD_VER).cpio.zst: src/zstd-$(ZSTD_VER).tar.gz pkg0/lfs-hst-xz-$(XZ_VER).cpio.zst
	rm -fr tmp/lfs-hst-zstd
	mkdir -p tmp/lfs-hst-zstd/bld
	tar -xzf $< -C tmp/lfs-hst-zstd
	sed -i "s/-O3/$(BASE_OPT_FLAGS)/" tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/programs/Makefile
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/lib && make $(JOBS) $(ZSTD1_L_OPT) lib-all && make $(ZSTD1_L_OPT) install'
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/programs && make $(JOBS) $(ZSTD1_P_OPT) zstd-small && make $(ZSTD1_P_OPT) zstd-small install'
	rm -fr tmp/lfs-hst-zstd/ins/usr/share
	rm -fr tmp/lfs-hst-zstd/ins/usr/lib/*.a
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-zstd/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/lfs-hst-zstd/ins/usr/bin/zstd
endif
	mkdir -p tmp/lfs-hst-zstd/pkg0
	cd tmp/lfs-hst-zstd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-zstd/$@ pkg0/
	rm -fr tmp/lfs-hst-zstd
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-zstd: pkg0/lfs-hst-zstd-$(ZSTD_VER).cpio.zst

# === extra (BLFS-10) :: cpio :: "make hst-cpio" (deps : hst-zstd)
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/cpio.html
# BUILD_TIME :: 1m 24s
CPIO_OPT0+= --prefix=/usr
CPIO_OPT0+= --host=$(LFS_TGT)
CPIO_OPT0+= --disable-nls
CPIO_OPT0+= --disable-static
CPIO_OPT0+= --with-rmt=/usr/libexec/rmt
CPIO_OPT0+= CFLAGS="$(RK3588_FLAGS) -Os -fcommon"
pkg0/lfs-hst-cpio-$(CPIO_VER).cpio.zst: src/cpio-$(CPIO_VER).tar.bz2 pkg0/lfs-hst-zstd-$(ZSTD_VER).cpio.zst
	rm -fr tmp/lfs-hst-cpio
	mkdir -p tmp/lfs-hst-cpio/bld
	tar -xjf $< -C tmp/lfs-hst-cpio
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-cpio/bld && ../cpio-$(CPIO_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(CPIO_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-cpio/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/lfs-hst-cpio/ins/usr/bin/cpio
endif
	mkdir -p tmp/lfs-hst-cpio/pkg0
	cd tmp/lfs-hst-cpio/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-cpio/$@ pkg0/
	rm -fr tmp/lfs-hst-cpio
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-cpio: pkg0/lfs-hst-cpio-$(CPIO_VER).cpio.zst

# === extra :: pv :: "make hst-pv" (deps: hst-cpio)
# http://www.ivarch.com/programs/pv.shtml
# https://github.com/icetee/pv
# BUILD_TIME :: 15s
#PV_OPT0+= --prefix=/usr
#PV_OPT0+= --host=$(LFS_TGT)
#PV_OPT0+= --disable-nls
#PV_OPT0+= --disable-splice
#PV_OPT0+= --disable-ipc
#PV_OPT0+= $(OPT_FLAGS)
#pkg0/lfs-hst-pv-$(PV_VER).cpio.zst: src/pv_$(PV_VER).orig.tar.bz2 pkg0/lfs-hst-cpio-$(CPIO_VER).cpio.zst
#	rm -fr tmp/lfs-hst-pv
#	mkdir -p tmp/lfs-hst-pv/bld
#	tar -xjf $< -C tmp/lfs-hst-pv
#	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-pv/bld && ../pv-$(PV_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(PV_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
#	rm -fr tmp/lfs-hst-pv/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/lfs-hst-pv/ins/usr/bin/pv
#endif
#	mkdir -p tmp/lfs-hst-pv/pkg0
#	cd tmp/lfs-hst-pv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
#	mv -f tmp/lfs-hst-pv/$@ pkg0/
#	rm -fr tmp/lfs-hst-pv
#	pv $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
#hst-pv: pkg0/lfs-hst-pv-$(PV_VER).cpio.zst

# === LFS-10.0-systemd :: 6.17. Binutils-2.35 - Pass 2 :: "make hst-binutils2" (deps : hst-cpio)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/binutils-pass2.html
# BUILD_TIME :: 2m 20s
BINUTILS2_OPT0+= --prefix=/usr
BINUTILS2_OPT0+= --host=$(LFS_TGT)
BINUTILS2_OPT0+= --disable-nls
BINUTILS2_OPT0+= --enable-shared
BINUTILS2_OPT0+= --disable-werror
BINUTILS2_OPT0+= --enable-64-bit-bfd
BINUTILS2_OPT0+= $(OPT_FLAGS)
BINUTILS2_OPT0+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
BINUTILS2_OPT0+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst: src/binutils-$(BINUTILS_VER).tar.xz pkg0/lfs-hst-cpio-$(CPIO_VER).cpio.zst
	rm -fr tmp/lfs-hst-binutils2
	mkdir -p tmp/lfs-hst-binutils2/bld
	tar -xJf $< -C tmp/lfs-hst-binutils2
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/lfs-hst-binutils2/binutils-$(BINUTILS_VER)/ld/Makefile.in
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils2/bld && ../binutils-$(BINUTILS_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(BINUTILS2_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-binutils2/ins/usr/share
	find tmp/lfs-hst-binutils2/ins/usr/lib -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/lfs-hst-binutils2/ins/usr/lib/*.a
	cd tmp/lfs-hst-binutils2/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	mkdir -p tmp/lfs-hst-binutils2/pkg0
	cd tmp/lfs-hst-binutils2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-binutils2/$@ pkg0/
	rm -fr tmp/lfs-hst-binutils2
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-binutils2: pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst

# === LFS-10.0-systemd :: 6.18. GCC-10.2.0 - Pass 2 :: "make hst-gcc2" (deps : hst-binutils2)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gcc-pass2.html
# BUILD_TIME :: 12m 16s
GCC2_OPT0+= --host=$(LFS_TGT)
GCC2_OPT0+= --prefix=/usr
GCC2_OPT0+= CC_FOR_TARGET=$(LFS_TGT)-gcc
GCC2_OPT0+= --with-build-sysroot=$(LFS)
GCC2_OPT0+= --enable-initfini-array
GCC2_OPT0+= --disable-nls
GCC2_OPT0+= --disable-multilib
GCC2_OPT0+= --disable-decimal-float
GCC2_OPT0+= --disable-libatomic
GCC2_OPT0+= --disable-libgomp
GCC2_OPT0+= --disable-libquadmath
GCC2_OPT0+= --disable-libssp
GCC2_OPT0+= --disable-libvtv
GCC2_OPT0+= --disable-libstdcxx
GCC2_OPT0+= --enable-languages=c,c++
GCC2_OPT0+= $(OPT_FLAGS)
GCC2_OPT0+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC2_OPT0+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg0/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst: src/gcc-$(GCC_VER).tar.xz pkg0/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst
	rm -fr tmp/lfs-hst-gcc2
	mkdir -p tmp/lfs-hst-gcc2/bld
	tar -xJf src/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-gcc2
	tar -xJf src/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf src/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf src/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/lfs-hst-gcc2/gcc-$(GCC_VER)/libgcc/Makefile.in
	cd tmp/lfs-hst-gcc2/bld && mkdir -p $(LFS_TGT)/libgcc && cd $(LFS_TGT)/libgcc && ln -sfv ../../../gcc-$(GCC_VER)/libgcc/gthr-posix.h gthr-default.h
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gcc2/bld && ../gcc-$(GCC_VER)/configure --build=`cat $(shell pwd)/build-host.txt` $(GCC2_OPT0) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gcc2/ins/usr/share
	find tmp/lfs-hst-gcc2/ins -name \*.la -delete
	mv tmp/lfs-hst-gcc2/ins/usr/lib64/* tmp/lfs-hst-gcc2/ins/usr/lib/
	rm -fr tmp/lfs-hst-gcc2/ins/usr/lib64
ifeq ($(BUILD_STRIP),y)
	cd tmp/lfs-hst-gcc2/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	strip --strip-debug tmp/lfs-hst-gcc2/ins/usr/lib/gcc/$(LFS_TGT)/$(GCC_VER)/*.a
endif
	mkdir -p tmp/lfs-hst-gcc2/pkg0
	cd tmp/lfs-hst-gcc2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/lfs-hst-gcc2/$@ pkg0/
	rm -fr tmp/lfs-hst-gcc2
	cat $@ | zstd -d | cpio -iduH newc --quiet -D lfs-cross/	
hst-gcc2: pkg0/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst

# === LFS-10.0-systemd :: 7.2. Changing Ownership :: (deps : hst-gcc2)
# === LFS-10.0-systemd :: 7.3. Preparing Virtual Kernel File Systems 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/changingowner.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/kernfs.html
# BUILD TIME :: 13s
pkg0/lfs-hst-full.cpio.zst: pkg0/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst
	sudo rm -fr lfs-chroot
	rm -fr tmp
	mkdir -p lfs-chroot/opt/mysdk/tmp
	ln -sfv lfs-chroot/opt/mysdk/tmp tmp
#	sudo rm -fr tmp/lfs
	mkdir -p tmp/lfs
	cp -far lfs-cross/* tmp/lfs/
	rm -fr tmp/lfs/tools
	mkdir -p tmp/lfs/dev/pts
	mkdir tmp/lfs/proc
	mkdir tmp/lfs/sys
	mkdir tmp/lfs/run
	sudo chown -R root:root tmp/lfs/*
	mkdir -p tmp/lfs/opt/mysdk
	cp -far cfg tmp/lfs/opt/mysdk
	cp -far .git tmp/lfs/opt/mysdk
	cp -f .gitignore tmp/lfs/opt/mysdk
	cp -f README.md tmp/lfs/opt/mysdk
	cp -far src tmp/lfs/opt/mysdk
	cp -f *.zst tmp/lfs/opt/mysdk/
	cp -f Makefile tmp/lfs/opt/mysdk
	mkdir -p tmp/pkg0
	cd tmp/lfs && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../$@
	mv -f tmp/$@ $@
	rm -fr tmp/pkg0
	sudo rm -fr tmp/lfs
hst-full: pkg0/lfs-hst-full.cpio.zst

# === TOTAL: STAGE0= HOST BUILD
# BUILD_TIME :: 45m-50m

# === extra :: Unpack New LFS-ROOTFS (lfs-chroot)
#
lfs-chroot/opt/mysdk/Makefile: pkg0/lfs-hst-full.cpio.zst
	sudo rm -fr lfs-chroot
	mkdir -p lfs-chroot/opt/mysdk/tmp
#	ln -sfv lfs-chroot/opt/mysdk/tmp tmp
	cat $< | zstd -d | cpio -iduH newc --quiet -D lfs-chroot
lfs-chroot/opt/mysdk/chroot1.sh: lfs-chroot/opt/mysdk/Makefile
	mkdir -p lfs-chroot/opt/mysdk
	echo '#!/bin/bash' > $@
	echo 'make -C /opt/mysdk mmc.img' >> $@
#	echo 'make -C /opt/mysdk tgt-uboot-tools' >> $@
	chmod ugo+x $@
#lfs-chroot/opt/mysdk/chroot2.sh: lfs-chroot/opt/mysdk/mmc.img
#	mkdir -p lfs-chroot/opt/mysdk
#	echo '#!/bin/bash' > $@
#	echo 'make -C /opt/mysdk flash || true' >> $@
#	chmod ugo+x $@

stage0: lfs-chroot/opt/mysdk/chroot1.sh

# === LFS-10.0-systemd :: 7.3. Preparing Virtual Kernel File Systems 
# === LFS-10.0-systemd :: 7.4. Entering the Chroot Environment 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/kernfs.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/chroot.html
stage1: lfs-chroot/opt/mysdk/chroot1.sh
img: lfs-chroot/opt/mysdk/chroot1.sh
# CHROOT STAGE1
	sudo mount -v --bind /dev lfs-chroot/dev
	sudo mount -v --bind /dev/pts lfs-chroot/dev/pts
	sudo mount -vt proc proc lfs-chroot/proc
	sudo mount -vt sysfs sysfs lfs-chroot/sys
	sudo mount -vt tmpfs tmpfs lfs-chroot/run
	sudo chroot lfs-chroot /usr/bin/env -i HOME=/root TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin /opt/mysdk/chroot1.sh --login +h
	sudo umount lfs-chroot/run
	sudo umount lfs-chroot/sys
	sudo umount lfs-chroot/proc
	sudo umount lfs-chroot/dev/pts
	sudo umount lfs-chroot/dev

#lfs-chroot/etc/resolv.conf: /etc/resolv.conf
#	sudo cp -f $< $@
#	sudo touch $@
#stage1: lfs-chroot/etc/resolv.conf

chroot: lfs-chroot/opt/mysdk/chroot1.sh
# No Script = Manual Login
	sudo mount -v --bind /dev lfs-chroot/dev
	sudo mount -v --bind /dev/pts lfs-chroot/dev/pts
	sudo mount -vt proc proc lfs-chroot/proc
	sudo mount -vt sysfs sysfs lfs-chroot/sys
	sudo mount -vt tmpfs tmpfs lfs-chroot/run
	sudo chroot lfs-chroot /usr/bin/env -i HOME=/root TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin /bin/sh --login +h
	sudo umount lfs-chroot/run
	sudo umount lfs-chroot/sys
	sudo umount lfs-chroot/proc
	sudo umount lfs-chroot/dev/pts
	sudo umount lfs-chroot/dev
	
chroot-flash: lfs-chroot/opt/mysdk/chroot2.sh
	sudo mount -v --bind /dev lfs-chroot/dev
	sudo mount -v --bind /dev/pts lfs-chroot/dev/pts
	sudo mount -vt proc proc lfs-chroot/proc
	sudo mount -vt sysfs sysfs lfs-chroot/sys
	sudo mount -vt tmpfs tmpfs lfs-chroot/run
	sudo chroot lfs-chroot /usr/bin/env -i HOME=/root TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin /opt/mysdk/chroot2.sh --login +h
	sudo umount lfs-chroot/run
	sudo umount lfs-chroot/sys
	sudo umount lfs-chroot/proc
	sudo umount lfs-chroot/dev/pts
	sudo umount lfs-chroot/dev

unchroot:
	sudo umount lfs-chroot/run || true
	sudo umount lfs-chroot/sys || true
	sudo umount lfs-chroot/proc || true
	sudo umount lfs-chroot/dev/pts || true
	sudo umount lfs-chroot/dev || true

# =============================================================================
# === CHROOT HERE
# =============================================================================

# === LFS-10.0-systemd :: INSIDE CHROOT :: 7.5. Creating Directories 	
# === LFS-10.0-systemd :: INSIDE CHROOT :: 7.6. Creating Essential Files and Symlinks
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/creatingdirs.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/createfiles.html
pkg1/lfs-tgt-initial.cpio.zst:
	rm -fr tmp/initial
	mkdir -p tmp/initial/ins/etc
#
	echo 'root::0:0:root:/root:/bin/bash' > tmp/initial/ins/etc/passwd
	echo 'bin:x:1:1:bin:/dev/null:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'daemon:x:6:6:Daemon User:/dev/null:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-network:x:76:76:systemd Network Management:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-resolve:x:77:77:systemd Resolver:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false' >> tmp/initial/ins/etc/passwd
	echo 'nobody:x:99:99:Unprivileged User:/dev/null:/bin/false' >> tmp/initial/ins/etc/passwd
#
	echo 'root:x:0:' > tmp/initial/ins/etc/group
	echo 'bin:x:1:daemon' >> tmp/initial/ins/etc/group
	echo 'sys:x:2:' >> tmp/initial/ins/etc/group
	echo 'kmem:x:3:' >> tmp/initial/ins/etc/group
	echo 'tape:x:4:' >> tmp/initial/ins/etc/group
	echo 'tty:x:5:' >> tmp/initial/ins/etc/group
	echo 'daemon:x:6:' >> tmp/initial/ins/etc/group
	echo 'floppy:x:7:' >> tmp/initial/ins/etc/group
	echo 'disk:x:8:' >> tmp/initial/ins/etc/group
	echo 'lp:x:9:' >> tmp/initial/ins/etc/group
	echo 'dialout:x:10:' >> tmp/initial/ins/etc/group
	echo 'audio:x:11:' >> tmp/initial/ins/etc/group
	echo 'video:x:12:' >> tmp/initial/ins/etc/group
	echo 'utmp:x:13:' >> tmp/initial/ins/etc/group
	echo 'usb:x:14:' >> tmp/initial/ins/etc/group
	echo 'cdrom:x:15:' >> tmp/initial/ins/etc/group
	echo 'adm:x:16:' >> tmp/initial/ins/etc/group
	echo 'messagebus:x:18:' >> tmp/initial/ins/etc/group
	echo 'systemd-journal:x:23:' >> tmp/initial/ins/etc/group
	echo 'input:x:24:' >> tmp/initial/ins/etc/group
	echo 'mail:x:34:' >> tmp/initial/ins/etc/group
	echo 'kvm:x:61:' >> tmp/initial/ins/etc/group
	echo 'systemd-bus-proxy:x:72:' >> tmp/initial/ins/etc/group
	echo 'systemd-journal-gateway:x:73:' >> tmp/initial/ins/etc/group
	echo 'systemd-journal-remote:x:74:' >> tmp/initial/ins/etc/group
	echo 'systemd-journal-upload:x:75:' >> tmp/initial/ins/etc/group
	echo 'systemd-network:x:76:' >> tmp/initial/ins/etc/group
	echo 'systemd-resolve:x:77:' >> tmp/initial/ins/etc/group
	echo 'systemd-timesync:x:78:' >> tmp/initial/ins/etc/group
	echo 'systemd-coredump:x:79:' >> tmp/initial/ins/etc/group
	echo 'wheel:x:97:' >> tmp/initial/ins/etc/group
	echo 'nogroup:x:99:' >> tmp/initial/ins/etc/group
	echo 'users:x:999:' >> tmp/initial/ins/etc/group
	mkdir -p pkg1
	cd tmp/initial/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/initial
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	mknod -m 600 /dev/console c 5 1 || true
	mknod -m 666 /dev/null c 1 3 || true
	mkdir -p /boot
	mkdir -p /home
	mkdir -p /media
	mkdir -p /mnt
	mkdir -p /srv
	mkdir -p /etc/opt
	mkdir -p /etc/sysconfig
	mkdir -p /lib/firmware
# mkdir -p /media/{floppy,cdrom}
	mkdir -p /usr/local/bin
	mkdir -p /usr/local/include
	mkdir -p /usr/local/lib
	mkdir -p /usr/local/sbin
	mkdir -p /usr/local/src
# mkdir -p /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -p /usr/share/misc
	mkdir -p /usr/share/terminfo
	mkdir -p /usr/share/zoneinfo
	mkdir -p /usr/local/share/misc
	mkdir -p /usr/local/share/terminfo
	mkdir -p /usr/local/share/zoneinfo
# mkdir -p /usr/{,local/}share/man/man{1..8}
	mkdir -p /var/cache
	mkdir -p /var/local
	mkdir -p /var/log
	mkdir -p /var/mail
	mkdir -p /var/opt
	mkdir -p /var/spool
	mkdir -p /var/lib/color
	mkdir -p /var/lib/misc
	mkdir -p /var/lib/locate
	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	ln -sfv /proc/self/mounts /etc/mtab
	sh -c 'echo "127.0.0.1 localhost `hostname`" > /etc/hosts'
#	sh -c 'echo "tester:x:`ls -n $$(tty) | cut -d" " -f3`:101::/home/tester:/bin/bash" >> /etc/passwd'
#	sh -c 'echo "tester:x:101:" >> /etc/group'
#	sh -c 'cd / && install -o tester -d /home/tester'
	touch /var/log/btmp
	touch /var/log/lastlog
	touch /var/log/faillog
	touch /var/log/wtmp
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
chroot-initial: pkg1/lfs-tgt-initial.cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.7. Libstdc++ from GCC-10.2.0, Pass 2 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/gcc-libstdc++-pass2.html
# BUILD_TIME :: 1m 35s
LIBCPP2_OPT1+= --prefix=/usr
LIBCPP2_OPT1+= --host=$(LFS_TGT)
LIBCPP2_OPT1+= --disable-multilib
LIBCPP2_OPT1+= --disable-nls
LIBCPP2_OPT1+= --disable-libstdcxx-pch
LIBCPP2_OPT1+= CFLAGS="$(BASE_OPT_FLAGS)" CPPFLAGS="$(BASE_OPT_FLAGS)" CXXFLAGS="$(BASE_OPT_FLAGS) -D_GNU_SOURCE"
pkg1/lfs-tgt-libcpp.pass2.cpio.zst: pkg1/lfs-tgt-initial.cpio.zst
	rm -fr tmp/tgt-gcc-libcpp
	mkdir -p tmp/tgt-gcc-libcpp/bld
	tar -xJf src/gcc-$(GCC_VER).tar.xz -C tmp/tgt-gcc-libcpp
	tar -xJf src/gmp-$(GMP_VER).tar.xz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf src/mpfr-$(MPFR_VER).tar.xz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf src/mpc-$(MPC_VER).tar.gz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/tgt-gcc-libcpp/gcc-$(GCC_VER)/libstdc++-v3/configure
	sed -i 's|-O1|$(BASE_OPT_VALUE)|' tmp/tgt-gcc-libcpp/gcc-$(GCC_VER)/libstdc++-v3/configure
	cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && ln -sf gthr-posix.h libgcc/gthr-default.h
	cd tmp/tgt-gcc-libcpp/bld && ../gcc-$(GCC_VER)/libstdc++-v3/configure $(LIBCPP2_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	mv -v tmp/tgt-gcc-libcpp/ins/usr/lib64/* tmp/tgt-gcc-libcpp/ins/usr/lib/
	rm -fr tmp/tgt-gcc-libcpp/ins/usr/lib64
	rm -fr tmp/tgt-gcc-libcpp/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/tgt-gcc-libcpp/ins/usr/lib/*.a
	strip --strip-unneeded tmp/tgt-gcc-libcpp/ins/usr/lib/libstdc++.so.6.0.28
endif
	cd tmp/tgt-gcc-libcpp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-gcc-libcpp
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-libcpp: pkg1/lfs-tgt-libcpp.pass2.cpio.zst
 
# LFS-10.0-systemd :: CHROOT :: 7.8. Gettext-0.21
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/gettext.html
# BUILD_TIME :: 6m 30s
#GETTEXT_OPT1+= --prefix=/usr
#GETTEXT_OPT1+= --disable-shared
#GETTEXT_OPT1+= --disable-nls
#GETTEXT_OPT1+= $(OPT_FLAGS)
#pkg1/lfs-tgt-gettext-$(GETTEXT_VER).cpio.zst: pkg1/lfs-tgt-libcpp.pass2.cpio.zst
#	rm -fr tmp/tgt-gettext
#	mkdir -p tmp/tgt-gettext
#	tar -xJf src/gettext-$(GETTEXT_VER).tar.xz -C tmp/tgt-gettext
#	mkdir -p tmp/tgt-gettext/bld
#	cd tmp/tgt-gettext/bld && ../gettext-$(GETTEXT_VER)/configure $(GETTEXT_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/tgt-gettext/ins/usr/share/doc
#	rm -fr tmp/tgt-gettext/ins/usr/share/gettext/projects
#	rm -fr tmp/tgt-gettext/ins/usr/share/info
#	rm -fr tmp/tgt-gettext/ins/usr/share/man
#	rm -fr tmp/tgt-gettext/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-debug tmp/tgt-gettext/ins/usr/lib/*.a
#	strip --strip-unneeded tmp/tgt-gettext/ins/usr/bin/* || true
#	strip --strip-unneeded tmp/tgt-gettext/ins/usr/lib/gettext/* || true
#endif
#	cd tmp/tgt-gettext/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/tgt-gettext
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#chroot-gettext: pkg1/lfs-tgt-gettext-$(GETTEXT_VER).cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.9. Bison-3.7.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/bison.html
# BUILD_TIME :: 1m 4s
BISON_OPT1+= --prefix=/usr
BISON_OPT1+= --docdir=/usr/share/doc/bison-$(BISON_VER)
BISON_OPT1+= --disable-nls
BISON_OPT1+= $(OPT_FLAGS)
#pkg1/lfs-tgt-bison-$(BISON_VER).cpio.zst: pkg1/lfs-tgt-gettext-$(GETTEXT_VER).cpio.zst
pkg1/lfs-tgt-bison-$(BISON_VER).cpio.zst: pkg1/lfs-tgt-libcpp.pass2.cpio.zst
	rm -fr tmp/tgt-bison
	mkdir -p tmp/tgt-bison
	tar -xJf src/bison-$(BISON_VER).tar.xz -C tmp/tgt-bison
	mkdir -p tmp/tgt-bison/bld
	cd tmp/tgt-bison/bld && ../bison-$(BISON_VER)/configure $(BISON_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-bison/ins/usr/share/bison/README.md
	rm -fr tmp/tgt-bison/ins/usr/share/doc
	rm -fr tmp/tgt-bison/ins/usr/share/info
	rm -fr tmp/tgt-bison/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/tgt-bison/ins/usr/lib/*.a
	strip --strip-unneeded tmp/tgt-bison/ins/usr/bin/bison
endif
	cd tmp/tgt-bison/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-bison
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-bison: pkg1/lfs-tgt-bison-$(BISON_VER).cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.10. Perl-5.32.0 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/perl.html
# BUILD_TIME :: 3m 50s
PERL_POPT1+= -des
PERL_POPT1+= -Dcc=gcc
PERL_POPT1+= -Dprefix=/usr
PERL_POPT1+= -Dvendorprefix=/usr
PERL_POPT1+= -Dprivlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT1+= -Darchlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT1+= -Dsitelib=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT1+= -Dsitearch=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT1+= -Dvendorlib=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT1+= -Dvendorarch=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT1+= -Doptimize="$(BASE_OPT_FLAGS)"	
pkg1/lfs-tgt-perl-$(PERL_VER).cpio.zst: pkg1/lfs-tgt-bison-$(BISON_VER).cpio.zst
	rm -fr tmp/tgt-perl
	mkdir -p tmp/tgt-perl
	tar -xJf src/perl-$(PERL_VER).tar.xz -C tmp/tgt-perl
	cd tmp/tgt-perl/perl-$(PERL_VER) && sh Configure $(PERL_POPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins2 install
	mkdir -p tmp/tgt-perl/ins
	cp -far tmp/tgt-perl/ins2/usr tmp/tgt-perl/ins/
ifeq ($(BUILD_STRIP),y)
	cd tmp/tgt-perl/ins/ && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	strip --strip-debug tmp/tgt-perl/ins/usr/lib/perl5/$(PERL_VER0)/core_perl/CORE/*.a
endif
	cd tmp/tgt-perl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-perl
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-perl: pkg1/lfs-tgt-perl-$(PERL_VER).cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.11. Python-3.8.5 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/Python.html
# BUILD_TIME :: 2m 20s
PYTHON_OPT1+= --prefix=/usr
PYTHON_OPT1+= --enable-shared
PYTHON_OPT1+= --without-ensurepip
PYTHON_OPT1+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg1/lfs-tgt-Python-$(PYTHON_VER).cpio.zst: pkg1/lfs-tgt-perl-$(PERL_VER).cpio.zst
	rm -fr tmp/tgt-python
	mkdir -p tmp/tgt-python
	tar -xJf src/Python-$(PYTHON_VER).tar.xz -C tmp/tgt-python
	sed -i "s/-O3/$(BASE_OPT_VALUE)/" tmp/tgt-python/Python-$(PYTHON_VER)/configure
	mkdir -p tmp/tgt-python/bld
	cd tmp/tgt-python/bld && ../Python-$(PYTHON_VER)/configure $(PYTHON_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-python/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	find tmp/tgt-python/ins/usr/lib -type f -name "*.a" -exec strip --strip-debug {} +
	strip --strip-unneeded tmp/tgt-python/ins/usr/bin/python3
	cd  tmp/tgt-python/ins/usr/lib/ && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/tgt-python/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-python
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-python: pkg1/lfs-tgt-Python-$(PYTHON_VER).cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.12. Texinfo-6.7 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/texinfo.html
# BUILD_TIME :: 58s
TEXINFO_OPT1+= --prefix=/usr
TEXINFO_OPT1+= --disable-nls
TEXINFO_OPT1+= $(OPT_FLAGS)
pkg1/lfs-tgt-texinfo-$(TEXINFO_VER).cpio.zst: pkg1/lfs-tgt-Python-$(PYTHON_VER).cpio.zst
	rm -fr tmp/tgt-texinfo
	mkdir -p tmp/tgt-texinfo
	tar -xJf src/texinfo-$(TEXINFO_VER).tar.xz -C tmp/tgt-texinfo
	mkdir -p tmp/tgt-texinfo/bld
	cd tmp/tgt-texinfo/bld && ../texinfo-$(TEXINFO_VER)/configure $(TEXINFO_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-texinfo/ins/usr/share/info
	rm -fr tmp/tgt-texinfo/ins/usr/share/man
	rm -fr tmp/tgt-texinfo/ins/usr/lib/texinfo/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/tgt-texinfo/ins/usr/bin/install-info
	strip --strip-unneeded tmp/tgt-texinfo/ins/usr/lib/texinfo/*.so
endif
	cd tmp/tgt-texinfo/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-texinfo
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-texinfo: pkg1/lfs-tgt-texinfo-$(TEXINFO_VER).cpio.zst

# LFS-10.0-systemd :: CHROOT :: 7.13. Util-linux-2.36
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/util-linux.html
# BUILD_TIME :: 1m 22s
UTIL_LINUX_OPT1+= ADJTIME_PATH=/var/lib/hwclock/adjtime
UTIL_LINUX_OPT1+= --docdir=/usr/share/doc/util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_OPT1+= --disable-chfn-chsh
UTIL_LINUX_OPT1+= --disable-login
UTIL_LINUX_OPT1+= --disable-nologin
UTIL_LINUX_OPT1+= --disable-su
UTIL_LINUX_OPT1+= --disable-setpriv
UTIL_LINUX_OPT1+= --disable-runuser
UTIL_LINUX_OPT1+= --disable-pylibmount
UTIL_LINUX_OPT1+= --disable-static
UTIL_LINUX_OPT1+= --without-python
UTIL_LINUX_OPT1+= --disable-nls
UTIL_LINUX_OPT1+= --enable-usrdir-path
UTIL_LINUX_OPT1+= $(OPT_FLAGS)
pkg1/lfs-tgt-util-linux-$(UTIL_LINUX_VER).cpio.zst: pkg1/lfs-tgt-texinfo-$(TEXINFO_VER).cpio.zst
	mkdir -p /var/lib/hwclock
	rm -fr tmp/tgt-util-linux
	mkdir -p tmp/tgt-util-linux
	tar -xJf src/util-linux-$(UTIL_LINUX_VER).tar.xz -C tmp/tgt-util-linux
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/tgt-util-linux/util-linux-$(UTIL_LINUX_VER)/configure
	mkdir -p tmp/tgt-util-linux/bld
	cd tmp/tgt-util-linux/bld && ../util-linux-$(UTIL_LINUX_VER)/configure $(UTIL_LINUX_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-util-linux/ins/usr/share/doc
	rm -fr tmp/tgt-util-linux/ins/usr/share/man
	rm -fr tmp/tgt-util-linux/ins/usr/lib/*.la
	cd tmp/tgt-util-linux/ins/lib && ln -sfv libblkid.so.1.1.0 libblkid.so
	cd tmp/tgt-util-linux/ins/lib && ln -sfv libfdisk.so.1.1.0 libfdisk.so
	cd tmp/tgt-util-linux/ins/lib && ln -sfv libmount.so.1.1.0 libmount.so
	cd tmp/tgt-util-linux/ins/lib && ln -sfv libsmartcols.so.1.1.0 libsmartcols.so
	cd tmp/tgt-util-linux/ins/lib && ln -sfv libuuid.so.1.3.0 libuuid.so
	cp -far tmp/tgt-util-linux/ins/lib/* tmp/tgt-util-linux/ins/usr/lib/
	rm -fr tmp/tgt-util-linux/ins/lib
	cp -far tmp/tgt-util-linux/ins/bin/* tmp/tgt-util-linux/ins/usr/bin/
	rm -fr tmp/tgt-util-linux/ins/bin
	cp -far tmp/tgt-util-linux/ins/sbin/* tmp/tgt-util-linux/ins/usr/sbin/
	rm -fr tmp/tgt-util-linux/ins/sbin
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/bin/*
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/sbin/*
endif
	cd tmp/tgt-util-linux/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-util-linux
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
chroot-util-linux: pkg1/lfs-tgt-util-linux-$(UTIL_LINUX_VER).cpio.zst
# ===
# This Initial Chroot-Stage (LFS chapter 7) build time :: about 19 minutes
# ===

# =============================================================================
# === BASE SYSTEM
# =============================================================================

# LFS-10.0-systemd :: 8.3. Man-pages-5.08 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/man-pages.html
# SKIP THIS
# You can install it using "pkg/man-pages-5.08.tar.xz"

#==============================================================================

# LFS-10.0-systemd :: 8.4. Tcl-8.6.10 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/tcl.html
# BUILD_TIME :: 3m 3s
# BUILD_TIME_WITH_TEST :: 8m 1s
# NOTE: Skip unpack documentation. You can do it from "pkg/tcl8.6.10-html.tar.gz"
TCL_OPT2+= --prefix=/usr
TCL_OPT2+= --mandir=/usr/share/man
TCL_OPT2+= --enable-64bit
TCL_OPT2+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg2/tcl$(TCL_VER).cpio.zst: pkg1/lfs-tgt-util-linux-$(UTIL_LINUX_VER).cpio.zst
	mkdir -p pkg2
	rm -fr tmp/tcl
	mkdir -p tmp/tcl/bld
	tar -xzf src/tcl$(TCL_VER)-src.tar.gz -C tmp/tcl
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/unix/configure
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/unix/configure.in
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/unix/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/thread$(TCL_VER_THREAD_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/thread$(TCL_VER_THREAD_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/itcl$(TCL_VER_ITCL_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/itcl$(TCL_VER_ITCL_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/sqlite$(TCL_VER_SQLITE_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/sqlite$(TCL_VER_SQLITE_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc$(TCL_VER_TDBC_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc$(TCL_VER_TDBC_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcpostgres$(TCL_VER_TDBC_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcpostgres$(TCL_VER_TDBC_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcodbc$(TCL_VER_TDBC_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcodbc$(TCL_VER_TDBC_VER)/tclconfig/tcl.m4
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcmysql$(TCL_VER_TDBC_VER)/configure
#	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/pkgs/tdbcmysql$(TCL_VER_TDBC_VER)/tclconfig/tcl.m4
	cd tmp/tcl/bld && ../tcl$(TCL_VER)/unix/configure $(TCL_OPT2) && make $(JOBS) V=$(VERB)
	sed -i "s|`pwd`/tmp/tcl/bld|/usr/lib|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)|/usr/include|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/generic|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0/generic|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/tcl/bld && make test 2>&1 | tee ../../../tst/tcl-test.log || true
## TESTS ARE PASSED, except some with clock. See LFS-note in book "In the test results there are several places associated with clock.test that indicate a failure, but the summary at the end indicates no failures. clock.test passes on a complete LFS system.".
#endif
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install-private-headers
	rm -fr tmp/tcl/ins/usr/share/man
	cd tmp/tcl/ins/usr/bin && ln -sf tclsh$(TCL_VER_BRIEF) tclsh
	chmod -v u+w tmp/tcl/ins/usr/lib/libtcl$(TCL_VER_BRIEF).so
ifeq ($(BUILD_STRIP),y)
	find tmp/tcl/ins/usr/lib -type f -name "*.a" -exec strip --strip-debug {} +
	strip --strip-unneeded tmp/tcl/ins/usr/bin/tclsh$(TCL_VER_BRIEF)
	cd tmp/tcl/ins/usr/lib && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/tcl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/tcl
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-tcl: pkg2/tcl$(TCL_VER).cpio.zst

# LFS-10.0-systemd :: 8.5. Expect-5.45.4
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/expect.html
# BUILD_TIME :: 20s
# BUILD_TIME_WITH_TEST :: 36s
EXPECT_OPT2+= --prefix=/usr
EXPECT_OPT2+= --with-tcl=/usr/lib
EXPECT_OPT2+= --enable-shared
EXPECT_OPT2+= --mandir=/usr/share/man
EXPECT_OPT2+= --enable-64bit
EXPECT_OPT2+= --with-tclinclude=/usr/include
EXPECT_OPT2+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg2/expect$(EXPECT_VER).cpio.zst: pkg2/tcl$(TCL_VER).cpio.zst
	rm -fr tmp/expect
	mkdir -p tmp/expect/bld
	tar -xzf src/expect$(EXPECT_VER).tar.gz -C tmp/expect
## BEGIN: Workaround error with configure guess "unknown host"
## https://forums.fedoraforum.org/showthread.php?281575-configure-error-cannot-guess-build-type-you-must-specify-one
## download new "configure.guess" and "configure.sub" from "http://git.savannah.gnu.org/gitweb/?p=config.git&view=view+git+repository"
## see above our "make pkg" and replace old inside "tclconfig"-dir.
## NOTE: config.guess return the name of build-host, as is initial system start builds at first stages, i.e. "aarch64-unknown-linux-gnu" for Debian11 initial build-host
	cp -far src/config.guess tmp/expect/expect$(EXPECT_VER)/tclconfig/
	cp -far src/config.sub tmp/expect/expect$(EXPECT_VER)/tclconfig/
## END: workaround
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/expect/expect$(EXPECT_VER)/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/expect/expect$(EXPECT_VER)/testsuite/configure
	cd tmp/expect/bld && ../expect$(EXPECT_VER)/configure $(EXPECT_OPT2) && make $(JOBS) V=$(VERB)
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/expect/bld && make test 2>&1 | tee ../../../tst/expect-test.log || true
## TESTS ARE PASSED
#endif
	cd tmp/expect/bld && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/expect/ins/usr/share
	cd tmp/expect/ins/usr/lib && ln -svf expect$(EXPECT_VER)/libexpect$(EXPECT_VER).so libexpect$(EXPECT_VER).so
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/expect/ins/usr/lib/expect$(EXPECT_VER)/libexpect$(EXPECT_VER).so
	strip --strip-unneeded tmp/expect/ins/usr/bin/expect
endif
	cd tmp/expect/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/expect
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-expect: pkg2/expect$(EXPECT_VER).cpio.zst

# LFS-10.0-systemd :: 8.6. DejaGNU-1.6.2 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/dejagnu.html
# BUILD_TIME :: 6s
# BUILD_TIME_WITH_TEST :: 10s
#DEJAGNU_OPT2+= --prefix=/usr
#DEJAGNU_OPT2+= $(OPT_FLAGS)
#pkg2/dejagnu-$(DEJAGNU_VER).cpio.zst: pkg2/expect$(EXPECT_VER).cpio.zst
#	rm -fr tmp/dejagnu
#	mkdir -p tmp/dejagnu/bld
#	tar -xzf src/dejagnu-$(DEJAGNU_VER).tar.gz -C tmp/dejagnu
#	cd tmp/dejagnu/bld && ../dejagnu-$(DEJAGNU_VER)/configure $(DEJAGNU_OPT2)
#	cd tmp/dejagnu/bld && makeinfo --html --no-split -o doc/dejagnu.html ../dejagnu-$(DEJAGNU_VER)/doc/dejagnu.texi
#	cd tmp/dejagnu/bld && makeinfo --plaintext       -o doc/dejagnu.txt  ../dejagnu-$(DEJAGNU_VER)/doc/dejagnu.texi
#	cd tmp/dejagnu/bld && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/dejagnu/bld && make check 2>&1 | tee ../../../tst/dejagnu-check.log || true
## TESTS ARE PASSED
#endif
#	rm -fr tmp/dejagnu/ins/usr/share/info
#	rm -fr tmp/dejagnu/ins/usr/share/man
#	rm -fr tmp/dejagnu/ins/usr/share/dejagnu/baseboards/README
#	rm -fr tmp/dejagnu/ins/usr/share/dejagnu/config/README
#	cd tmp/dejagnu/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/dejagnu
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#tgt-dejagnu: pkg2/dejagnu-$(DEJAGNU_VER).cpio.zst

# LFS-10.0-systemd :: 8.7. Iana-Etc-20200821
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/iana-etc.html
# BUILD_TIME :: 1s
pkg2/iana-etc-$(IANA_ETC_VER).cpio.zst: pkg2/expect$(EXPECT_VER).cpio.zst
	rm -fr tmp/iana-etc
	mkdir -p tmp/iana-etc/ins/etc
	tar -xzf src/iana-etc-$(IANA_ETC_VER).tar.gz -C tmp/iana-etc
	cp -far tmp/iana-etc/iana-etc-$(IANA_ETC_VER)/protocols tmp/iana-etc/ins/etc/
	cp -far tmp/iana-etc/iana-etc-$(IANA_ETC_VER)/services tmp/iana-etc/ins/etc/
	cd tmp/iana-etc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/iana-etc
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-iana-etc: pkg2/iana-etc-$(IANA_ETC_VER).cpio.zst

# LFS-10.0-systemd :: 8.8. Glibc-2.32
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/glibc.html
# BUILD_TIME :: 5m 30s
# BUILD_TIME_WITH_TEST :: 68m 45s
GLIBC_OPT2+= 
GLIBC_OPT2+= --prefix=/usr
GLIBC_OPT2+= --disable-werror
GLIBC_OPT2+= --enable-kernel=3.2
GLIBC_OPT2+= --enable-stack-protector=strong
GLIBC_OPT2+= --with-headers=/usr/include
GLIBC_OPT2+= libc_cv_slibdir=/lib
GLIBC_OPT2+= $(OPT_FLAGS)
# Some useful info about tests: https://sourceware.org/glibc/wiki/Testing/Testsuite
pkg2/glibc-$(GLIBC_VER).cpio.zst: pkg2/iana-etc-$(IANA_ETC_VER).cpio.zst
	rm -fr tmp/glibc
	mkdir -p tmp/glibc/bld
	tar -xJf src/glibc-$(GLIBC_VER).tar.xz -C tmp/glibc
	cp -far src/glibc-$(GLIBC_VER)-fhs-1.patch tmp/glibc
	cd tmp/glibc/glibc-$(GLIBC_VER) && patch -Np1 -i ../glibc-$(GLIBC_VER)-fhs-1.patch
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/glibc/glibc-$(GLIBC_VER)/Makerules
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/glibc/glibc-$(GLIBC_VER)/Makeconfig
	sed -i '/test-installation/s@$$(PERL)@echo not running@' tmp/glibc/glibc-$(GLIBC_VER)/Makefile	
	cd tmp/glibc/bld && ../glibc-$(GLIBC_VER)/configure $(GLIBC_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/glibc/ins/usr/share/info
	cp -far tmp/glibc/ins/sbin/* tmp/glibc/ins/usr/sbin/
	rm -fr tmp/glibc/ins/sbin
	cp -far tmp/glibc/ins/lib/* tmp/glibc/ins/usr/lib/
	rm -fr tmp/glibc/ins/lib
	cd tmp/glibc/ins/usr/lib && ln -sf libanl.so.1 libanl.so
	cd tmp/glibc/ins/usr/lib && ln -sf libBrokenLocale.so.1 libBrokenLocale.so
	cd tmp/glibc/ins/usr/lib && ln -sf libcrypt.so.1 libcrypt.so
	cd tmp/glibc/ins/usr/lib && ln -sf libdl.so.2 libdl.so
	cd tmp/glibc/ins/usr/lib && ln -sf libm.so.6 libm.so
	cd tmp/glibc/ins/usr/lib && ln -sf libnss_compat.so.2 libnss_compat.so
	cd tmp/glibc/ins/usr/lib && ln -sf libnss_db.so.2 libnss_db.so
	cd tmp/glibc/ins/usr/lib && ln -sf libnss_dns.so.2 libnss_dns.so
	cd tmp/glibc/ins/usr/lib && ln -sf libnss_files.so.2 libnss_files.so
	cd tmp/glibc/ins/usr/lib && ln -sf libnss_hesiod.so.2 libnss_hesiod.so
	cd tmp/glibc/ins/usr/lib && ln -sf libpthread.so.0 libpthread.so
	cd tmp/glibc/ins/usr/lib && ln -sf libresolv.so.2 libresolv.so
	cd tmp/glibc/ins/usr/lib && ln -sf librt.so.1 librt.so
	cd tmp/glibc/ins/usr/lib && ln -sf libthread_db.so.1 libthread_db.so
	cd tmp/glibc/ins/usr/lib && ln -sf libutil.so.1 libutil.so
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/glibc/ins/usr/lib/*.a
	strip --strip-unneeded tmp/glibc/ins/usr/lib/*.so || true
# libc.so is not ELF
	strip --strip-unneeded tmp/glibc/ins/usr/bin/* || true
	strip --strip-unneeded tmp/glibc/ins/usr/sbin/* || true
	strip --strip-unneeded tmp/glibc/ins/usr/libexec/getconf/* || true
	strip --strip-unneeded tmp/glibc/ins/usr/lib/audit/* || true
	strip --strip-unneeded tmp/glibc/ins/usr/lib/gconv/* || true
endif
	cp -far tmp/glibc/glibc-$(GLIBC_VER)/nscd/nscd.conf tmp/glibc/ins/etc/
	mkdir -p tmp/glibc/ins/var/cache/nscd
	install -v -Dm644 tmp/glibc/glibc-$(GLIBC_VER)/nscd/nscd.tmpfiles tmp/glibc/ins/usr/lib/tmpfiles.d/nscd.conf
	install -v -Dm644 tmp/glibc/glibc-$(GLIBC_VER)/nscd/nscd.service tmp/glibc/ins/usr/lib/systemd/system/nscd.service
	mkdir -p tmp/glibc/ins/usr/lib/locale
	echo "# Begin /etc/nsswitch.conf" > tmp/glibc/ins/etc/nsswitch.conf
	echo "passwd: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "group: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "shadow: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "hosts: files dns" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "networks: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "protocols: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "services: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "ethers: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "rpc: files" >> tmp/glibc/ins/etc/nsswitch.conf
	echo "# End /etc/nsswitch.conf" >> tmp/glibc/ins/etc/nsswitch.conf
	mkdir -p tmp/glibc/ins/etc/ld.so.conf.d
	echo "# Begin /etc/ld.so.conf" > tmp/glibc/ins/etc/ld.so.conf
	echo "/usr/local/lib" >> tmp/glibc/ins/etc/ld.so.conf
	echo "/opt/lib" >> tmp/glibc/ins/etc/ld.so.conf
	echo "# Add an include directory" >> tmp/glibc/ins/etc/ld.so.conf
	echo "include /etc/ld.so.conf.d/*.conf" >> tmp/glibc/ins/etc/ld.so.conf
	cd tmp/glibc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/glibc
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/glibc/bld && make check 2>&1 | tee ../../../tst/glibc-check.log || true
##Summary of test results:
##      1 FAIL
##   4141 PASS
###     30 UNSUPPORTED
##     17 XFAIL
##      2 XPASS
## FAIL: io/tst-lchmod
## https://www.linuxfromscratch.org/~thomas/multilib/chapter08/glibc.html
## io/tst-lchmod is known to fail in the LFS chroot environment.
#endif
tgt-glibc: pkg2/glibc-$(GLIBC_VER).cpio.zst

# LFS-10.0-systemd :: 8.8.2.2. Adding time zone data 
# LFS-10.0-systemd :: set locales
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/glibc.html
# PROCESS TIME :: 4s
/etc/localtime: pkg2/glibc-$(GLIBC_VER).cpio.zst
	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
#	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	mkdir -p /usr/share/zoneinfo/posix
	mkdir -p /usr/share/zoneinfo/right
	mkdir -p tmp/tzdata
	tar -xzf src/tzdata$(TIME_ZONE_DATA_VER).tar.gz -C tmp/tzdata
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       etcetera
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix etcetera
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right etcetera
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       southamerica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix southamerica
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right southamerica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       northamerica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix northamerica
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right northamerica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       europe
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix europe
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right europe
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       africa
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix africa
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right africa
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       antarctica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix antarctica
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right antarctica
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       asia
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix asia
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right asia
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       australasia
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix australasia
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right australasia
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       backward
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix backward
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right backward
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       pacificnew
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix pacificnew
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right pacificnew
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo       systemv
	cd tmp/tzdata && zic -L /dev/null   -d /usr/share/zoneinfo/posix systemv
	cd tmp/tzdata && zic -L leapseconds -d /usr/share/zoneinfo/right systemv
	cd tmp/tzdata && cp -v zone.tab zone1970.tab iso3166.tab /usr/share/zoneinfo/
	cd tmp/tzdata && zic -d /usr/share/zoneinfo -p America/New_York
#	tzselect
	ln -sfv /usr/share/zoneinfo/Etc/GMT /etc/localtime
	rm -fr tmp/tzdata
tgt-local-time: /etc/localtime

# LFS-10.0-systemd :: 8.9. Zlib-1.2.11
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/zlib.html
# BUILD_TIME :: 4s
# BUILD_TIME_WITH_TEST :: 4s
ZLIB_OPT2+= --prefix=/usr
pkg2/zlib-$(ZLIB_VER).cpio.zst: /etc/localtime
	rm -fr tmp/zlib
	mkdir -p tmp/zlib/bld
	tar -xJf src/zlib-$(ZLIB_VER).tar.xz -C tmp/zlib
	sed -i "s/-O3/$(BASE_OPT_FLAGS)/" tmp/zlib/zlib-$(ZLIB_VER)/configure
	cd tmp/zlib/bld && ../zlib-$(ZLIB_VER)/configure $(ZLIB_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/zlib/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/zlib/ins/usr/lib/*.a
	strip --strip-unneeded tmp/zlib/ins/usr/lib/*.so
endif
	cd tmp/zlib/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/zlib/bld && make check 2>&1 | tee ../../../tst/zlib-check.log || true
## TEST PASSED!
#endif
	rm -fr tmp/zlib
tgt-zlib: pkg2/zlib-$(ZLIB_VER).cpio.zst

# LFS-10.0-systemd :: 8.10. Bzip2-1.0.8 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/bzip2.html
# BUILD_TIME :: 5s
pkg2/bzip2-$(BZIP2_VER).cpio.zst: pkg2/zlib-$(ZLIB_VER).cpio.zst
	rm -fr tmp/bzip2
	mkdir -p tmp/bzip2/ins/usr
	tar -xzf src/bzip2-$(BZIP2_VER).tar.gz -C tmp/bzip2
	cp -far src/bzip2-$(BZIP2_VER)-install_docs-1.patch tmp/bzip2/
	cd tmp/bzip2/bzip2-$(BZIP2_VER) && patch -Np1 -i ../bzip2-$(BZIP2_VER)-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i "s|-O2|$(BASE_OPT_FLAGS)|" tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile
	sed -i "s|-O2|$(BASE_OPT_FLAGS)|" tmp/bzip2/bzip2-$(BZIP2_VER)/Makefile-libbz2_so
	cd tmp/bzip2/bzip2-$(BZIP2_VER) && make $(JOBS) V=$(VERB) -f Makefile-libbz2_so && make clean && make $(JOBS) V=$(VERB) && make PREFIX=`pwd`/../ins/usr install
	rm -f tmp/bzip2/ins/usr/bin/bunzip2
	rm -f tmp/bzip2/ins/usr/bin/bzcat
	rm -f tmp/bzip2/ins/usr/bin/bzip2
	cp -fa tmp/bzip2/bzip2-$(BZIP2_VER)/bzip2-shared tmp/bzip2/ins/usr/bin/bzip2
	cd tmp/bzip2/ins/usr/bin && ln -sf bzip2 bunzip2 && ln -sf bzip2 bzcat
	cp -fa tmp/bzip2/bzip2-$(BZIP2_VER)/*.so* tmp/bzip2/ins/usr/lib/
	cd tmp/bzip2/ins/usr/lib && ln -sf libbz2.so.1.0 libbz2.so
	rm -fr tmp/bzip2/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug    tmp/bzip2/ins/usr/lib/*.a
	strip --strip-unneeded tmp/bzip2/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/bzip2/ins/usr/bin/* || true
endif
	rm -f tmp/bzip2/ins/usr/lib/*.a
# Disable static)))
	cd tmp/bzip2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/bzip2
tgt-bzip2: pkg2/bzip2-$(BZIP2_VER).cpio.zst

# LFS-10.0-systemd :: 8.11. Xz-5.2.5
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/xz.html
# BUILD_TIME :: 25s
# BUILD_TIME_WITH_TEST :: 44s
XZ_OPT2+= --prefix=/usr
XZ_OPT2+= --disable-static
XZ_OPT2+= --docdir=/usr/share/doc/xz-$(XZ_VER)
XZ_OPT2+= --disable-nls
ifeq ($(BASE_OPT_VALUE),-Os)
XZ_OPT2+= --enable-small
endif
XZ_OPT2+= --disable-doc
XZ_OPT2+= $(OPT_FLAGS)
pkg2/xz-$(XZ_VER).cpio.zst: pkg2/bzip2-$(BZIP2_VER).cpio.zst
	rm -fr tmp/xz
	mkdir -p tmp/xz/bld
	tar -xJf src/xz-$(XZ_VER).tar.xz -C tmp/xz
	cd tmp/xz/bld && ../xz-$(XZ_VER)/configure $(XZ_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/xz/ins/usr/share
	rm -f tmp/xz/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/xz/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/xz/ins/usr/bin/* || true
endif
	cd tmp/xz/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/xz/bld && make check 2>&1 | tee ../../../tst/xz-check.log || true
## TEST OK
#endif
	rm -fr tmp/xz
tgt-xz: pkg2/xz-$(XZ_VER).cpio.zst

# LFS-10.0-systemd :: 8.12. Zstd-1.4.5 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/zstd.html
# BUILD_TIME :: 1m 4s
# BUILD_TIME_WITH_TEST :: 29m 30s
pkg2/zstd-$(ZSTD_VER).cpio.zst: pkg2/xz-$(XZ_VER).cpio.zst
	rm -fr tmp/zstd
	mkdir -p tmp/zstd
	tar -xzf src/zstd-$(ZSTD_VER).tar.gz -C tmp/zstd
	find tmp/zstd/zstd-$(ZSTD_VER) -name "Makefile" -exec sed -i "s|-O3|$(BASE_OPT_VALUE)|" {} +
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/tests/fuzz/fuzz.py
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/contrib/linux-kernel/0002-lib-Add-zstd-modules.patch
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/zstd/zstd-$(ZSTD_VER)/Makefile
# runned 2nd time for core Makefile, because "-O3" double exists on lines
	cd tmp/zstd/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS)
	cd tmp/zstd/zstd-$(ZSTD_VER) && make $(JOBS) CC=gcc MOREFLAGS=$(RK3588_FLAGS) prefix=`pwd`/../ins/usr install
	rm -fr tmp/zstd/ins/usr/share
#	rm -f tmp/zstd/ins/usr/lib/*.a
# disable-static )))
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/zstd/ins/usr/bin/* || true
	strip --strip-debug tmp/zstd/ins/usr/lib/*.a
	strip --strip-unneeded tmp/zstd/ins/usr/lib/*.so*
endif
	cd tmp/zstd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/zstd/zstd-$(ZSTD_VER) && make CC=gcc MOREFLAGS=$(RK3588_FLAGS) test 2>&1 | tee ../../../tst/zstd-test.log || true
## TEST OK
#endif
	rm -fr tmp/zstd
tgt-zstd: pkg2/zstd-$(ZSTD_VER).cpio.zst

# === extra (BLFS-10) :: cpio
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/cpio.html
# BUILD_TIME :: 1m 19s
# BUILD_TIME_WITH_TEST :: 1m 22s
CPIO_OPT2+= --prefix=/usr
CPIO_OPT2+= --enable-mt
CPIO_OPT2+= --disable-nls
CPIO_OPT2+= --disable-static
CPIO_OPT2+= --with-rmt=/usr/libexec/rmt
CPIO_OPT2+= $(OPT_FLAGS)
pkg2/cpio-$(CPIO_VER).cpio.zst: pkg2/zstd-$(ZSTD_VER).cpio.zst
	rm -fr tmp/cpio
	mkdir -p tmp/cpio/bld
	tar -xjf src/cpio-$(CPIO_VER).tar.bz2 -C tmp/cpio
	sed -i '/The name/,+2 d' tmp/cpio/cpio-$(CPIO_VER)/src/global.c
	cd tmp/cpio/bld && ../cpio-$(CPIO_VER)/configure $(CPIO_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/cpio/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/cpio/ins/usr/bin/*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/cpio/bld && make check 2>&1 | tee ../../../tst/cpio-check.log || true
## TEST OK
#endif
	cd tmp/cpio/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/cpio
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-cpio: pkg2/cpio-$(CPIO_VER).cpio.zst

# === extra :: pv
# http://www.ivarch.com/programs/pv.shtml
# https://github.com/icetee/pv
# BUILD_TIME :: 13s
# BUILD_TIME_WITH_TEST :: 1m 52s
#PV_OPT2+= --prefix=/usr
#PV_OPT2+= --disable-nls
#PV_OPT2+= $(OPT_FLAGS)
#pkg2/pv-$(PV_VER).cpio.zst: pkg2/cpio-$(CPIO_VER).cpio.zst
#	rm -fr tmp/pv
#	mkdir -p tmp/pv/bld
#	tar -xjf src/pv_$(PV_VER).orig.tar.bz2 -C tmp/pv
#	cd tmp/pv/bld && ../pv-$(PV_VER)/configure $(PV_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/pv/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/pv/ins/usr/bin/pv
#endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/pv/bld && make check 2>&1 | tee ../../../tst/pv-check.log || true
## TEST OK
#endif
#	cd tmp/pv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	rm -fr tmp/pv
#	pv $@ | zstd -d | cpio -iduH newc --quiet -D /
#tgt-pv: pkg2/pv-$(PV_VER).cpio.zst

# LFS-10.0-systemd :: 8.13. File-5.39 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/file.html
# BUILD_TIME :: 22s
# BUILD_TIME_WITH_TEST :: 25s
FILE_OPT2+= --prefix=/usr
FILE_OPT2+= $(OPT_FLAGS)
pkg2/file-$(FILE_VER).cpio.zst: pkg2/cpio-$(CPIO_VER).cpio.zst
	rm -fr tmp/file
	mkdir -p tmp/file/bld
	tar -xzf src/file-$(FILE_VER).tar.gz -C tmp/file
	cd tmp/file/bld && ../file-$(FILE_VER)/configure $(FILE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/file/ins/usr/share/man
	rm -f tmp/file/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/file/ins/usr/bin/file
	strip --strip-unneeded tmp/file/ins/usr/lib/*.so*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/file/bld && make check 2>&1 | tee ../../../tst/file-check.log || true
## TEST OK
#endif
	cd tmp/file/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/file
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-file: pkg2/file-$(FILE_VER).cpio.zst

# LFS-10.0-systemd :: 8.14. Readline-8.0 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/readline.html
# BUILD_TIME :: 20s
READLINE_OPT2+= --prefix=/usr
READLINE_OPT2+= --disable-static
READLINE_OPT2+= --with-curses
READLINE_OPT2+= $(OPT_FLAGS)
pkg2/readline-$(READLINE_VER).cpio.zst: pkg2/file-$(FILE_VER).cpio.zst
	rm -fr tmp/readline
	mkdir -p tmp/readline/bld
	tar -xzf src/readline-$(READLINE_VER).tar.gz -C tmp/readline
	sed -i '/MV.*old/d' tmp/readline/readline-$(READLINE_VER)/Makefile.in
	sed -i '/{OLDSUFF}/c:' tmp/readline/readline-$(READLINE_VER)/support/shlib-install
	cd tmp/readline/bld && ../readline-$(READLINE_VER)/configure $(READLINE_OPT2) && make SHLIB_LIBS="-lncursesw" $(JOBS) V=$(VERB) && make SHLIB_LIBS="-lncursesw" DESTDIR=`pwd`/../ins install
	rm -fr tmp/readline/ins/usr/bin
	rm -fr tmp/readline/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/readline/ins/usr/lib/*.so*
endif
	cd tmp/readline/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/readline
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-readline: pkg2/readline-$(READLINE_VER).cpio.zst

# LFS-10.0-systemd :: 8.15. M4-1.4.18 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/m4.html
# BUILD_TIME :: 59s
# BUILD_TIME_WITH_TEST :: 1m 58s
M4_OPT2+= --prefix=/usr
M4_OPT2+= $(OPT_FLAGS)
pkg2/m4-$(M4_VER).cpio.zst: pkg2/readline-$(READLINE_VER).cpio.zst
	rm -fr tmp/m4
	mkdir -p tmp/m4/bld
	tar -xJf src/m4-$(M4_VER).tar.xz -C tmp/m4
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/m4/m4-$(M4_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/m4/m4-$(M4_VER)/lib/stdio-impl.h
	cd tmp/m4/bld && ../m4-$(M4_VER)/configure $(M4_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/m4/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/m4/ins/usr/bin/m4
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/m4/bld && make check 2>&1 | tee ../../../tst/m4-check.log || true
## TEST OK
#endif
	cd tmp/m4/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/m4
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-m4: pkg2/m4-$(M4_VER).cpio.zst

# LFS-10.0-systemd :: 8.16. Bc-3.1.5 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/bc.html
# BUILD_TIME :: 4s
# BUILD_TIME_WITH_TEST :: 9s
BC_OPT2+= --disable-man-pages
BC_OPT2+= --disable-nls
pkg2/bc-$(BC_VER).cpio.zst: pkg2/m4-$(M4_VER).cpio.zst
	rm -fr tmp/bc
	mkdir -p tmp/bc
	tar -xJf src/bc-$(BC_VER).tar.xz -C tmp/bc
	cd tmp/bc/bc-$(BC_VER) && PREFIX=/usr CC=gcc CFLAGS="-std=c99 $(RK3588_FLAGS)" ./configure.sh $(BC_OPT2) -G $(BASE_OPT_VALUE) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/bc/ins/usr/bin/bc
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/bc/bc-$(BC_VER) && make test 2>&1 | tee ../../../tst/bc-test.log || true
## TEST OK
#endif
	cd tmp/bc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/bc
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-bc: pkg2/bc-$(BC_VER).cpio.zst

# LFS-10.0-systemd :: 8.17. Flex-2.6.4
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/flex.html
# BUILD_TIME :: 25s
# BUILD_TIME_WITH_TEST :: 1m 48s
FLEX_OPT2+= --prefix=/usr
FLEX_OPT2+= --disable-nls 
FLEX_OPT2+= $(OPT_FLAGS)
pkg2/flex-$(FLEX_VER).cpio.zst: pkg2/bc-$(BC_VER).cpio.zst
	rm -fr tmp/flex
	mkdir -p tmp/flex/bld
	tar -xzf src/flex-$(FLEX_VER).tar.gz -C tmp/flex
	cd tmp/flex/bld && ../flex-$(FLEX_VER)/configure $(FLEX_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/flex/ins/usr/share
	rm -f tmp/flex/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/flex/ins/usr/bin/flex
	strip --strip-debug tmp/flex/ins/usr/lib/*.a
	strip --strip-unneeded tmp/flex/ins/usr/lib/*.so*
endif
	cd tmp/flex/ins/usr/bin && ln -sf flex lex
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/flex/bld && make check 2>&1 | tee ../../../tst/flex-check.log || true
## TEST OK
#endif
	cd tmp/flex/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/flex
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-flex: pkg2/flex-$(FLEX_VER).cpio.zst

# LFS-10.0-systemd :: 8.19. GMP-6.2.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gmp.html
# BUILD_TIME :: 1m 3s
# BUILD_TIME_WITH_TEST :: 4m 12s
GMP_OPT2+= --prefix=/usr
GMP_OPT2+= --enable-cxx
GMP_OPT2+= --disable-static
GMP_OPT2+= --docdir=/usr/share/doc/gmp-6.2.0
GMP_OPT2+= $(OPT_FLAGS)
pkg2/gmp-$(GMP_VER).cpio.zst: pkg2/flex-$(FLEX_VER).cpio.zst
	rm -fr tmp/gmp
	mkdir -p tmp/gmp/bld
	tar -xJf src/gmp-$(GMP_VER).tar.xz -C tmp/gmp
	cd tmp/gmp/bld && ../gmp-$(GMP_VER)/configure $(GMP_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gmp/ins/usr/share
	rm -f tmp/gmp/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gmp/ins/usr/lib/*.so*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gmp/bld && make check 2>&1 | tee ../../../tst/gmp-check.log || true
#	echo "Must be 197 successul tests. Here is:"
#	awk '/# PASS:/{total+=$$3} ; END{print total}' tst/gmp-check.log
## TEST OK
#endif
	cd tmp/gmp/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/gmp
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-gmp: pkg2/gmp-$(GMP_VER).cpio.zst

# === extra :: ISL build support
#
# BUILD_TIME :: 45s
# BUILD_TIME_WITH_TEST :: 1m 47s
ISL_OPT2+= --prefix=/usr
ISL_OPT2+= --disable-static
ISL_OPT2+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg2/isl-$(ISL_VER).cpio.zst: pkg2/gmp-$(GMP_VER).cpio.zst
	rm -fr tmp/isl
	mkdir -p tmp/isl/bld
	tar -xJf src/isl-$(ISL_VER).tar.xz -C tmp/isl
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/isl/isl-$(ISL_VER)/configure
	cd tmp/isl/bld && ../isl-$(ISL_VER)/configure $(ISL_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/isl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/isl/ins/usr/lib/*.so* || true
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/isl/bld && make check 2>&1 | tee ../../../tst/isl-check.log || true
## TEST OK
#endif
	cd tmp/isl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/isl
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-isl: pkg2/isl-$(ISL_VER).cpio.zst

# LFS-10.0-systemd :: 8.20. MPFR-4.1.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/mpfr.html
# BUILD_TIME :: 31s
# BUILD_TIME_WITH_TEST :: 3m 17s
MPFR_OPT2+= --prefix=/usr
MPFR_OPT2+= --disable-static
MPFR_OPT2+= --enable-thread-safe
MPFR_OPT2+= --docdir=/usr/share/doc/mpfr-4.1.0
MPFR_OPT2+= $(OPT_FLAGS)
pkg2/mpfr-$(MPFR_VER).cpio.zst: pkg2/isl-$(ISL_VER).cpio.zst
	rm -fr tmp/mpfr
	mkdir -p tmp/mpfr/bld
	tar -xJf src/mpfr-$(MPFR_VER).tar.xz -C tmp/mpfr
	cd tmp/mpfr/bld && ../mpfr-$(MPFR_VER)/configure $(MPFR_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mpfr/ins/usr/share
	rm -f tmp/mpfr/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/mpfr/ins/usr/lib/*.so*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/mpfr/bld && make check 2>&1 | tee ../../../tst/mpfr-check.log || true
## TEST OK
#endif
	cd tmp/mpfr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mpfr
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-mpfr: pkg2/mpfr-$(MPFR_VER).cpio.zst

# LFS-10.0-systemd :: 8.21. MPC-1.1.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/mpc.html
# BUILD_TIME :: 14s
# BUILD_TIME_WITH_TEST :: 1m 15s
MPC_OPT2+= --prefix=/usr
MPC_OPT2+= --disable-static
MPC_OPT2+= --docdir=/usr/share/doc/mpc-1.1.0
MPC_OPT2+= $(OPT_FLAGS)
pkg2/mpc-$(MPC_VER).cpio.zst: pkg2/mpfr-$(MPFR_VER).cpio.zst
	rm -fr tmp/mpc
	mkdir -p tmp/mpc/bld
	tar -xzf src/mpc-$(MPC_VER).tar.gz -C tmp/mpc
	cd tmp/mpc/bld && ../mpc-$(MPC_VER)/configure $(MPC_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/mpc/ins/usr/share
	rm -fr tmp/mpc/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/mpc/ins/usr/lib/*.so*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/mpc/bld && make check 2>&1 | tee ../../../tst/mpc-check.log || true
## TEST OK
#endif
	cd tmp/mpc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/mpc
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-mpc: pkg2/mpc-$(MPC_VER).cpio.zst

# LFS-10.0-systemd :: 8.18. Binutils-2.35 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/binutils.html
# BUILD_TIME :: 2m 11s
# BUILD_TIME_WITH_TEST :: 10m (without gold)
BINUTILS_OPT2+= --prefix=/usr
#BINUTILS_OPT2+= --enable-gold
BINUTILS_OPT2+= --enable-ld=default
BINUTILS_OPT2+= --enable-plugins
BINUTILS_OPT2+= --enable-shared
BINUTILS_OPT2+= --disable-werror
BINUTILS_OPT2+= --enable-64-bit-bfd
BINUTILS_OPT2+= --with-system-zlib
BINUTILS_OPT2+= $(OPT_FLAGS)
BINUTILS_OPT2+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg2/binutils-$(BINUTILS_VER).cpio.zst: pkg2/mpc-$(MPC_VER).cpio.zst
	rm -fr tmp/binutils
	mkdir -p tmp/binutils/bld
	tar -xJf src/binutils-$(BINUTILS_VER).tar.xz -C tmp/binutils
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/binutils/binutils-$(BINUTILS_VER)/ld/Makefile.in
	expect -c "spawn ls"
#OK	
	sed -i '/@\tincremental_copy/d' tmp/binutils/binutils-$(BINUTILS_VER)/gold/testsuite/Makefile.in
	cd tmp/binutils/bld && ../binutils-$(BINUTILS_VER)/configure $(BINUTILS_OPT2) && make tooldir=/usr $(JOBS) V=$(VERB) && make tooldir=/usr DESTDIR=`pwd`/../ins install
	rm -fr tmp/binutils/ins/usr/share
	rm -f tmp/binutils/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/binutils/ins/usr/bin/* || true
	strip --strip-debug tmp/binutils/ins/usr/lib/*.a
	strip --strip-unneeded tmp/binutils/ins/usr/lib/*.so*
endif
	cd tmp/binutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/binutils/bld && make -k check 2>&1 | tee ../../../tst/binutils-check.log || true
# TEST not passed !
# FAILS - (A) "--enable-gold".
# gcctestdir/collect-ld: error: tls_test.o: unsupported TLSLE reloc 549 in shared code
# <etc>
# gcctestdir/collect-ld: error: tls_test.o: unsupported reloc 549 in non-static TLSLE mode.
# tls_test.o:tls_test.cc:function t1(): error: unexpected opcode while processing relocation R_AARCH64_TLSLE_ADD_TPREL_HI12
# <etc>
# https://www.mail-archive.com/bug-binutils@gnu.org/msg30791.html
# This problem is repaired or not?
# OK. We'll disable gold. But some problems are still exists.
# FAILS - (B) "dwarf","libbar","libfoo".
# Running /opt/mysdk/tmp/binutils/binutils-2.35/ld/testsuite/ld-elf/dwarf.exp ...
# FAIL: DWARF parse during linker error
# Running /opt/mysdk/tmp/binutils/binutils-2.35/ld/testsuite/ld-elf/shared.exp ...
# FAIL: Build warn libbar.so
# FAIL: Run warn with versioned libfoo.so
# What's the your opinion? Lets go to front and run future, with ignore theese fails? Possibly we can see any problems in a future?
#endif
	rm -fr tmp/binutils
tgt-binutils: pkg2/binutils-$(BINUTILS_VER).cpio.zst

# LFS-10.0-systemd :: 8.22. Attr-2.4.48
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/attr.html
# BUILD_TIME :: 10s
# BUILD_TIME_WITH_TEST :: 14s
ATTR_OPT2+= --prefix=/usr
ATTR_OPT2+= --disable-static
ATTR_OPT2+= --sysconfdir=/etc
ATTR_OPT2+= --disable-nls
ATTR_OPT2+= $(OPT_FLAGS)
pkg2/attr-$(ATTR_VER).cpio.zst: pkg2/binutils-$(BINUTILS_VER).cpio.zst
	rm -fr tmp/attr
	mkdir -p tmp/attr/bld
	tar -xzf src/attr-$(ATTR_VER).tar.gz -C tmp/attr
	cd tmp/attr/bld && ../attr-$(ATTR_VER)/configure $(ATTR_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/attr/ins/usr/share
	rm -f tmp/attr/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/attr/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/attr/ins/usr/bin/* || true
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/attr/bld && make check 2>&1 | tee ../../../tst/attr-check.log || true
## TEST OK
#endif
	cd tmp/attr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/attr
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-attr: pkg2/attr-$(ATTR_VER).cpio.zst

# LFS-10.0-systemd :: 8.23. Acl-2.2.53
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/acl.html
# BUILD_TIME :: 12s
# BUILD_TIME_WITH_TEST ::
ACL_OPT2+= --prefix=/usr
ACL_OPT2+= --disable-static
ACL_OPT2+= --libexecdir=/usr/lib
ACL_OPT2+= --disable-nls
ACL_OPT2+= $(OPT_FLAGS)
pkg2/acl-$(ACL_VER).cpio.zst: pkg2/attr-$(ATTR_VER).cpio.zst
	rm -fr tmp/acl
	mkdir -p tmp/acl/bld
	tar -xzf src/acl-$(ACL_VER).tar.gz -C tmp/acl
	cd tmp/acl/bld && ../acl-$(ACL_VER)/configure $(ACL_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/acl/ins/usr/share
	rm -f tmp/acl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/acl/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/acl/ins/usr/bin/* || true
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/acl/bld && make check 2>&1 | tee ../../../tst/acl-check.log || true
# ACL can be tested only with coreutils built with acl support
#endif
	cd tmp/acl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/acl
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-acl: pkg2/acl-$(ACL_VER).cpio.zst

# LFS-10.0-systemd :: 8.24. Libcap-2.42
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/libcap.html
# BUILD_TIME :: 3s
# BUILD_TIME_WITH_TEST :: 4s
pkg2/libcap-$(LIBCAP_VER).cpio.zst: pkg2/acl-$(ACL_VER).cpio.zst
	rm -fr tmp/libcap
	mkdir -p tmp/libcap/ins/lib
	tar -xJf src/libcap-$(LIBCAP_VER).tar.xz -C tmp/libcap
	sed -i '/install -m.*STACAPLIBNAME/d' tmp/libcap/libcap-$(LIBCAP_VER)/libcap/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/libcap/libcap-$(LIBCAP_VER)/Make.Rules
	cd tmp/libcap/libcap-$(LIBCAP_VER) && make $(JOBS) V=$(VERB) CC=gcc lib=lib && make CC=gcc lib=lib DESTDIR=`pwd`/../ins PKGCONFIGDIR=/usr/lib/pkgconfig install
	mv -f tmp/libcap/ins/lib/* tmp/libcap/ins/usr/lib/
	rm -fr tmp/libcap/ins/lib
	rm -fr tmp/libcap/ins/usr/share
	chmod 755 tmp/libcap/ins/usr/lib/libcap.so.$(LIBCAP_VER)
	mv -f tmp/libcap/ins/sbin tmp/libcap/ins/usr/
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/libcap/ins/usr/lib/*.a
	strip --strip-unneeded tmp/libcap/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/libcap/ins/usr/sbin/*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/libcap/libcap-$(LIBCAP_VER) && make CC=gcc test 2>&1 | tee ../../../tst/libcap-test.log || true
## TEST OK
#endif
	cd tmp/libcap/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/libcap
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
tgt-libcap: pkg2/libcap-$(LIBCAP_VER).cpio.zst

# LFS-10.0-systemd :: 8.25. Shadow-4.8.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/shadow.html
# BUILD_TIME :: 40s
SHADOW_OPT2+= --sysconfdir=/etc
SHADOW_OPT2+= --with-group-name-max-length=32
SHADOW_OPT2+= --disable-nls
SHADOW_OPT2+= $(OPT_FLAGS)
pkg2/shadow-$(SHADOW_VER).cpio.zst: pkg2/libcap-$(LIBCAP_VER).cpio.zst
	rm -fr tmp/shadow
	mkdir -p tmp/shadow/bld
	tar -xJf src/shadow-$(SHADOW_VER).tar.xz -C tmp/shadow
	sed -i 's|groups$$(EXEEXT) ||' tmp/shadow/shadow-$(SHADOW_VER)/src/Makefile.in
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	cd tmp/shadow/shadow-$(SHADOW_VER) && find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	sed -i 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's:/var/spool/mail:/var/mail:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' tmp/shadow/shadow-$(SHADOW_VER)/etc/login.defs
	sed -i 's/1000/999/' tmp/shadow/shadow-$(SHADOW_VER)/etc/useradd
	touch /usr/bin/passwd
	cd tmp/shadow/bld && ../shadow-$(SHADOW_VER)/configure $(SHADOW_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/shadow/ins/usr/share
	mv -f tmp/shadow/ins/bin/* tmp/shadow/ins/usr/bin/
	rm -fr tmp/shadow/ins/bin
	mv -f  tmp/shadow/ins/sbin/* tmp/shadow/ins/usr/sbin/
	rm -fr tmp/shadow/ins/sbin
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/shadow/ins/usr/bin/* || true
	strip --strip-unneeded tmp/shadow/ins/usr/sbin/* || true
endif
	cd tmp/shadow/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/shadow
	pwconv
	grpconv
	passwd -d root
tgt-shadow: pkg2/shadow-$(SHADOW_VER).cpio.zst

# LFS-10.0-systemd :: 8.26. GCC-10.2.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gcc.html
# BUILD_TIME :: 14m 25s
# BUILD_TIME_WITH_TEST :: 938m (15h 38m)
GCC_OPT2+= --prefix=/usr
GCC_OPT2+= LD=ld
#GCC_OPT2+= CC_FOR_TARGET=gcc
GCC_OPT2+= --enable-languages=c,c++
GCC_OPT2+= --disable-multilib
GCC_OPT2+= --disable-bootstrap
GCC_OPT2+= --with-system-zlib
GCC_OPT2+= --disable-nls
GCC_OPT2+= $(OPT_FLAGS)
GCC_OPT2+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC_OPT2+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg2/gcc-$(GCC_VER).cpio.zst: pkg2/shadow-$(SHADOW_VER).cpio.zst
	rm -fr tmp/gcc
	mkdir -p tmp/gcc/bld
	tar -xJf src/gcc-$(GCC_VER).tar.xz -C tmp/gcc
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libgcc/Makefile.in
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/Makefile.in
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libgomp/configure
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libitm/configure
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libatomic/configure
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/include/Makefile.in
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/gcc/gcc-$(GCC_VER)/libstdc++-v3/include/Makefile.am
# https://mysqlonarm.github.io/ARM-LSE-and-MySQL/
# Resolve '-march=armv8-a+lse' build error:
# tmp/gcc/gcc-$(GCC_VER)/libatomic/Changelog
# tmp/gcc/gcc-$(GCC_VER)/gcc/doc/invoke.texi
# tmp/gcc/gcc-$(GCC_VER)/gcc/doc/gcc.info
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-cas.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-ldadd.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-ldlogic.c
# tmp/gcc/gcc-$(GCC_VER)/gcc/testsuite/gcc.target/aarch64/atomic-inst-swp.c
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/config/aarch64/lse.S
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/configure.ac
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libgcc/configure
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/Makefile.am
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/Makefile.in
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/configure.ac
	sed -i 's|armv8-a+lse|$(RK3588_ARCH)|' tmp/gcc/gcc-$(GCC_VER)/libatomic/configure
	cd tmp/gcc/bld && ../gcc-$(GCC_VER)/configure $(GCC_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gcc/ins/usr/share/info
	rm -fr tmp/gcc/ins/usr/share/man
	mv -f tmp/gcc/ins/usr/lib64/* tmp/gcc/ins/usr/lib/
	rm -fr tmp/gcc/ins/usr/lib64
	cd tmp/gcc/ins/usr/lib && ln -sf ../bin/cpp cpp
	cd tmp/gcc/ins/usr/bin && ln -sf gcc cc
	find tmp/gcc/ins/usr/ -name \*.la -delete
ifeq ($(BUILD_STRIP),y)
	find tmp/gcc/ins/usr -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/gcc/ins/usr && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
# rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/
# !!! 'gcc -dumpmachine' at this return 'aarch64-lfs-linux-gnu'.
# We need to rebuild all LFS later using LFS_TGT=aarch64-unknown-linux-gnu, then all system will be native and we will remove this parts later.
	install -v -dm755 tmp/gcc/ins/usr/lib/bfd-plugins
	cp -f src/config.guess tmp/
	chmod ugo+x tmp/config.guess
	cd tmp/gcc/ins/usr/lib/bfd-plugins && ln -sf ../../libexec/gcc/`../../../../../config.guess`/$(GCC_VER)/liblto_plugin.so liblto_plugin.so
	rm -f tmp/config.guess
	mkdir -p tmp/gcc/ins/usr/share/gdb/auto-load/usr/lib
	mv -f tmp/gcc/ins/usr/lib/*gdb.py tmp/gcc/ins/usr/share/gdb/auto-load/usr/lib/
	cd tmp/gcc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
# !!! 'gcc -dumpmachine' at this return return 'aarch64-unknown-linux-gnu'.
#	rm -fr tmp/gcc/ins/usr/lib/gcc/$$(gcc -dumpmachine)/10.2.0/include-fixed/bits
#	rm -f tmp/gcc/ins/usr/lib/gcc/$$(gcc -dumpmachine)/10.2.0/include-fixed/README
#	rm -f tmp/gcc/ins/usr/lib/gcc/$$(gcc -dumpmachine)/10.2.0/install-tools/include/README
#	cd tmp/gcc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gcc/bld && ulimit -s 32768 && make -k check 2>&1 | tee ../../../tst/gcc-check.log || true
#endif
	rm -fr tmp/gcc
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.c-torture/execute/execute.exp ...
#FAIL: gcc.c-torture/execute/alias-2.c   -O1  execution test
#FAIL: gcc.c-torture/execute/alias-2.c   -O2  execution test
#FAIL: gcc.c-torture/execute/alias-2.c   -O3 -g  execution test
#FAIL: gcc.c-torture/execute/alias-2.c   -Os  execution test
#FAIL: gcc.c-torture/execute/alias-2.c   -O2 -flto -fno-use-linker-plugin -flto-partition=none  execution test
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.dg/asan/asan.exp ...
#FAIL: gcc.dg/asan/pr80166.c   -O0  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -O1  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -O2  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -O3 -g  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -Os  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -O2 -flto -fno-use-linker-plugin -flto-partition=none  (test for excess errors)
#FAIL: gcc.dg/asan/pr80166.c   -O2 -flto -fuse-linker-plugin -fno-fat-lto-objects  (test for excess errors)
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.dg/gomp/gomp.exp ...
#FAIL: gcc.dg/gomp/pr89104.c (test for excess errors)
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.dg/tsan/tsan.exp ...
#FAIL: c-c++-common/tsan/thread_leak1.c   -O0  output pattern test
#FAIL: c-c++-common/tsan/thread_leak1.c   -O2  output pattern test
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.dg/vect/vect.exp ...
#FAIL: gcc.dg/vect/slp-46.c scan-tree-dump-times vect "vectorizing stmts using SLP" 2
#FAIL: gcc.dg/vect/slp-46.c -flto -ffat-lto-objects  scan-tree-dump-times vect "vectorizing stmts using SLP" 2
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.target/aarch64/aarch64.exp ...
#FAIL: gcc.target/aarch64/insv_1.c scan-assembler bfi\tx[0-9]+, x[0-9]+, 0, 8
#FAIL: gcc.target/aarch64/insv_1.c scan-assembler bfi\tx[0-9]+, x[0-9]+, 16, 5
#FAIL: gcc.target/aarch64/insv_1.c scan-assembler movk\tx[0-9]+, 0x1d6b, lsl 32
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/gcc.target/aarch64/advsimd-intrinsics/advsimd-intrinsics.exp ...
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -O0  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -O1  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -O2  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -O3 -g  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -Os  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -Og -g  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/bfdot-2.c   -O2 -flto -fno-use-linker-plugin -flto-partition=none  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -O0  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -O1  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -O2  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -O3 -g  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -Os  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -Og -g  (test for excess errors)
#FAIL: gcc.target/aarch64/advsimd-intrinsics/vdot-3-2.c   -O2 -flto -fno-use-linker-plugin -flto-partition=none  (test for excess errors)
#...
#		=== gcc Summary ===
#
## of expected passes		249700
## of unexpected failures	34
## of expected failures		1908
## of unresolved testcases	120
## of unsupported tests		2749
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/g++.dg/asan/asan.exp ...
#FAIL: g++.dg/asan/asan_test.C   -O2  (test for excess errors)
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/g++.dg/coroutines/coroutines.exp ...
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C execution test
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/g++.dg/coroutines/torture/coro-torture.exp ...
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O0  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O1  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O2  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O3 -g  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -Os  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O2 -flto -fno-use-linker-plugin -flto-partition=none  execution test
#FAIL: g++.dg/coroutines/torture/co-ret-17-void-ret-coro.C   -O2 -flto -fuse-linker-plugin -fno-fat-lto-objects  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O0  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O1  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O2  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O3 -g  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -Os  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O2 -flto -fno-use-linker-plugin -flto-partition=none  execution test
#FAIL: g++.dg/coroutines/torture/pr95519-05-gro.C   -O2 -flto -fuse-linker-plugin -fno-fat-lto-objects  execution test
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/gcc/testsuite/g++.dg/tsan/tsan.exp ...
#FAIL: c-c++-common/tsan/thread_leak1.c   -O0  output pattern test
#FAIL: c-c++-common/tsan/thread_leak1.c   -O2  output pattern test
#...
#		=== g++ Summary ===
#
## of expected passes		300228
## of unexpected failures	19
## of expected failures		1904
## of unresolved testcases	1
## of unsupported tests		8570
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/libstdc++-v3/testsuite/libstdc++-abi/abi.exp ...
#FAIL: libstdc++-abi/abi_check
#...
#Running /opt/mysdk/tmp/gcc/gcc-10.2.0/libstdc++-v3/testsuite/libstdc++-dg/conformance.exp ...
#FAIL: 20_util/allocator/1.cc execution test
#FAIL: 27_io/filesystem/iterators/91067.cc (test for excess errors)
#FAIL: 27_io/filesystem/iterators/directory_iterator.cc (test for excess errors)
#FAIL: 27_io/filesystem/iterators/recursive_directory_iterator.cc execution test
#FAIL: 27_io/filesystem/operations/exists.cc execution test
#FAIL: 27_io/filesystem/operations/is_empty.cc execution test
#FAIL: 27_io/filesystem/operations/remove.cc execution test
#FAIL: 27_io/filesystem/operations/remove_all.cc execution test
#FAIL: 27_io/filesystem/operations/status.cc execution test
#FAIL: 27_io/filesystem/operations/symlink_status.cc execution test
#FAIL: 27_io/filesystem/operations/temp_directory_path.cc execution test
#FAIL: experimental/filesystem/iterators/directory_iterator.cc execution test
#FAIL: experimental/filesystem/iterators/recursive_directory_iterator.cc execution test
#FAIL: experimental/filesystem/operations/exists.cc execution test
#FAIL: experimental/filesystem/operations/is_empty.cc execution test
#FAIL: experimental/filesystem/operations/remove.cc execution test
#FAIL: experimental/filesystem/operations/remove_all.cc execution test
#FAIL: experimental/filesystem/operations/temp_directory_path.cc execution test
#...
#		=== libstdc++ Summary ===
#
## of expected passes		13342
## of unexpected failures	19
## of expected failures		93
## of unresolved testcases	1
## of unsupported tests		688
#...
#		=== libgomp Summary ===
#
## of expected passes		2666
## of expected failures		4
## of unsupported tests		312
#...
#		=== libitm Summary ===
#
## of expected passes		42
## of expected failures		3
## of unsupported tests		1
#...
# ---------------------------------------
# SYSTEM NOW SWITCHED TO NATIVE 'aarch64-unknown-linux-gnu' !
# Compile tests:
### echo 'int main(){}' > dummy.c
### cc dummy.c -v -Wl,--verbose &> dummy.log
### readelf -l a.out | grep ': /lib'
#       [Requesting program interpreter: /lib/ld-linux-aarch64.so.1]
### grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
# /usr/lib/gcc/aarch64-unknown-linux-gnu/10.2.0/../../../../lib64/crt1.o succeeded
# /usr/lib/gcc/aarch64-unknown-linux-gnu/10.2.0/../../../../lib64/crti.o succeeded
# /usr/lib/gcc/aarch64-unknown-linux-gnu/10.2.0/../../../../lib64/crtn.o succeeded
### grep -B4 '^ /usr/include' dummy.log
# #include <...> search starts here:
# /usr/lib/gcc/aarch64-unknown-linux-gnu/10.2.0/include
# /usr/local/include
# /usr/lib/gcc/aarch64-unknown-linux-gnu/10.2.0/include-fixed
# /usr/include
### grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
# SEARCH_DIR("/usr/aarch64-unknown-linux-gnu/lib64")
# SEARCH_DIR("/usr/local/lib64")
# SEARCH_DIR("/lib64")
# SEARCH_DIR("/usr/lib64")
# SEARCH_DIR("/usr/aarch64-unknown-linux-gnu/lib")
# SEARCH_DIR("/usr/local/lib")
# SEARCH_DIR("/lib")
# SEARCH_DIR("/usr/lib");
### grep "/lib.*/libc.so.6 " dummy.log
# attempt to open /lib/libc.so.6 succeeded
### grep found dummy.log
# found ld-linux-aarch64.so.1 at /lib/ld-linux-aarch64.so.1
### rm -v dummy.c a.out dummy.log
# removed 'dummy.c'
# removed 'a.out'
# removed 'dummy.log'
tgt-gcc: pkg2/gcc-$(GCC_VER).cpio.zst

# =============================================================================
# here is the point of NATIVE BUILD (aarch64-unknown-linux-gnu)
# =============================================================================

# LFS-10.0-systemd :: 8.27. Pkg-config-0.29.2
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/pkg-config.html
# BUILD_TIME :: 1m 4s
# BUILD_TIME_WITH_TEST :: 1m 8s
PKGCONFIG_OPT2+= --prefix=/usr
PKGCONFIG_OPT2+= --with-internal-glib
PKGCONFIG_OPT2+= --disable-host-tool
PKGCONFIG_OPT2+= $(OPT_FLAGS)
pkg2/pkg-config-$(PKG_CONFIG_VER).cpio.zst: pkg2/gcc-$(GCC_VER).cpio.zst
	rm -fr tmp/pkg-config
	mkdir -p tmp/pkg-config/bld
	tar -xzf src/pkg-config-$(PKG_CONFIG_VER).tar.gz -C tmp/pkg-config
	cd tmp/pkg-config/bld && ../pkg-config-$(PKG_CONFIG_VER)/configure $(PKGCONFIG_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/pkg-config/ins/usr/share/doc
	rm -fr tmp/pkg-config/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/pkg-config/ins/usr/bin/pkg-config
endif
	cd tmp/pkg-config/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/pkg-config/bld && make check 2>&1 | tee ../../../tst/pkg-config-check.log || true
##All 30 tests passed
#endif
	rm -fr tmp/pkg-config
tgt-pkg-config: pkg2/pkg-config-$(PKG_CONFIG_VER).cpio.zst

# LFS-10.0-systemd :: 8.28. Ncurses-6.2
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/ncurses.html
# BUILD_TIME :: 1m 0s
# Tests are interactive. They work ok.
NCURSES_OPT2+= --prefix=/usr
NCURSES_OPT2+= --mandir=/usr/share/man
NCURSES_OPT2+= --with-shared
NCURSES_OPT2+= --without-debug
NCURSES_OPT2+= --without-normal
NCURSES_OPT2+= --enable-pc-files
NCURSES_OPT2+= --enable-widec
NCURSES_OPT2+= $(OPT_FLAGS)
pkg2/ncurses-$(NCURSES_VER).cpio.zst: pkg2/pkg-config-$(PKG_CONFIG_VER).cpio.zst
	rm -fr tmp/ncurses
	mkdir -p tmp/ncurses/bld
	tar -xzf src/ncurses-$(NCURSES_VER).tar.gz -C tmp/ncurses
	sed -i '/LIBTOOL_INSTALL/d' tmp/ncurses/ncurses-$(NCURSES_VER)/c++/Makefile.in
	cd tmp/ncurses/bld && ../ncurses-$(NCURSES_VER)/configure $(NCURSES_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	mv -f tmp/ncurses/ins/lib/pkgconfig tmp/ncurses/ins/usr/lib/
	rm -fr tmp/ncurses/ins/lib
	rm -fr tmp/ncurses/ins/usr/share/man
	rm -vf tmp/ncurses/ins/usr/lib/libncurses.so
	echo "INPUT(-lncursesw)" > tmp/ncurses/ins/usr/lib/libncurses.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf ncursesw.pc ncurses.pc
	rm -vf tmp/ncurses/ins/usr/lib/libform.so
	echo "INPUT(-lformw)" > tmp/ncurses/ins/usr/lib/libform.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf formw.pc form.pc
	rm -vf tmp/ncurses/ins/usr/lib/libpanel.so
	echo "INPUT(-lpanelw)" > tmp/ncurses/ins/usr/lib/libpanel.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf panelw.pc panel.pc
	rm -vf tmp/ncurses/ins/usr/lib/libmenu.so
	echo "INPUT(-lmenuw)" > tmp/ncurses/ins/usr/lib/libmenu.so
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf menuw.pc menu.pc
	cd tmp/ncurses/ins/usr/lib/pkgconfig && ln -sf ncurses++w.pc ncurses++.pc
	rm -vf tmp/ncurses/ins/usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > tmp/ncurses/ins/usr/lib/libcursesw.so
	cd tmp/ncurses/ins/usr/lib && ln -sf libncurses.so libcurses.so
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/ncurses/ins/usr/bin/* || true
	strip --strip-unneeded tmp/ncurses/ins/usr/lib/*.so* || true
	strip --strip-debug tmp/ncurses/ins/usr/lib/*.a
endif
	cd tmp/ncurses/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/ncurses
tgt-ncurses: pkg2/ncurses-$(NCURSES_VER).cpio.zst

# LFS-10.0-systemd :: 8.29. Sed-4.8
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/sed.html
# BUILD_TIME :: 1m 2s
# BUILD_TIME_WITH_TEST :: 2m 12s
SED_OPT2+= --prefix=/usr
SED_OPT2+= --disable-nls
SED_OPT2+= --disable-i18n
SED_OPT2+= $(OPT_FLAGS)
pkg2/sed-$(SED_VER).cpio.zst: pkg2/ncurses-$(NCURSES_VER).cpio.zst
	rm -fr tmp/sed
	mkdir -p tmp/sed/bld
	tar -xJf src/sed-$(SED_VER).tar.xz -C tmp/sed
	cd tmp/sed/bld && ../sed-$(SED_VER)/configure $(SED_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/sed/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/sed/ins/usr/bin/sed
endif	
	cd tmp/sed/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	chown -Rv tester tmp/sed/bld
#	mkdir -p tst && cd tmp/sed/bld && su tester -c "PATH=$$PATH make check"
#============================================================================
#Testsuite summary for GNU sed 4.8
#============================================================================
## TOTAL: 178
## PASS:  149
## SKIP:  29
## XFAIL: 0
## FAIL:  0
## XPASS: 0
## ERROR: 0
#============================================================================
#endif
	rm -fr tmp/sed
tgt-sed: pkg2/sed-$(SED_VER).cpio.zst

# LFS-10.0-systemd :: 8.30. Psmisc-23.3
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/psmisc.html
# BUILD_TIME :: 16s
PSMISC_OPT2+= --prefix=/usr
PSMISC_OPT2+= --disable-nls
PSMISC_OPT2+= $(OPT_FLAGS)
pkg2/psmisc-$(PSMISC_VER).cpio.zst: pkg2/sed-$(SED_VER).cpio.zst
	rm -fr tmp/psmisc
	mkdir -p tmp/psmisc/bld
	tar -xJf src/psmisc-$(PSMISC_VER).tar.xz -C tmp/psmisc
	sed -i "s|-O2|$(BASE_OPT_VALUE)|" tmp/psmisc/psmisc-$(PSMISC_VER)/configure
	cd tmp/psmisc/bld && ../psmisc-$(PSMISC_VER)/configure $(PSMISC_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/psmisc/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/psmisc/ins/usr/bin/* || true
endif
	cd tmp/psmisc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/psmisc
tgt-psmisc: pkg2/psmisc-$(PSMISC_VER).cpio.zst

# LFS-10.0-systemd :: 8.31. Gettext-0.21
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gettext.html
# BUILD_TIME :: 7m 15s
# BUILD_TIME_WITH_TEST :: 13m 30s
GETTEXT_OPT2+= --prefix=/usr
GETTEXT_OPT2+= --disable-static
GETTEXT_OPT2+= --docdir=/usr/share/doc/gettext-$(GETTEXT_VER)
GETTEXT_OPT2+= --disable-nls
GETTEXT_OPT2+= $(OPT_FLAGS)
pkg2/gettext-$(GETTEXT_VER).cpio.zst: pkg2/psmisc-$(PSMISC_VER).cpio.zst
	rm -fr tmp/gettext
	mkdir -p tmp/gettext/bld
	tar -xJf src/gettext-$(GETTEXT_VER).tar.xz -C tmp/gettext
	cd tmp/gettext/bld && ../gettext-$(GETTEXT_VER)/configure $(GETTEXT_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gettext/ins/usr/share/doc
	rm -fr tmp/gettext/ins/usr/share/info
	rm -fr tmp/gettext/ins/usr/share/man
	rm -fr tmp/gettext/ins/usr/share/gettext/projects
	rm -f  tmp/gettext/ins/usr/share/gettext/ABOUT-NLS
	rm -fr tmp/gettext/ins/usr/lib/*.la
	chmod -v 0755 tmp/gettext/ins/usr/lib/preloadable_libintl.so
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gettext/ins/usr/bin/* || true
	strip --strip-unneeded tmp/gettext/ins/usr/lib/gettext/* || true
	strip --strip-unneeded tmp/gettext/ins/usr/lib/*.so*
endif
	cd tmp/gettext/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gettext/bld && make check 2>&1 | tee ../../../tst/gettext-check.log || true
#============================================================================
#Testsuite summary for gettext-tools 0.21
#============================================================================
## TOTAL: 266
## PASS:  236
## SKIP:  30
## XFAIL: 0
## FAIL:  0
## XPASS: 0
## ERROR: 0
#============================================================================
#endif
	rm -fr tmp/gettext
tgt-gettext: pkg2/gettext-$(GETTEXT_VER).cpio.zst

# LFS-10.0-systemd :: 8.32. Bison-3.7.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/bison.html
# BUILD_TIME :: 1m 12s
# BUILD_TIME_WITH_TEST :: 21m 28s
BISON_OPT2+= --prefix=/usr
BISON_OPT2+= --disable-nls
BISON_OPT2+= $(OPT_FLAGS)
pkg2/bison-$(BISON_VER).cpio.zst: pkg2/gettext-$(GETTEXT_VER).cpio.zst
	rm -fr tmp/bison
	mkdir -p tmp/bison/bld
	tar -xJf src/bison-$(BISON_VER).tar.xz -C tmp/bison
	cd tmp/bison/bld && ../bison-$(BISON_VER)/configure $(BISON_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/bison/ins/usr/share/doc
	rm -fr tmp/bison/ins/usr/share/info
	rm -fr tmp/bison/ins/usr/share/man
	rm -f  tmp/bison/ins/usr/share/bison/README.md
	rm -f  tmp/bison/ins/usr/share/bison/skeletons/README-D.txt
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/bison/ins/usr/lib/liby.a
	strip --strip-unneeded tmp/bison/ins/usr/bin/* || true
endif
	cd tmp/bison/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/bison/bld && make check 2>&1 | tee ../../../tst/bison-check.log || true
## 617 tests were successful.
## 43 tests were skipped.
#endif
	rm -fr tmp/bison
tgt-bison: pkg2/bison-$(BISON_VER).cpio.zst

# LFS-10.0-systemd :: 8.33. Grep-3.4
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/grep.html
# BUILD_TIME :: 1m 5s
# BUILD_TIME_WITH_TEST :: 2m 46s
GREP_OPT2+= --prefix=/usr
GREP_OPT2+= --disable-nls
GREP_OPT2+= $(OPT_FLAGS)
pkg2/grep-$(GREP_VER).cpio.zst: pkg2/bison-$(BISON_VER).cpio.zst
	rm -fr tmp/grep
	mkdir -p tmp/grep/bld
	tar -xJf src/grep-$(GREP_VER).tar.xz -C tmp/grep
	cd tmp/grep/bld && ../grep-$(GREP_VER)/configure $(GREP_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/grep/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/grep/ins/usr/bin/grep
endif
	cd tmp/grep/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/grep/bld && make check 2>&1 | tee ../../../tst/grep-check.log || true
#============================================================================
## TOTAL: 185
## PASS:  163
## SKIP:  22
## XFAIL: 0
## FAIL:  0
## XPASS: 0
## ERROR: 0
#============================================================================
#endif
	rm -fr tmp/grep
tgt-grep: pkg2/grep-$(GREP_VER).cpio.zst

# LFS-10.0-systemd :: 8.34. Bash-5.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/bash.html
# BUILD_TIME :: 1m 14s
# BUILD_TIME_WITH_TEST :: 4m 20s
BASH_OPT2+= --prefix=/usr
BASH_OPT2+= --without-bash-malloc
BASH_OPT2+= --with-installed-readline
BASH_OPT2+= --disable-nls
BASH_OPT2+= $(OPT_FLAGS)
pkg2/bash-$(BASH_VER).cpio.zst: pkg2/grep-$(GREP_VER).cpio.zst
	rm -fr tmp/bash
	mkdir -p tmp/bash/bld
	tar -xzf src/bash-$(BASH_VER).tar.gz -C tmp/bash
	cp src/bash-$(BASH_VER)-upstream_fixes-1.patch tmp/bash/
	cd tmp/bash/bash-$(BASH_VER) && patch -Np1 -i ../bash-$(BASH_VER)-upstream_fixes-1.patch
	cd tmp/bash/bld && ../bash-$(BASH_VER)/configure $(BASH_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/bash/ins/usr/share
	cd tmp/bash/ins/usr/bin && ln -sf bash sh
ifeq ($(BUILD_STRIP),y)
	cd tmp/bash/ins/usr && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/bash/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	chown -Rv tester tmp/bash/bld
#	mkdir -p tst && cd tmp/bash/bld && su tester -c "PATH=$$PATH make tests < $$(tty)"
#endif
	rm -fr tmp/bash
#	exec /bin/bash --login +h
tgt-bash: pkg2/bash-$(BASH_VER).cpio.zst
###############################################################################
# THIS POINT IS: 127m 48s (2h 8m)
###############################################################################

# === RE-ENTER TO CHROOT with new bash

# LFS-10.0-systemd :: 8.35. Libtool-2.4.6
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/libtool.html
# BUILD_TIME :: 20s
# BUILD_TIME_WITH_TEST :: 5m 45s
LIBTOOL_OPT2+= --prefix=/usr
LIBTOOL_OPT2+= $(OPT_FLAGS)
pkg2/libtool-$(LIBTOOL_VER).cpio.zst: pkg2/bash-$(BASH_VER).cpio.zst
	rm -fr tmp/libtool
	mkdir -p tmp/libtool/bld
	tar -xJf src/libtool-$(LIBTOOL_VER).tar.xz -C tmp/libtool
	cd tmp/libtool/bld && ../libtool-$(LIBTOOL_VER)/configure $(LIBTOOL_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libtool/ins/usr/share/info
	rm -fr tmp/libtool/ins/usr/share/man
	rm -f  tmp/libtool/ins/usr/share/libtool/README
	rm -f  tmp/libtool/ins/usr/share/libtool/COPYING.LIB
	rm -f  tmp/libtool/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/libtool/ins/usr/lib/*.a
	strip --strip-unneeded tmp/libtool/ins/usr/lib/*.so*
endif
	cd tmp/libtool/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/libtool/bld && make TESTSUITEFLAGS=$(JOBS) check 2>&1 | tee ../../../tst/libtool-check.log || true
#126: linking libltdl without autotools               FAILED (standalone.at:85)
#125: installable libltdl                             FAILED (standalone.at:67)
#124: compiling copied libltdl                        FAILED (standalone.at:50)
#123: compiling softlinked libltdl                    FAILED (standalone.at:35)
#130: linking libltdl without autotools               FAILED (subproject.at:115)
#ERROR: 139 tests were run,
#65 failed (60 expected failures).
#31 tests were skipped.
# LFS-Note: "Five tests are known to fail in the LFS build environment due to a circular dependency, but all tests pass if rechecked after automake is installed."
#endif
	rm -fr tmp/libtool
tgt-libtool: pkg2/libtool-$(LIBTOOL_VER).cpio.zst

# LFS-10.0-systemd :: 8.36. GDBM-1.18.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gdbm.html
# BUILD_TIME :: 17s
# BUILD_TIME_WITH_TEST ::
GDBM_OPT2+= --prefix=/usr
GDBM_OPT2+= --disable-static
GDBM_OPT2+= --enable-libgdbm-compat
GDBM_OPT2+= --disable-nls
GDBM_OPT2+= $(OPT_FLAGS)
pkg2/gdbm-$(GDBM_VER).cpio.zst: pkg2/libtool-$(LIBTOOL_VER).cpio.zst
	rm -fr tmp/gdbm
	mkdir -p tmp/gdbm/bld
	tar -xzf src/gdbm-$(GDBM_VER).tar.gz -C tmp/gdbm
	sed -r -i '/^char.*parseopt_program_(doc|args)/d' tmp/gdbm/gdbm-$(GDBM_VER)/src/parseopt.c
	cd tmp/gdbm/bld && ../gdbm-$(GDBM_VER)/configure $(GDBM_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gdbm/ins/usr/share
	rm -fr tmp/gdbm/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gdbm/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/gdbm/ins/usr/bin/*
endif
	cd tmp/gdbm/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gdbm/bld && make check 2>&1 | tee ../../../tst/gdbm-check.log || true
# All 30 tests were successful.
#endif
	rm -fr tmp/gdbm
tgt-gdbm: pkg2/gdbm-$(GDBM_VER).cpio.zst

# LFS-10.0-systemd :: 8.37. Gperf-3.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gperf.html
# BUILD_TIME :: 9s
# BUILD_TIME_WITH_TEST :: 12s
GPERF_OPT2+= --prefix=/usr
GPERF_OPT2+= --docdir=/usr/share/doc/gperf-$(GPERF_VER)
GPERF_OPT2+= $(OPT_FLAGS)
pkg2/gperf-$(GPERF_VER).cpio.zst: pkg2/gdbm-$(GDBM_VER).cpio.zst
	rm -fr tmp/gperf
	mkdir -p tmp/gperf/bld
	tar -xzf src/gperf-$(GPERF_VER).tar.gz -C tmp/gperf
	cd tmp/gperf/bld && ../gperf-$(GPERF_VER)/configure $(GPERF_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gperf/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gperf/ins/usr/bin/gperf
endif
	cd tmp/gperf/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gperf/bld && make -j1 check 2>&1 | tee ../../../tst/gperf-check.log || true
## TEST OK
#endif
	rm -fr tmp/gperf
tgt-gperf: pkg2/gperf-$(GPERF_VER).cpio.zst

# LFS-10.0-systemd :: 8.38. Expat-2.2.9
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/expat.html
# BUILD_TIME :: 20s
# BUILD_TIME_WITH_TEST :: 31
EXPAT_OPT2+= --prefix=/usr
EXPAT_OPT2+= --disable-static
EXPAT_OPT2+= --docdir=/usr/share/doc/expat-$(EXPAT_VER)
EXPAT_OPT2+= $(OPT_FLAGS)
pkg2/expat-$(EXPAT_VER).cpio.zst: pkg2/gperf-$(GPERF_VER).cpio.zst
	rm -fr tmp/expat
	mkdir -p tmp/expat/bld
	tar -xJf src/expat-$(EXPAT_VER).tar.xz -C tmp/expat
	cd tmp/expat/bld && ../expat-$(EXPAT_VER)/configure $(EXPAT_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/expat/ins/usr/share
	rm -f tmp/expat/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/expat/ins/usr/bin/xmlwf
	strip --strip-unneeded tmp/expat/ins/usr/lib/*.so*
endif
	cd tmp/expat/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/expat/bld && make check 2>&1 | tee ../../../tst/expat-check.log || true
# ============================================================================
# Testsuite summary for expat 2.5.0
# ============================================================================
# # TOTAL: 2
# # PASS:  2
# # SKIP:  0
# # XFAIL: 0
# # FAIL:  0
# # XPASS: 0
# # ERROR: 0
# ============================================================================
#endif
	rm -fr tmp/expat
tgt-expat: pkg2/expat-$(EXPAT_VER).cpio.zst

# LFS-10.0-systemd :: 8.39. Inetutils-1.9.4
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/inetutils.html
# BUILD_TIME :: 2m 3s
# BUILD_TIME_WITH_TEST ::
INETUTILS_OPT2+= --prefix=/usr
INETUTILS_OPT2+= --localstatedir=/var
INETUTILS_OPT2+= --disable-logger
INETUTILS_OPT2+= --disable-whois
INETUTILS_OPT2+= --disable-rcp
INETUTILS_OPT2+= --disable-rexec
INETUTILS_OPT2+= --disable-rlogin
INETUTILS_OPT2+= --disable-rsh
INETUTILS_OPT2+= --disable-servers
INETUTILS_OPT2+= $(OPT_FLAGS)
pkg2/inetutils-$(INET_UTILS_VER).cpio.zst: pkg2/expat-$(EXPAT_VER).cpio.zst
	rm -fr tmp/inetutils
	mkdir -p tmp/inetutils/bld
	tar -xJf src/inetutils-$(INET_UTILS_VER).tar.xz -C tmp/inetutils
	cd tmp/inetutils/bld && ../inetutils-$(INET_UTILS_VER)/configure $(INETUTILS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/inetutils/ins/usr/share
	rm -fr tmp/inetutils/ins/usr/libexec
# libexec is empty
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/inetutils/ins/usr/bin/* || true
endif
	cd tmp/inetutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/inetutils/bld && make check 2>&1 | tee ../../../tst/inetutils-check.log || true
# ============================================================================
# Testsuite summary for GNU inetutils 1.9.4
# ============================================================================
# # TOTAL: 10
# # PASS:  10
# # SKIP:  0
# # XFAIL: 0
# # FAIL:  0
# # XPASS: 0
# # ERROR: 0
# ============================================================================
#endif
	rm -fr tmp/inetutils
tgt-inetutils: pkg2/inetutils-$(INET_UTILS_VER).cpio.zst

# LFS-10.0-systemd :: 8.40. Perl-5.32.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/perl.html
# BUILD_TIME :: 4m 12s
# BUILD_TIME_WITH_TEST :: 24m 37s
PERL_POPT2+= -des
PERL_POPT2+= -Dprefix=/usr
PERL_POPT2+= -Dvendorprefix=/usr
PERL_POPT2+= -Dprivlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT2+= -Darchlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT2+= -Dsitelib=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT2+= -Dsitearch=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT2+= -Dvendorlib=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT2+= -Dvendorarch=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT2+= -Dman1dir=/usr/share/man/man1
PERL_POPT2+= -Dman3dir=/usr/share/man/man3
PERL_POPT2+= -Dpager="/usr/bin/less -isR"
PERL_POPT2+= -Duseshrplib
PERL_POPT2+= -Dusethreads
PERL_POPT2+= -Doptimize="$(BASE_OPT_FLAGS)"	
pkg2/perl-$(PERL_VER).cpio.zst: pkg2/inetutils-$(INET_UTILS_VER).cpio.zst
	rm -fr tmp/perl
	mkdir -p tmp/perl
	tar -xJf src/perl-$(PERL_VER).tar.xz -C tmp/perl
	sh -c 'export BUILD_ZLIB=False && export BUILD_BZIP2=0 && cd tmp/perl/perl-$(PERL_VER) && sh Configure $(PERL_POPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/perl/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/perl/ins/usr && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/perl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	export BUILD_ZLIB=False && export BUILD_BZIP2=0 && cd tmp/perl/perl-$(PERL_VER) && make test -j1
# ^^^ It cant runs under make invocation(( I has't any ideas about it. Both types of invocation from make-file via sh -c 'make test' or directly "make test" both are not working.
# PERL TEST, NOW, WAS INVOKED FROM COMMAND LINE DIRECTLY FROM CHROOT!!!
# bash # cd /opt/mysdk
# bash # cd tmp/perl/perl-<TAB>
# bash # make test -j1
#Failed 9 tests out of 2554, 99.65% okay.
#	../cpan/Compress-Raw-Zlib/t/01version.t
#	../cpan/Compress-Raw-Zlib/t/02zlib.t
#	../cpan/Compress-Raw-Zlib/t/18lvalue.t
#	../cpan/Compress-Raw-Zlib/t/19nonpv.t
#	../cpan/IO-Compress/t/cz-01version.t
#	../cpan/IO-Compress/t/cz-03zlib-v1.t
#	../cpan/IO-Compress/t/cz-06gzsetp.t
#	../cpan/IO-Compress/t/cz-08encoding.t
#	../cpan/IO-Compress/t/cz-14gzopen.t
### Since not all tests were successful, you may want to run some of
### them individually and examine any diagnostic messages they produce.
### See the INSTALL document's section on "make test".
### You have a good chance to get more information by running
###   ./perl harness
### in the 't' directory since most (>=80%) of the tests succeeded.
### You may have to set your dynamic library search path,
### LD_LIBRARY_PATH, to point to the build directory:
###   setenv LD_LIBRARY_PATH `pwd`:$LD_LIBRARY_PATH; cd t; ./perl harness
###   LD_LIBRARY_PATH=`pwd`:$LD_LIBRARY_PATH; export LD_LIBRARY_PATH; cd t; ./perl harness
###   export LD_LIBRARY_PATH=`pwd`:$LD_LIBRARY_PATH; cd t; ./perl harness
### for csh-style shells, like tcsh; or for traditional/modern
### Bourne-style shells, like bash, ksh, and zsh, respectively.
#Elapsed: 1452 sec
#u=17.85  s=9.40  cu=948.21  cs=169.97  scripts=2554  tests=1220476
#make: *** [makefile:799: test] Error 1
#endif
	rm -fr tmp/perl
tgt-perl: pkg2/perl-$(PERL_VER).cpio.zst

# LFS-10.0-systemd :: 8.41. XML::Parser-2.46
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/xml-parser.html
# BUILD_TIME :: 5s
# BUILD_TIME_WITH_TEST :: 7s
pkg2/XML-Parser-$(XML_PARSER_VER).cpio.zst: pkg2/perl-$(PERL_VER).cpio.zst
	rm -fr tmp/XML-Parser
	mkdir -p tmp/XML-Parser
	tar -xzf src/XML-Parser-$(XML_PARSER_VER).tar.gz -C tmp/XML-Parser
	cd tmp/XML-Parser/XML-Parser-$(XML_PARSER_VER) && perl Makefile.PL && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/XML-Parser/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	cd tmp/XML-Parser/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif	
	cd tmp/XML-Parser/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/XML-Parser/XML-Parser-$(XML_PARSER_VER) && make test 2>&1 | tee ../../../tst/XML-Parser-test.log || true
#All tests successful.
#Files=15, Tests=140,  1 wallclock secs ( 0.11 usr  0.05 sys +  1.08 cusr  0.23 csys =  1.47 CPU)
#Result: PASS
#endif
	rm -fr tmp/XML-Parser
tgt-xml-parser: pkg2/XML-Parser-$(XML_PARSER_VER).cpio.zst

# LFS-10.0-systemd :: 8.42. Intltool-0.51.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/intltool.html
# BUILD_TIME :: 3s
# BUILD_TIME_WITH_TEST :: 7s
#INTLTOOL_OPT2+= --prefix=/usr
#pkg2/intltool-$(INTL_TOOL_VER).cpio.zst: pkg2/XML-Parser-$(XML_PARSER_VER).cpio.zst
#	rm -fr tmp/intltool
#	mkdir -p tmp/intltool/bld
#	tar -xzf src/intltool-$(INTL_TOOL_VER).tar.gz -C tmp/intltool
#	sed -i 's:\\\$${:\\\$$\\{:' tmp/intltool/intltool-$(INTL_TOOL_VER)/intltool-update.in
#	cd tmp/intltool/bld && ../intltool-$(INTL_TOOL_VER)/configure $(INTLTOOL_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/intltool/ins/usr/share/man
#	cd tmp/intltool/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/intltool/bld && make check 2>&1 | tee ../../../tst/intltool-check.log || true
#============================================================================
#Testsuite summary for intltool 0.51.0
#============================================================================
# TOTAL: 1
# PASS:  1
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
#	rm -fr tmp/intltool
#tgt-intltool: pkg2/intltool-$(INTL_TOOL_VER).cpio.zst

# LFS-10.0-systemd :: 8.43. Autoconf-2.69
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/autoconf.html
# BUILD_TIME :: 6s
# BUILD_TIME_WITH_TEST :: 22m 51s
AUTOCONF_OPT2+= --prefix=/usr
#AUTOCONF_OPT2+= $(OPT_FLAGS)
pkg2/autoconf-$(AUTOCONF_VER).cpio.zst: pkg2/XML-Parser-$(XML_PARSER_VER).cpio.zst
	rm -fr tmp/autoconf
	mkdir -p tmp/autoconf/bld
	tar -xJf src/autoconf-$(AUTOCONF_VER).tar.xz -C tmp/autoconf
	sed -i '361 s/{/\\{/' tmp/autoconf/autoconf-$(AUTOCONF_VER)/bin/autoscan.in
	cd tmp/autoconf/bld && ../autoconf-$(AUTOCONF_VER)/configure $(AUTOCONF_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/autoconf/ins/usr/share/info
	rm -fr tmp/autoconf/ins/usr/share/man
	rm -f  tmp/autoconf/ins/usr/share/autoconf/INSTALL
	cd tmp/autoconf/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/autoconf/bld && make check 2>&1 | tee ../../../tst/autoconf-check.log || true
# LFS: "The test suite is currently broken by bash-5 and libtool-2.4.3."
# ERROR: 450 tests were run,
# 137 failed (4 expected failures).
# 53 tests were skipped.
#endif
	rm -fr tmp/autoconf
tgt-autoconf: pkg2/autoconf-$(AUTOCONF_VER).cpio.zst

# LFS-10.0-systemd :: 8.44. Automake-1.16.2
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/automake.html
# BUILD_TIME :: 20s
# BUILD_TIME_WITH_TEST :: 16m 15s
AUTOMAKE_OPT2+= --prefix=/usr
#AUTOMAKE_OPT2+= $(OPT_FLAGS)
pkg2/automake-$(AUTOMAKE_VER).cpio.zst: pkg2/autoconf-$(AUTOCONF_VER).cpio.zst
	rm -fr tmp/automake
	mkdir -p tmp/automake/bld
	tar -xJf src/automake-$(AUTOMAKE_VER).tar.xz -C tmp/automake
	sed -i "s/''/etags/" tmp/automake/automake-$(AUTOMAKE_VER)/t/tags-lisp-space.sh
	cd tmp/automake/bld && ../automake-$(AUTOMAKE_VER)/configure $(AUTOMAKE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/automake/ins/usr/share/doc
	rm -fr tmp/automake/ins/usr/share/info
	rm -fr tmp/automake/ins/usr/share/man
	rm -fr tmp/automake/ins/usr/share/aclocal
# aclocal is empty
	rm -f  tmp/automake/ins/usr/share/automake-$(AUTOMAKE_VER0)/COPYING
	rm -f  tmp/automake/ins/usr/share/automake-$(AUTOMAKE_VER0)/INSTALL
	cd tmp/automake/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/automake/bld && make $(JOBS) check 2>&1 | tee ../../../tst/automake-check.log || true
# ============================================================================
# Testsuite summary for GNU Automake 1.16.2
# ============================================================================
# TOTAL: 2915
# PASS:  2719
# SKIP:  157
# XFAIL: 39
# FAIL:  0
# XPASS: 0
# ERROR: 0
# ============================================================================
#endif
	rm -fr tmp/automake
tgt-automake: pkg2/automake-$(AUTOMAKE_VER).cpio.zst

# LFS-10.0-systemd :: 8.45. Kmod-27
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/kmod.html
# BUILD_TIME :: 24s
KMOD_OPT2+= --prefix=/usr
#KMOD_OPT2+= --bindir=/bin
KMOD_OPT2+= --sysconfdir=/etc
KMOD_OPT2+= --with-rootlibdir=/usr/lib
KMOD_OPT2+= --with-xz
KMOD_OPT2+= --with-zlib
KMOD_OPT2+= $(OPT_FLAGS)
pkg2/kmod-$(KMOD_VER).cpio.zst: pkg2/automake-$(AUTOMAKE_VER).cpio.zst
	rm -fr tmp/kmod
	mkdir -p tmp/kmod/bld
	tar -xJf src/kmod-$(KMOD_VER).tar.xz -C tmp/kmod
	cd tmp/kmod/bld && ../kmod-$(KMOD_VER)/configure $(KMOD_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/kmod/ins/usr/share/man
	rm -f  tmp/kmod/ins/usr/lib/*.la
	mkdir -p tmp/kmod/ins/usr/sbin
	cd tmp/kmod/ins/usr/sbin && ln -sf ../bin/kmod depmod && ln -sf ../bin/kmod insmod && ln -sf ../bin/kmod lsmod && ln -sf ../bin/kmod modinfo && ln -sf ../bin/kmod modprobe && ln -sf ../bin/kmod rmmod
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/kmod/ins/usr/bin/kmod
	strip --strip-unneeded tmp/kmod/ins/usr/lib/*.so*
endif
	cd tmp/kmod/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/kmod
tgt-kmod: pkg2/kmod-$(KMOD_VER).cpio.zst

# LFS-10.0-systemd :: 8.46. Libelf from Elfutils-0.180
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/libelf.html
# BUILD_TIME :: 56s
# BUILD_TIME_WITH_TEST :: 2m 18s
# https://sourceware.org/elfutils/
LIBELF_OPT2+= --prefix=/usr
LIBELF_OPT2+= --disable-debuginfod
LIBELF_OPT2+= --libdir=/usr/lib
LIBELF_OPT2+= --disable-nls
LIBELF_OPT2+= $(OPT_FLAGS)
pkg2/elfutils-$(ELF_UTILS_VER).full.cpio.zst pkg2/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst: pkg2/kmod-$(KMOD_VER).cpio.zst
	rm -fr tmp/elfutils
	mkdir -p tmp/elfutils/bld
	tar -xjf src/elfutils-$(ELF_UTILS_VER).tar.bz2 -C tmp/elfutils
	cd tmp/elfutils/bld && ../elfutils-$(ELF_UTILS_VER)/configure $(LIBELF_OPT2) && make $(JOBS) V=$(VERB)
	cd tmp/elfutils/bld && make DESTDIR=`pwd`/../ins-full install
	cd tmp/elfutils/bld && make -C libelf DESTDIR=`pwd`/../ins-libelf install
	rm -fr tmp/elfutils/ins-full/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-debug tmp/elfutils/ins-libelf/usr/lib/*.a
	strip --strip-unneeded tmp/elfutils/ins-libelf/usr/lib/*.so*
	strip --strip-unneeded tmp/elfutils/ins-full/usr/bin/* || true
	strip --strip-debug tmp/elfutils/ins-full/usr/lib/*.a
	strip --strip-unneeded tmp/elfutils/ins-full/usr/lib/*.so*
endif
	rm -f tmp/elfutils/ins-full/usr/lib/*.a
	rm -f tmp/elfutils/ins-libelf/usr/lib/*.a
	mkdir -p tmp/elfutils/ins-libelf/usr/lib/pkgconfig
	install -vm644 tmp/elfutils/bld/config/libelf.pc tmp/elfutils/ins-libelf/usr/lib/pkgconfig
	cd tmp/elfutils/ins-full && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../pkg2/elfutils-$(ELF_UTILS_VER).full.cpio.zst
	cd tmp/elfutils/ins-libelf && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../pkg2/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst
#	cat pkg2/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst | zstd -d | cpio -iduH newc --quiet -D /
	cat pkg2/elfutils-$(ELF_UTILS_VER).full.cpio.zst | zstd -d | cpio -iduH newc --quiet -D /
# ^^ here is your choose. 'FULL of elfutils' or 'ONLY libelf'
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/elfutils/bld && make check 2>&1 | tee ../../../tst/elfutils-check.log || true
#FAIL: run-strip-reloc.sh
#FAIL: run-strip-strmerge.sh
#FAIL: run-readelf-self.sh
#FAIL: run-varlocs-self.sh
#FAIL: run-exprlocs-self.sh
#FAIL: run-dwarf-die-addr-die.sh
#FAIL: run-get-units-invalid.sh
#FAIL: run-get-units-split.sh
#FAIL: run-unit-info.sh
#============================================================================
#Testsuite summary for elfutils 0.180
#============================================================================
# TOTAL: 218
# PASS:  204
# SKIP:  5
# XFAIL: 0
# FAIL:  9
# XPASS: 0
# ERROR: 0
#endif
	rm -fr tmp/elfutils
tgt-elfutils: pkg2/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst

# LFS-10.0-systemd :: 8.47. Libffi-3.3
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/libffi.html
# BUILD_TIME :: 17s
# BUILD_TIME_WITH_TEST :: 5m 53s
LIBFFI_OPT2+= --prefix=/usr
LIBFFI_OPT2+= --disable-static
LIBFFI_OPT2+= --with-gcc-arch=native
LIBFFI_OPT2+= $(OPT_FLAGS)
pkg2/libffi-$(LIBFFI_VER).cpio.zst: pkg2/elfutils-$(ELF_UTILS_VER).libelf.cpio.zst
	rm -fr tmp/libffi
	mkdir -p tmp/libffi/bld
	tar -xzf src/libffi-$(LIBFFI_VER).tar.gz -C tmp/libffi
	cd tmp/libffi/bld && ../libffi-$(LIBFFI_VER)/configure $(LIBFFI_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libffi/ins/usr/share
	mv -f tmp/libffi/ins/usr/lib64/* tmp/libffi/ins/usr/lib
	rm -fr tmp/libffi/ins/usr/lib64
	rm -f  tmp/libffi/ins/usr/lib/*.la
	cd tmp/libffi/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libffi/ins/usr/lib/*.so*
endif
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/libffi/bld && make check 2>&1 | tee ../../../tst/libffi-check.log || true
#		=== libffi Summary ===
# of expected passes		1554
# Looks like OK!
#endif
	rm -fr tmp/libffi
tgt-libffi: pkg2/libffi-$(LIBFFI_VER).cpio.zst

# LFS-10.0-systemd :: 8.48. OpenSSL-1.1.1g
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/openssl.html
# BUILD_TIME :: 3m 16s
# BUILD_TIME_WITH_TEST :: 7m 8s
OPENSSL_OPT2+= --prefix=/usr
OPENSSL_OPT2+= --openssldir=/etc/ssl
OPENSSL_OPT2+= --libdir=lib
OPENSSL_OPT2+= shared
OPENSSL_OPT2+= zlib-dynamic
OPENSSL_OPT2+= $(OPT_FLAGS)
pkg2/openssl-$(OPEN_SSL_VER).cpio.zst: pkg2/libffi-$(LIBFFI_VER).cpio.zst
	rm -fr tmp/openssl
	mkdir -p tmp/openssl/bld
	tar -xzf src/openssl-$(OPEN_SSL_VER).tar.gz -C tmp/openssl
	cd tmp/openssl/bld && ../openssl-$(OPEN_SSL_VER)/config $(OPENSSL_OPT2) && make $(JOBS) V=$(VERB)
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' tmp/openssl/bld/Makefile
	cd tmp/openssl/bld && make MANSUFFIX=ssl DESTDIR=`pwd`/../ins install
	rm -fr tmp/openssl/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/openssl/ins/usr/bin/openssl
	strip --strip-debug tmp/openssl/ins/usr/lib/*.a || true
	cd tmp/openssl/ins/usr/lib && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/openssl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/openssl/bld && make test 2>&1 | tee ../../../tst/openssl-test.log || true
#../../openssl-1.1.1g/test/recipes/80-test_cms.t ...................... 
#Dubious, test returned 5 (wstat 1280, 0x500)
#Failed 5/6 subtests 
#../../openssl-1.1.1g/test/recipes/80-test_ssl_new.t .................. 
#Dubious, test returned 1 (wstat 256, 0x100)
#Failed 1/29 subtests 
#Test Summary Report
#-------------------
#../../openssl-1.1.1g/test/recipes/80-test_cms.t                    (Wstat: 1280 Tests: 6 Failed: 5)
#  Failed tests:  1-5
#  Non-zero exit status: 5
#../../openssl-1.1.1g/test/recipes/80-test_ssl_new.t                (Wstat: 256 Tests: 29 Failed: 1)
#  Failed test:  12
#  Non-zero exit status: 1
#Files=155, Tests=1468, 225 wallclock secs ( 6.18 usr  0.65 sys + 177.19 cusr 58.49 csys = 242.51 CPU)
#Result: FAIL
#endif
	rm -fr tmp/openssl
tgt-openssl: pkg2/openssl-$(OPEN_SSL_VER).cpio.zst

# LFS-10.0-systemd :: 8.49. Python-3.8.5
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/Python.html
# BUILD_TIME :: 2m 48s
# BUILD_TIME_WITH_TEST :: 7m 8s
PYTHON_OPT2+= --prefix=/usr
PYTHON_OPT2+= --enable-shared
PYTHON_OPT2+= --with-system-expat
PYTHON_OPT2+= --with-system-ffi
PYTHON_OPT2+= --with-ensurepip=yes
PYTHON_OPT2+= $(OPT_FLAGS)
pkg2/Python-$(PYTHON_VER).cpio.zst: pkg2/openssl-$(OPEN_SSL_VER).cpio.zst
	rm -fr tmp/python
	mkdir -p tmp/python/bld
	tar -xJf src/Python-$(PYTHON_VER).tar.xz -C tmp/python
	sed -i "s|-O3|$(BASE_OPT_VALUE)|" tmp/python/Python-$(PYTHON_VER)/configure
	cd tmp/python/bld && ../Python-$(PYTHON_VER)/configure $(PYTHON_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/python/ins/usr/share
	chmod -v 755 tmp/python/ins/usr/lib/libpython$(PYTHON_VER0).so
	chmod -v 755 tmp/python/ins/usr/lib/libpython$(PYTHON_VER00).so
	cd tmp/python/ins/usr/bin && ln -sfv pip3.8 pip3
	cd tmp/python/ins/usr/bin && ln -sfv python3 python
	cd tmp/python/ins/usr/bin && ln -sfv pip3 pip
ifeq ($(BUILD_STRIP),y)
	cd tmp/python/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/python/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#PKG+=pkg/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/python/bld && make test 2>&1 | tee ../../../tst/python-test.log || true
# == Tests result: FAILURE ==
# 398 tests OK.
# 5 tests failed:
#    test_fcntl test_minidom test_normalization test_xml_etree
#    test_xml_etree_c
# 20 tests skipped:
#    test_devpoll test_gdb test_idle test_ioctl test_kqueue test_msilib
#    test_nis test_ossaudiodev test_sqlite test_startfile test_tcl
#    test_tix test_tk test_ttk_guionly test_ttk_textonly test_turtle
#    test_winconsoleio test_winreg test_winsound test_zipfile64
# test_issue3151 (test.test_xml_etree.BugsTest) ... ERROR
# ERROR: test_issue3151 (test.test_xml_etree.BugsTest)
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/etree/ElementTree.py", line 1693, in feed
#    self.parser.Parse(data, 0)
# xml.parsers.expat.ExpatError: syntax error: line 1, column 0
# During handling of the above exception, another exception occurred:
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_xml_etree.py", line 1969, in test_issue3151
#    e = ET.XML('<prefix:localname xmlns:prefix="${stuff}"/>')
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/etree/ElementTree.py", line 1320, in XML
#    parser.feed(text)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/etree/ElementTree.py", line 1695, in feed
#    self._raiseerror(v)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/etree/ElementTree.py", line 1602, in _raiseerror
#    raise err
#  File "<string>", line None
# xml.etree.ElementTree.ParseError: syntax error: line 1, column 0
# test_correct_import_pyET (test.test_xml_etree.NoAcceleratorTest) ... test test_xml_etree_c failed
# ERROR: test_issue3151 (test.test_xml_etree.BugsTest)
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_xml_etree.py", line 1969, in test_issue3151
#    e = ET.XML('<prefix:localname xmlns:prefix="${stuff}"/>')
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/etree/ElementTree.py", line 1320, in XML
#    parser.feed(text)
#  File "<string>", line None
# xml.etree.ElementTree.ParseError: syntax error: line 1, column 0
# Ran 177 tests in 0.506s
# FAILED (errors=1, skipped=4)
# 0:04:14 load avg: 8.33 Re-running test_fcntl in verbose mode
# struct.pack:  b'\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
# test_fcntl_64_bit (test.test_fcntl.TestFcntl) ... ERROR
# ERROR: test_fcntl_64_bit (test.test_fcntl.TestFcntl)
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_fcntl.py", line 138, in test_fcntl_64_bit
#    fcntl.fcntl(fd, cmd, flags)
# OSError: [Errno 22] Invalid argument
# Ran 9 tests in 0.029s
# FAILED (errors=1)
# 0:04:15 load avg: 8.33 Re-running test_normalization in verbose mode
# test_bug_834676 (test.test_normalization.NormalizationTest) ... ok
# test_main (test.test_normalization.NormalizationTest) ... test test_normalization failed
# 	fetching http://www.pythontest.net/unicode/12.1.0/NormalizationTest.txt ...
# FAIL
# FAIL: test_main (test.test_normalization.NormalizationTest)
# Traceback (most recent call last):
#   File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/urllib/request.py", line 1350, in do_open
#   h.request(req.get_method(), req.selector, req.data, headers,
# socket.gaierror: [Errno -3] Temporary failure in name resolution
# During handling of the above exception, another exception occurred:
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_normalization.py", line 41, in test_main
#    testdata = open_urlresource(TESTDATAURL, encoding="utf-8",
# urllib.error.URLError: <urlopen error [Errno -3] Temporary failure in name resolution>
# During handling of the above exception, another exception occurred:
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_normalization.py", line 47, in test_main
#    self.fail(f"Could not retrieve {TESTDATAURL}")
#AssertionError: Could not retrieve http://www.pythontest.net/unicode/12.1.0/NormalizationTest.txt
# Ran 2 tests in 0.021s
# FAILED (failures=1)
# ERROR: testEncodings (test.test_minidom.MinidomTest)
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_minidom.py", line 1150, in testEncodings
#    self.assertRaises(UnicodeDecodeError, parseString,
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/unittest/case.py", line 816, in assertRaises
#    return context.handle('assertRaises', args, kwargs)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/unittest/case.py", line 202, in handle
#    callable_obj(*args, **kwargs)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/minidom.py", line 1969, in parseString
#    return expatbuilder.parseString(string)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/expatbuilder.py", line 925, in parseString
#    return builder.parseString(string)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/expatbuilder.py", line 223, in parseString
#    parser.Parse(string, True)
# xml.parsers.expat.ExpatError: not well-formed (invalid token): line 1, column 5
# ERROR: testExceptionOnSpacesInXMLNSValue (test.test_minidom.MinidomTest)
# Traceback (most recent call last):
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/test/test_minidom.py", line 1597, in testExceptionOnSpacesInXMLNSValue
#    parseString('<element xmlns:abc="http:abc.com/de f g/hi/j k"><abc:foo /></element>')
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/minidom.py", line 1969, in parseString
#    return expatbuilder.parseString(string)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/expatbuilder.py", line 925, in parseString
#    return builder.parseString(string)
#  File "/opt/mysdk/tmp/python/Python-3.8.5/Lib/xml/dom/expatbuilder.py", line 223, in parseString
#    parser.Parse(string, True)
# xml.parsers.expat.ExpatError: syntax error: line 1, column 0
# Ran 126 tests in 0.038s
# FAILED (errors=2)
# 5 tests failed again:
#    test_fcntl test_minidom test_normalization test_xml_etree
#    test_xml_etree_c
# == Tests result: FAILURE then FAILURE ==
# 398 tests OK.
# 5 tests failed:
#    test_fcntl test_minidom test_normalization test_xml_etree
#    test_xml_etree_c
# 20 tests skipped:
#    test_devpoll test_gdb test_idle test_ioctl test_kqueue test_msilib
#    test_nis test_ossaudiodev test_sqlite test_startfile test_tcl
#    test_tix test_tk test_ttk_guionly test_ttk_textonly test_turtle
#    test_winconsoleio test_winreg test_winsound test_zipfile64
# 5 re-run tests:
#    test_fcntl test_minidom test_normalization test_xml_etree
#    test_xml_etree_c
# Total duration: 4 min 15 sec
# Tests result: FAILURE then FAILURE
#endif
	rm -fr tmp/python
tgt-python: pkg2/Python-$(PYTHON_VER).cpio.zst

# extra : RE2C (for ninja)
# https://github.com/skvadrik/re2c/releases/tag/3.1
# BUILD_TIME :: 1m 18s
# BUILD_TIME_WITH_TEST :: 1m 28s
RE2C_OPT2+= --prefix=/usr
RE2C_OPT2+= $(OPT_FLAGS)
pkg2/re2c-$(RE2C_VER).cpio.zst: pkg2/Python-$(PYTHON_VER).cpio.zst
	rm -fr tmp/re2c
	mkdir -p tmp/re2c/bld
	tar -xzf src/re2c-$(RE2C_VER).tar.gz -C tmp/re2c
	cd tmp/re2c/re2c-$(RE2C_VER) && autoreconf -i -W all
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/re2c/re2c-$(RE2C_VER)/configure
	cd tmp/re2c/bld && ../re2c-$(RE2C_VER)/configure $(RE2C_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/re2c/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/re2c/ins/usr/bin/*
endif
	cd tmp/re2c/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/re2c/bld && make check 2>&1 | tee ../../../tst/re2c-check.log || true
#============================================================================
#Testsuite summary for re2c 3.1
#============================================================================
# TOTAL: 5
# PASS:  5
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/re2c
tgt-re2c: pkg2/re2c-$(RE2C_VER).cpio.zst

# LFS-10.0-systemd :: 8.50. Ninja-1.10.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/ninja.html
# BUILD_TIME :: 36s
# BUILD_TIME_WITH_TEST :: 50s
pkg2/ninja-$(NINJA_VER).cpio.zst: pkg2/re2c-$(RE2C_VER).cpio.zst
	rm -fr tmp/ninja
	mkdir -p tmp/ninja
	tar -xzf src/ninja-$(NINJA_VER).tar.gz -C tmp/ninja
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
	strip --strip-unneeded tmp/ninja/ins/usr/bin/ninja
endif
	cd tmp/ninja/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	cd tmp/ninja/ninja-$(NINJA_VER) && ./ninja ninja_test && ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
# [19/19] LINK ninja_test
# [341/341] ElideMiddle.ElideInTheMiddle
# passed
#endif
	rm -fr tmp/ninja
tgt-ninja: pkg2/ninja-$(NINJA_VER).cpio.zst

# LFS-10.0-systemd :: 8.51. Meson-0.55.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/meson.html
# BUILD_TIME :: 3s
pkg2/meson-$(MESON_VER).cpio.zst: pkg2/ninja-$(NINJA_VER).cpio.zst
	rm -fr tmp/meson
	mkdir -p tmp/meson
	tar -xzf src/meson-$(MESON_VER).tar.gz -C tmp/meson
	cd tmp/meson/meson-$(MESON_VER) && python3 setup.py build && python3 setup.py install --root=OUT
	rm -fr tmp/meson/meson-$(MESON_VER)/OUT/usr/share/man
	mkdir -p tmp/meson/ins
	cp -far tmp/meson/meson-$(MESON_VER)/OUT/usr tmp/meson/ins/
	cd tmp/meson/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/meson
tgt-meson: pkg2/meson-$(MESON_VER).cpio.zst

# LFS-10.0-systemd :: 8.52. Coreutils-8.32
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/coreutils.html
# BUILD_TIME :: 2m 58s
# BUILD_TIME_WITH_TEST :: 10m 44s
COREUTILS_OPT2+= --prefix=/usr
COREUTILS_OPT2+= --enable-no-install-program=kill,uptime
COREUTILS_OPT2+= --disable-nls
COREUTILS_OPT2+= $(OPT_FLAGS)
pkg2/coreutils-$(CORE_UTILS_VER).cpio.zst: pkg2/meson-$(MESON_VER).cpio.zst
	rm -fr tmp/coreutils
	mkdir -p tmp/coreutils/bld
	tar -xJf src/coreutils-$(CORE_UTILS_VER).tar.xz -C tmp/coreutils
#	cp -f pkg/coreutils-$(CORE_UTILS_VER)-i18n-1.patch tmp/coreutils/
#	cd tmp/coreutils/coreutils-$(CORE_UTILS_VER) && patch -Np1 -i ../coreutils-$(CORE_UTILS_VER)-i18n-1.patch
### gcc   -mcpu=cortex-a76.cortex-a55+crypto -Os -Wl,--as-needed  -o src/expand src/expand.o src/expand-common.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a 
### /bin/ld: src/expand.o: in function `main':
### expand.c:(.text.startup+0x1e8): undefined reference to `mbfile_multi_getc'
### collect2: error: ld returned 1 exit status
# https://github.com/dslm4515/Musl-LFS/issues/11
	sed -i '/test.lock/s/^/#/' tmp/coreutils/coreutils-$(CORE_UTILS_VER)/gnulib-tests/gnulib.mk
	sed -i "s/SYS_getdents/SYS_getdents64/" tmp/coreutils/coreutils-$(CORE_UTILS_VER)/src/ls.c
	cd tmp/coreutils/coreutils-$(CORE_UTILS_VER) && autoreconf -fiv
	cd tmp/coreutils/bld && FORCE_UNSAFE_CONFIGURE=1 ../coreutils-$(CORE_UTILS_VER)/configure $(COREUTILS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/coreutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/coreutils/ins/usr/libexec/coreutils/libstdbuf.so
	strip --strip-unneeded tmp/coreutils/ins/usr/bin/* || true
endif
	cd tmp/coreutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	cd tmp/coreutils/bld && make NON_ROOT_USERNAME=tester check-root || true
#	echo "dummy:x:102:tester" >> /etc/group
#	cd tmp/coreutils/bld && chown -Rv tester .
#	cd tmp/coreutils/bld && su tester -c "PATH=$$PATH make RUN_EXPENSIVE_TESTS=yes check" || true
#	sed -i '/dummy/d' /etc/group
# as root
#============================================================================
#Testsuite summary for GNU coreutils 8.32
#============================================================================
# TOTAL: 621
# PASS:  489
# SKIP:  132
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
# as tester
#============================================================================
#Testsuite summary for GNU coreutils 8.32
#============================================================================
# TOTAL: 345
# PASS:  307
# SKIP:  38
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/coreutils
tgt-coreutils: pkg2/coreutils-$(CORE_UTILS_VER).cpio.zst

# LFS-10.0-systemd :: 8.53. Check-0.15.2
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/check.html
# BUILD_TIME :: 25s
# BUILD_TIME_WITH_TEST :: 6m 45s
#CHECK_OPT2+= --prefix=/usr
#CHECK_OPT2+= --disable-static
#CHECK_OPT2+= $(OPT_FLAGS)
#pkg2/check-$(CHECK_VER).cpio.zst: pkg2/coreutils-$(CORE_UTILS_VER).cpio.zst
#	rm -fr tmp/check
#	mkdir -p tmp/check/bld
#	tar -xzf src/check-$(CHECK_VER).tar.gz -C tmp/check
#	cd tmp/check/bld && ../check-$(CHECK_VER)/configure $(CHECK_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/check/ins/usr/share/doc
#	rm -fr tmp/check/ins/usr/share/info
#	rm -fr tmp/check/ins/usr/share/man
#	rm -f  tmp/check/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/check/ins/usr/lib/*.so*
#endif
#	cd tmp/check/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/check/check-$(CHECK_VER) && ./configure $(CHECK_OPT3) && make $(JOBS) V=$(VERB) && make check 2>&1 | tee ../../../tst/check-check.log || true
# TOTAL: 1
# PASS:  1
## make  check-TESTS
## make[3]: Entering directory '/opt/mysdk/tmp/check/check-0.15.2/tests'
## make[4]: Entering directory '/opt/mysdk/tmp/check/check-0.15.2/tests'
# ^^^ Very Long Time without any activity at this point, but then it will continue!
## PASS: check_check_export
# ^^^ Very Long Time without any activity at this point, but then it will continue!
#============================================================================
#Testsuite summary for Check 0.15.2
#============================================================================
# TOTAL: 9
# PASS:  9
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
#	rm -fr tmp/check
#tgt-check: pkg2/check-$(CHECK_VER).cpio.zst

# LFS-10.0-systemd :: 8.54. Diffutils-3.7
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/diffutils.html
# BUILD_TIME :: 58s
# BUILD_TIME_WITH_TEST :: 1m 55s
DIFFUTILS_OPT2+= --prefix=/usr
DIFFUTILS_OPT2+= --disable-nls
DIFFUTILS_OPT2+= $(OPT_FLAGS)
pkg2/diffutils-$(DIFF_UTILS_VER).cpio.zst: pkg2/coreutils-$(CORE_UTILS_VER).cpio.zst
	rm -fr tmp/diffutils
	mkdir -p tmp/diffutils/bld
	tar -xJf src/diffutils-$(DIFF_UTILS_VER).tar.xz -C tmp/diffutils
	cd tmp/diffutils/bld && ../diffutils-$(DIFF_UTILS_VER)/configure $(DIFFUTILS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/diffutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/diffutils/ins/usr/bin/*
endif
	cd tmp/diffutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/diffutils/bld && make check 2>&1 | tee ../../../tst/diffutils-check.log || true
#============================================================================
#Testsuite summary for GNU diffutils 3.7
#============================================================================
# TOTAL: 173
# PASS:  145
# SKIP:  28
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#endif
	rm -fr tmp/diffutils
tgt-diffutils: pkg2/diffutils-$(DIFF_UTILS_VER).cpio.zst

# LFS-10.0-systemd :: 8.55. Gawk-5.1.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gawk.html
# BUILD_TIME :: 48s
# BUILD_TIME_WITH_TEST :: 1m 18s
GAWK_OPT2+= --prefix=/usr
GAWK_OPT2+= --disable-nls
GAWK_OPT2+= $(OPT_FLAGS)
pkg2/gawk-$(GAWK_VER).cpio.zst: pkg2/diffutils-$(DIFF_UTILS_VER).cpio.zst
	rm -fr tmp/gawk
	mkdir -p tmp/gawk/bld
	tar -xJf src/gawk-$(GAWK_VER).tar.xz -C tmp/gawk
	sed -i 's/extras//' tmp/gawk/gawk-$(GAWK_VER)/Makefile.in
	cd tmp/gawk/bld && ../gawk-$(GAWK_VER)/configure $(GAWK_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gawk/ins/usr/share/info
	rm -fr tmp/gawk/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gawk/ins/usr/libexec/awk/*
	strip --strip-unneeded tmp/gawk/ins/usr/lib/gawk/*
	strip --strip-unneeded tmp/gawk/ins/usr/bin/*
endif
	cd tmp/gawk/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gawk/bld && make check 2>&1 | tee ../../../tst/gawk-check.log || true
# ALL TESTS PASSED
#endif
	rm -fr tmp/gawk
tgt-gawk: pkg2/gawk-$(GAWK_VER).cpio.zst

# LFS-10.0-systemd :: 8.56. Findutils-4.7.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/findutils.html
# BUILD_TIME :: 1m 35s
# BUILD_TIME_WITH_TEST :: 3m 41s
FINDUTILS_OPT2+= --prefix=/usr
FINDUTILS_OPT2+= --localstatedir=/var/lib/locate
FINDUTILS_OPT2+= --disable-nls
FINDUTILS_OPT2+= $(OPT_FLAGS)
pkg2/findutils-$(FIND_UTILS_VER).cpio.zst: pkg2/gawk-$(GAWK_VER).cpio.zst
	rm -fr tmp/findutils
	mkdir -p tmp/findutils/bld
	tar -xJf src/findutils-$(FIND_UTILS_VER).tar.xz -C tmp/findutils
	cd tmp/findutils/bld && ../findutils-$(FIND_UTILS_VER)/configure $(FINDUTILS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/findutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/findutils/ins/usr/libexec/frcode
	strip --strip-unneeded tmp/findutils/ins/usr/bin/* || true
endif
	cd tmp/findutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/findutils/bld && chown -Rv tester . && su tester -c "PATH=$$PATH make check"
#============================================================================
#Testsuite summary for GNU findutils 4.7.0
#============================================================================
# TOTAL: 12
# PASS:  11
# SKIP:  1
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/findutils
tgt-findutils: pkg2/findutils-$(FIND_UTILS_VER).cpio.zst

# LFS-10.0-systemd :: 8.57. Groff-1.22.4
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/groff.html
# BUILD_TIME :: 2m 7s
#GROFF_PREP_OPT2+= PAGE=A4
#GROFF_OPT2+= --prefix=/usr
#GROFF_OPT2+= $(OPT_FLAGS)
#pkg2/groff-$(GROFF_VER).cpio.zst: pkg2/findutils-$(FIND_UTILS_VER).cpio.zst
#	rm -fr tmp/groff
#	mkdir -p tmp/groff/bld
#	tar -xzf src/groff-$(GROFF_VER).tar.gz -C tmp/groff
#	cd tmp/groff/bld && $(GROFF_PREP_OPT2) ../groff-$(GROFF_VER)/configure $(GROFF_OPT2) && make -j1 V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/groff/ins/usr/share/doc
#	rm -fr tmp/groff/ins/usr/share/info
#	rm -fr tmp/groff/ins/usr/share/man
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/groff/ins/usr/bin/* || true
#endif
#	cd tmp/groff/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/groff
#tgt-groff: pkg2/groff-$(GROFF_VER).cpio.zst

# LFS-10.0-systemd :: 8.58. GRUB-2.04
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/grub.html
# N/A

# LFS-10.0-systemd :: 8.59. Less-551
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/less.html
# BUILD_TIME :: 14s
LESS_OPT2+= --prefix=/usr
LESS_OPT2+= --sysconfdir=/etc
LESS_OPT2+= $(OPT_FLAGS)
pkg2/less-$(LESS_VER).cpio.zst: pkg2/findutils-$(FIND_UTILS_VER).cpio.zst
	rm -fr tmp/less
	mkdir -p tmp/less/bld
	tar -xzf src/less-$(LESS_VER).tar.gz -C tmp/less
	cd tmp/less/bld && ../less-$(LESS_VER)/configure $(LESS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/less/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/less/ins/usr/bin/* || true
endif
	cd tmp/less/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/less
tgt-less: pkg2/less-$(LESS_VER).cpio.zst

# LFS-10.0-systemd :: 8.60. Gzip-1.10
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/gzip.html
# BUILD_TIME :: 43s
# BUILD_TIME_WITH_TEST :: 50s
GZIP_OPT2+= --prefix=/usr
GZIP_OPT2+= $(OPT_FLAGS)
pkg2/gzip-$(GZIP_VER).cpio.zst: pkg2/less-$(LESS_VER).cpio.zst
	rm -fr tmp/gzip
	mkdir -p tmp/gzip/bld
	tar -xJf src/gzip-$(GZIP_VER).tar.xz -C tmp/gzip
	cd tmp/gzip/bld && ../gzip-$(GZIP_VER)/configure $(GZIP_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/gzip/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/gzip/ins/usr/bin/* || true
endif
	cd tmp/gzip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/gzip/bld && make check 2>&1 | tee ../../../tst/gzip-check.log || true
#============================================================================
#Testsuite summary for gzip 1.10
#============================================================================
# TOTAL: 22
# PASS:  22
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/gzip
tgt-gzip: pkg2/gzip-$(GZIP_VER).cpio.zst

# extra blfs :: Which-2.21 and Alternatives
# https://www.linuxfromscratch.org/blfs/view/10.0/general/which.html
# BUILD_TIME :: 8s
WHICH_OPT2+= --prefix=/usr
WHICH_OPT2+= $(OPT_FLAGS)
pkg2/which-$(WHICH_VER).cpio.zst: pkg2/gzip-$(GZIP_VER).cpio.zst
	rm -fr tmp/which
	mkdir -p tmp/which/bld
	tar -xzf src/which-$(WHICH_VER).tar.gz -C tmp/which
	cd tmp/which/bld && ../which-$(WHICH_VER)/configure $(WHICH_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/which/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/which/ins/usr/bin/which
endif
	cd tmp/which/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/which
# -------------------
# "Which" alternative
pkg2/which.cpio.zst: pkg2/gzip-$(GZIP_VER).cpio.zst
	rm -fr tmp/which
	mkdir -p tmp/which/ins/usr/bin
	echo '#!/bin/bash' > tmp/which/ins/usr/bin/which
	echo 'type -pa "$$@" | head -n 1 ; exit $${PIPESTATUS[0]}' >> tmp/which/ins/usr/bin/which
	chmod -v 755 tmp/which/ins/usr/bin/which
	chown -v root:root tmp/which/ins/usr/bin/which
	cd tmp/which/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/which
tgt-which: pkg2/which.cpio.zst

# extra blfs :: Sharutils-4.15.2
# https://www.linuxfromscratch.org/blfs/view/10.0/general/sharutils.html
# BUILD_TIME :: 1m 29s
# BUILD_TIME_WITH_TEST :: 1m 43s
#SHARUTILS_OPT2+= --prefix=/usr
#SHARUTILS_OPT2+= --disable-nls
#SHARUTILS_OPT2+= $(OPT_FLAGS)
#pkg2/sharutils-$(SHARUTILS_VER).cpio.zst: pkg2/which.cpio.zst
#	rm -fr tmp/sharutils
#	mkdir -p tmp/sharutils/bld
#	tar -xJf src/sharutils-$(SHARUTILS_VER).tar.xz -C tmp/sharutils
#	sed -i 's/BUFSIZ/rw_base_size/' tmp/sharutils/sharutils-$(SHARUTILS_VER)/src/unshar.c
#	sed -i '/program_name/s/^/extern /' tmp/sharutils/sharutils-$(SHARUTILS_VER)/src/*opts.h
#	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/sharutils/sharutils-$(SHARUTILS_VER)/lib/*.c
#	echo "#define _IO_IN_BACKUP 0x100" >> tmp/sharutils/sharutils-$(SHARUTILS_VER)/lib/stdio-impl.h
#	cd tmp/sharutils/bld && ../sharutils-$(SHARUTILS_VER)/configure $(SHARUTILS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/sharutils/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/sharutils/ins/usr/bin/*
#endif
#	cd tmp/sharutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/sharutils/bld && make check 2>&1 | tee ../../../tst/sharutils-check.log || true
#============================================================================
#Testsuite summary for GNU sharutils 4.15.2
#============================================================================
# TOTAL: 6
# PASS:  6
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
#	rm -fr tmp/sharutils
#tgt-sharutils: pkg2/sharutils-$(SHARUTILS_VER).cpio.zst

# extra blfs :: Berkeley DB-5.3.28
# https://www.linuxfromscratch.org/blfs/view/10.0/server/db.html
# BUILD_TIME :: 1m 4s
DB_BERKELEY_OPT2+= --prefix=/usr
DB_BERKELEY_OPT2+= --enable-compat185
DB_BERKELEY_OPT2+= --enable-dbm
DB_BERKELEY_OPT2+= --disable-static
DB_BERKELEY_OPT2+= --enable-cxx
DB_BERKELEY_OPT2+= --enable-tcl
DB_BERKELEY_OPT2+= --with-tcl=/usr/lib
DB_BERKELEY_OPT2+= $(OPT_FLAGS)
#pkg2/db-$(DB_BERKELEY_VER).cpio.zst: pkg2/sharutils-$(SHARUTILS_VER).cpio.zst
pkg2/db-$(DB_BERKELEY_VER).cpio.zst: pkg2/which.cpio.zst
	rm -fr tmp/db
	mkdir -p tmp/db/bld
	tar -xzf src/db-$(DB_BERKELEY_VER).tar.gz -C tmp/db
	sed -i 's/\(__atomic_compare_exchange\)/\1_db/' tmp/db/db-$(DB_BERKELEY_VER)/src/dbinc/atomic.h
	cp -far src/config.guess tmp/db/db-$(DB_BERKELEY_VER)/dist/
	cp -far src/config.sub tmp/db/db-$(DB_BERKELEY_VER)/dist/
	cd tmp/db/bld && ../db-$(DB_BERKELEY_VER)/dist/configure $(DB_BERKELEY_OPT2) && make $(JOBS) V=$(VERB) && make docdir=/usr/share/doc/db-$(DB_BERKELEY_VER) DESTDIR=`pwd`/../ins install
	rm -fr tmp/db/ins/usr/share
	rm -f  tmp/db/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/db/ins/usr/bin/* || true
	strip --strip-unneeded tmp/db/ins/usr/lib/*.so*
endif
	cd tmp/db/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/db
tgt-db: pkg2/db-$(DB_BERKELEY_VER).cpio.zst

# extra blfs :: libmnl-1.0.4
# https://www.linuxfromscratch.org/blfs/view/10.0/basicnet/libmnl.html
# https://git.netfilter.org/libmnl/
# BUILD_TIME :: 9s
LIBMNL_OPT2+= --prefix=/usr
LIBMNL_OPT2+= $(OPT_FLAGS)
pkg2/libmnl-$(LIBMNL_VER).cpio.zst: pkg2/db-$(DB_BERKELEY_VER).cpio.zst
	rm -fr tmp/libmnl
	mkdir -p tmp/libmnl/bld
	tar -xjf src/libmnl-$(LIBMNL_VER).tar.bz2 -C tmp/libmnl
	cd tmp/libmnl/bld && ../libmnl-$(LIBMNL_VER)/configure $(LIBMNL_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f  tmp/libmnl/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libmnl/ins/usr/lib/*.so*
endif
	cd tmp/libmnl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libmnl
tgt-libmnl: pkg2/libmnl-$(LIBMNL_VER).cpio.zst

# LFS-10.0-systemd :: 8.61. IPRoute2-5.8.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/iproute2.html
# BUILD_TIME :: 18s
pkg2/iproute2-$(IP_ROUTE2_VER).cpio.zst: pkg2/libmnl-$(LIBMNL_VER).cpio.zst
	rm -fr tmp/iproute2
	mkdir -p tmp/iproute2
	tar -xJf src/iproute2-$(IP_ROUTE2_VER).tar.xz -C tmp/iproute2
	sed -i 's/.m_ipt.o//' tmp/iproute2/iproute2-$(IP_ROUTE2_VER)/tc/Makefile
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/iproute2/iproute2-$(IP_ROUTE2_VER)/Makefile
# libc has setns: yes
# ELF support: yes
# need for strlcpy: yes
# libcap support: yes
# Berkeley DB: yes
# libmnl support: yes
### ATM	no
### SELinux support: no
	cd tmp/iproute2/iproute2-$(IP_ROUTE2_VER) && make $(JOBS) V=$(VERB) && make DOCDIR=/usr/share/doc/iproute2-$(IP_ROUTE2_VER) DESTDIR=`pwd`/../ins install
	mv -fv tmp/iproute2/ins/sbin tmp/iproute2/ins/usr/
	rm -fr tmp/iproute2/ins/usr/share/man
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/iproute2/ins/usr/sbin/* || true
endif
	cd tmp/iproute2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/iproute2
tgt-iproute2: pkg2/iproute2-$(IP_ROUTE2_VER).cpio.zst

# LFS-10.0-systemd :: 8.62. Kbd-2.3.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/kbd.html
# BUILD_TIME :: 53s
# BUILD_TIME_WITH_TEST ::
KBD_OPT2+= --prefix=/usr
KBD_OPT2+= --disable-vlock
KBD_OPT2+= --disable-nls
KBD_OPT2+= CFLAGS="$(RK3588_FLAGS)"
pkg2/kbd-$(KBD_VER).cpio.zst: pkg2/iproute2-$(IP_ROUTE2_VER).cpio.zst
	rm -fr tmp/kbd
	mkdir -p tmp/kbd/bld
	tar -xJf src/kbd-$(KBD_VER).tar.xz -C tmp/kbd
	cp -f src/kbd-$(KBD_VER)-backspace-1.patch tmp/kbd/
	cd tmp/kbd/kbd-$(KBD_VER) && patch -Np1 -i ../kbd-$(KBD_VER)-backspace-1.patch
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' tmp/kbd/kbd-$(KBD_VER)/configure
	sed -i 's/resizecons.8 //' tmp/kbd/kbd-$(KBD_VER)/docs/man/man8/Makefile.in
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/m4/libtool.m4
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure.ac
	sed -i 's|-O2|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure.ac
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/configure
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/m4/ax_code_coverage.m4
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/tests/libtswrap/Makefile.in
	sed -i 's|-O0|$(BASE_OPT_VALUE)|' tmp/kbd/kbd-$(KBD_VER)/tests/libtswrap/Makefile.am
	cd tmp/kbd/bld && ../kbd-$(KBD_VER)/configure $(KBD_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
# warning: remember to run 'libtool --finish /usr/lib'
# This's because DESTDIR install. It's not a problem.
	rm -fr tmp/kbd/ins/usr/share/man
	rm -fr tmp/kbd/ins/usr/lib
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/kbd/ins/usr/bin/* || true
endif
	cd tmp/kbd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/kbd/bld && make check 2>&1 | tee ../../../tst/kbd-check.log || true
# 36 tests were successful.
# 4 tests were skipped.
#endif
	rm -fr tmp/kbd
tgt-kbd: pkg2/kbd-$(KBD_VER).cpio.zst

# LFS-10.0-systemd :: 8.63. Libpipeline-1.5.3
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/libpipeline.html
# BUILD_TIME :: 57s
# BUILD_TIME_WITH_TEST :: 1m 4s
LIBPIPILINE_OPT2+= --prefix=/usr
LIBPIPILINE_OPT2+= $(OPT_FLAGS)
pkg2/libpipeline-$(LIBPIPILINE_VER).cpio.zst: pkg2/kbd-$(KBD_VER).cpio.zst
	rm -fr tmp/libpipeline
	mkdir -p tmp/libpipeline/bld
	tar -xzf src/libpipeline-$(LIBPIPILINE_VER).tar.gz -C tmp/libpipeline
	cd tmp/libpipeline/bld && ../libpipeline-$(LIBPIPILINE_VER)/configure $(LIBPIPILINE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libpipeline/ins/usr/share
	rm -f  tmp/libpipeline/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libpipeline/ins/usr/lib/*.so*
endif
	cd tmp/libpipeline/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/libpipeline/bld && make check 2>&1 | tee ../../../tst/libpipeline-check.log || true
#============================================================================
#Testsuite summary for libpipeline 1.5.3
#============================================================================
# TOTAL: 7
# PASS:  7
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/libpipeline
tgt-libpipeline: pkg2/libpipeline-$(LIBPIPILINE_VER).cpio.zst

# LFS-10.0-systemd :: 8.64. Make-4.3
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/make.html
# BUILD_TIME :: 30s
# BUILD_TIME_WITH_TEST ::
MAKE_OPT2+= --prefix=/usr
MAKE_OPT2+= --disable-nls
MAKE_OPT2+= $(OPT_FLAGS)
pkg2/make-$(MAKE_VER).cpio.zst: pkg2/libpipeline-$(LIBPIPILINE_VER).cpio.zst
	rm -fr tmp/make
	mkdir -p tmp/make/bld
	tar -xzf src/make-$(MAKE_VER).tar.gz -C tmp/make
	cd tmp/make/bld && ../make-$(MAKE_VER)/configure $(MAKE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/make/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/make/ins/usr/bin/make
endif
	cd tmp/make/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/make/bld && make check 2>&1 | tee ../../../tst/make-check.log || true
# 690 Tests in 125 Categories Complete ... No Failures :-)
#endif
	rm -fr tmp/make
tgt-make: pkg2/make-$(MAKE_VER).cpio.zst

# LFS-10.0-systemd :: 8.65. Patch-2.7.6
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/patch.html
# BUILD_TIME :: 1m 19s
# BUILD_TIME_WITH_TEST ::
PATCH_OPT2+= --prefix=/usr
PATCH_OPT2+= $(OPT_FLAGS)
pkg2/patch-$(PATCH_VER).cpio.zst: pkg2/make-$(MAKE_VER).cpio.zst
	rm -fr tmp/patch
	mkdir -p tmp/patch/bld
	tar -xJf src/patch-$(PATCH_VER).tar.xz -C tmp/patch
	cd tmp/patch/bld && ../patch-$(PATCH_VER)/configure $(PATCH_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/patch/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/patch/ins/usr/bin/patch
endif
	cd tmp/patch/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/patch/bld && make check 2>&1 | tee ../../../tst/patch-check.log || true
#============================================================================
#Testsuite summary for GNU patch 2.7.6
#============================================================================
# TOTAL: 44
# PASS:  41
# SKIP:  1
# XFAIL: 2
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/patch
tgt-patch: pkg2/patch-$(PATCH_VER).cpio.zst

###############################################################################
# THIS POINT IS: 144m 38s (2h 42m)
###############################################################################

# LFS-10.0-systemd :: 8.66. Man-DB-2.9.3
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/man-db.html
# SKIP THIS STEP.

# LFS-10.0-systemd :: 8.67. Tar-1.32
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/tar.html
# BUILD_TIME :: 1m 27s
# BUILD_TIME_WITH_TEST :: 5m 13s
TAR_OPT2+= --prefix=/usr
TAR_OPT2+= --disable-nls
TAR_OPT2+= $(OPT_FLAGS)
pkg2/tar-$(TAR_VER).cpio.zst: pkg2/patch-$(PATCH_VER).cpio.zst
	rm -fr tmp/tar
	mkdir -p tmp/tar/bld
	tar -xJf src/tar-$(TAR_VER).tar.xz -C tmp/tar
	cd tmp/tar/bld && FORCE_UNSAFE_CONFIGURE=1 ../tar-$(TAR_VER)/configure $(TAR_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tar/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/tar/ins/usr/libexec/rmt
	strip --strip-unneeded tmp/tar/ins/usr/bin/tar
endif
	cd tmp/tar/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/tar/bld && make check 2>&1 | tee ../../../tst/tar-check.log || true
# 223: capabilities: binary store/restore              FAILED (capabs_raw01.at:28)
# ERROR: 215 tests were run,
# 1 failed unexpectedly.
# 19 tests were skipped.
#endif
	rm -fr tmp/tar
tgt-tar: pkg2/tar-$(TAR_VER).cpio.zst

# LFS-10.0-systemd :: 8.68. Texinfo-6.7
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/texinfo.html
# BUILD_TIME :: 1m 9s
# BUILD_TIME_WITH_TEST :: 3m 7s
TEXINFO_OPT2+= --prefix=/usr
TEXINFO_OPT2+= --disable-static
TEXINFO_OPT2+= --disable-nls
TEXINFO_OPT2+= $(OPT_FLAGS)
pkg2/texinfo-$(TEXINFO_VER).cpio.zst: pkg2/tar-$(TAR_VER).cpio.zst
	rm -fr tmp/texinfo
	mkdir -p tmp/texinfo/bld
	tar -xJf src/texinfo-$(TEXINFO_VER).tar.xz -C tmp/texinfo
	cd tmp/texinfo/bld && ../texinfo-$(TEXINFO_VER)/configure $(TEXINFO_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/texinfo/ins/usr/share/info
	rm -fr tmp/texinfo/ins/usr/share/man
	rm -f  tmp/texinfo/ins/usr/lib/texinfo/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/texinfo/ins/usr/bin/* || true
	strip --strip-unneeded tmp/texinfo/ins/usr/lib/texinfo/*.so*
endif
	cd tmp/texinfo/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/texinfo/bld && make check 2>&1 | tee ../../../tst/texinfo-check.log || true
# TEST OK
#endif
	rm -fr tmp/texinfo
tgt-texinfo: pkg2/texinfo-$(TEXINFO_VER).cpio.zst

# extra BFS-10.0-systemd :: Nano-5.2
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/postlfs/nano.html
# BUILD_TIME :: 52s
NANO_OPT2+= --prefix=/usr
NANO_OPT2+= --sysconfdir=/etc
NANO_OPT2+= --enable-utf8
NANO_OPT2+= --docdir=/usr/share/doc/nano-$(NANO_VER)
NANO_OPT2+= --disable-nls
NANO_OPT2+= $(OPT_FLAGS)
pkg2/nano-$(NANO_VER).cpio.zst: pkg2/texinfo-$(TEXINFO_VER).cpio.zst
	rm -fr tmp/nano
	mkdir -p tmp/nano/bld
	tar -xJf src/nano-$(NANO_VER).tar.xz -C tmp/nano
	cd tmp/nano/bld && ../nano-$(NANO_VER)/configure $(NANO_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/nano/ins/usr/share/doc
	rm -fr tmp/nano/ins/usr/share/info
	rm -fr tmp/nano/ins/usr/share/man
	mkdir -p tmp/nano/ins/etc
	echo 'set autoindent' > tmp/nano/ins/etc/nanorc
	echo 'set linenumbers' >> tmp/nano/ins/etc/nanorc
	echo 'set smooth' >> tmp/nano/ins/etc/nanorc
	echo 'set mouse' >> tmp/nano/ins/etc/nanorc
	echo 'set tabsize 4' >> tmp/nano/ins/etc/nanorc
	echo 'set titlecolor red,green' >> tmp/nano/ins/etc/nanorc
#	echo 'set constantshow' >> tmp/nano/ins/etc/nanorc
#	echo 'set fill 72' >> tmp/nano/ins/etc/nanorc
#	echo 'set historylog' >> tmp/nano/ins/etc/nanorc
#	echo 'set multibuffer' >> tmp/nano/ins/etc/nanorc
#	echo 'set positionlog' >> tmp/nano/ins/etc/nanorc
#	echo 'set quickblank' >> tmp/nano/ins/etc/nanorc
#	echo 'set regexp' >> tmp/nano/ins/etc/nanorc
#	echo 'set suspend' >> tmp/nano/ins/etc/nanorc
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/nano/ins/usr/bin/nano
endif
	cd tmp/nano/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/nano
tgt-nano: pkg2/nano-$(NANO_VER).cpio.zst

# LFS-10.0-systemd :: 8.70. Systemd-246
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/systemd.html
# BUILD_TIME :: 2m 8s
# BUILD_TIME_WITH_TEST ::
SYSTEMD_MOPT2+= --prefix=/usr
SYSTEMD_MOPT2+= --sysconfdir=/etc
SYSTEMD_MOPT2+= --localstatedir=/var
SYSTEMD_MOPT2+= -Dblkid=true
#SYSTEMD_MOPT2+= -Dbuildtype=release
SYSTEMD_MOPT2+= -Ddebug=false
SYSTEMD_MOPT2+= -Doptimization=$(BASE_OPT_VAL)
SYSTEMD_MOPT2+= -Dc_args="$(RK3588_FLAGS)"
SYSTEMD_MOPT2+= -Dcpp_args="$(RK3588_FLAGS)"
SYSTEMD_MOPT2+= -Ddefault-dnssec=no
SYSTEMD_MOPT2+= -Dfirstboot=false
SYSTEMD_MOPT2+= -Dinstall-tests=false
SYSTEMD_MOPT2+= -Dkmod-path=/usr/bin/kmod
SYSTEMD_MOPT2+= -Dmount-path=/usr/bin/mount
SYSTEMD_MOPT2+= -Dumount-path=/usr/bin/umount
SYSTEMD_MOPT2+= -Dsulogin-path=/usr/sbin/sulogin
SYSTEMD_MOPT2+= -Drootlibdir=/usr/lib
SYSTEMD_MOPT2+= -Dldconfig=false
SYSTEMD_MOPT2+= -Drootprefix=
SYSTEMD_MOPT2+= -Dsplit-usr=true
SYSTEMD_MOPT2+= -Dsysusers=false
SYSTEMD_MOPT2+= -Db_lto=false
SYSTEMD_MOPT2+= -Drpmmacrosdir=no
SYSTEMD_MOPT2+= -Dhomed=false
SYSTEMD_MOPT2+= -Duserdb=false
SYSTEMD_MOPT2+= -Ddocdir=/usr/share/doc/systemd-$(SYSTEMD_VER)
SYSTEMD_MOPT2+= -Dman=false
SYSTEMD_BUILD_VERB=
ifeq ($(VERB),1)
SYSTEMD_BUILD_VERB=-v
endif
pkg2/systemd-$(SYSTEMD_VER).cpio.zst: pkg2/nano-$(NANO_VER).cpio.zst
	rm -fr tmp/systemd
	mkdir -p tmp/systemd/bld
	tar -xzf src/systemd-$(SYSTEMD_VER).tar.gz -C tmp/systemd
	ln -sf /bin/true /usr/bin/xsltproc
	sed -i '177,$$ d' tmp/systemd/systemd-$(SYSTEMD_VER)/src/resolve/meson.build
	sed -i 's/GROUP="render", //' tmp/systemd/systemd-$(SYSTEMD_VER)/rules.d/50-udev-default.rules.in
	cd tmp/systemd/bld && LANG=en_US.UTF-8 meson $(SYSTEMD_MOPT2) ../systemd-$(SYSTEMD_VER)/
	cd tmp/systemd/bld && LANG=en_US.UTF-8 ninja $(SYSTEMD_BUILD_VERB)
	cd tmp/systemd/bld && LANG=en_US.UTF-8 DESTDIR=`pwd`/../ins ninja install
	mv -fv tmp/systemd/ins/bin/* tmp/systemd/ins/usr/bin/
	rm -fr tmp/systemd/ins/bin
	mkdir -p tmp/systemd/ins/usr/sbin
	mv -fv tmp/systemd/ins/sbin/* tmp/systemd/ins/usr/sbin/
	rm -fr tmp/systemd/ins/sbin
	cd tmp/systemd/ins/usr/sbin && ln -fs ../bin/resolvectl resolvconf
	cp -far tmp/systemd/ins/lib/* tmp/systemd/ins/usr/lib/
	rm -fr tmp/systemd/ins/lib
	rm -f  tmp/systemd/ins/var/log/README
	rm -f  tmp/systemd/ins/etc/init.d/README
	rm -fr tmp/systemd/ins/usr/share/doc
	rm -fr tmp/systemd/ins/usr/share/locale
ifeq ($(BUILD_STRIP),y)
	cd tmp/systemd/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/systemd/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/systemd
	touch /etc/environment
	rm -fv /usr/bin/xsltproc
	systemd-machine-id-setup
	systemctl preset-all
	systemctl disable systemd-time-wait-sync.service
	rm -fv /usr/lib/sysctl.d/50-pid-max.conf 
tgt-systemd: pkg2/systemd-$(SYSTEMD_VER).cpio.zst

# LFS-10.0-systemd :: 8.71. D-Bus-1.12.20
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/dbus.html
# BUILD_TIME :: 52s
DBUS_OPT2+= --prefix=/usr
DBUS_OPT2+= --sysconfdir=/etc
DBUS_OPT2+= --localstatedir=/var
DBUS_OPT2+= --disable-static
DBUS_OPT2+= --disable-doxygen-docs
DBUS_OPT2+= --disable-xml-docs
DBUS_OPT2+= --docdir=/usr/share/doc/dbus-$(DBUS_VER)
DBUS_OPT2+= --with-console-auth-dir=/run/console
DBUS_OPT2+= $(OPT_FLAGS)
pkg2/dbus-$(DBUS_VER).cpio.zst: pkg2/systemd-$(SYSTEMD_VER).cpio.zst
	rm -fr tmp/dbus
	mkdir -p tmp/dbus/bld
	tar -xzf src/dbus-$(DBUS_VER).tar.gz -C tmp/dbus
	cd tmp/dbus/bld && ../dbus-$(DBUS_VER)/configure $(DBUS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/dbus/ins/lib/* tmp/dbus/ins/usr/lib/
	rm -fr tmp/dbus/ins/lib
	rm -fr tmp/dbus/ins/usr/share/doc
	rm -f  tmp/dbus/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	cd tmp/dbus/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	sed -i 's:/var/run:/run:' tmp/dbus/ins/usr/lib/systemd/system/dbus.socket
	mv -f tmp/dbus/ins/var/run tmp/dbus/ins/
	cd tmp/dbus/ins/var/lib/dbus && ln -sf /etc/machine-id machine-id
	cd tmp/dbus/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/dbus
tgt-dbus: pkg2/dbus-$(DBUS_VER).cpio.zst

# LFS-10.0-systemd :: 8.72. Procps-ng-3.3.16
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/procps-ng.html
# BUILD_TIME :: 29s
# BUILD_TIME_WITH_TEST ::
PROCPS_OPT2+= --prefix=/usr
PROCPS_OPT2+= --exec-prefix=
PROCPS_OPT2+= --libdir=/usr/lib
PROCPS_OPT2+= --docdir=/usr/share/doc/procps-ng-$(PROCPS_VER)
PROCPS_OPT2+= --disable-static
PROCPS_OPT2+= --disable-kill
PROCPS_OPT2+= --with-systemd
PROCPS_OPT2+= --disable-nls
PROCPS_OPT2+= $(OPT_FLAGS)
pkg2/procps-ng-$(PROCPS_VER).cpio.zst: pkg2/dbus-$(DBUS_VER).cpio.zst
	rm -fr tmp/procps-ng
	mkdir -p tmp/procps-ng/bld
	tar -xJf src/procps-ng-$(PROCPS_VER).tar.xz -C tmp/procps-ng
	cd tmp/procps-ng/bld && ../procps-ng-$(PROCPS_VER)/configure $(PROCPS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	mv -f tmp/procps-ng/ins/bin tmp/procps-ng/ins/usr/
	mv -f tmp/procps-ng/ins/sbin tmp/procps-ng/ins/usr/
	rm -fr tmp/procps-ng/ins/usr/share
	rm -f  tmp/procps-ng/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/procps-ng/ins/usr/bin/* || true
	strip --strip-unneeded tmp/procps-ng/ins/usr/sbin/* || true
	strip --strip-unneeded tmp/procps-ng/ins/usr/lib/*.so*
endif
	cd tmp/procps-ng/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/procps-ng/bld && make check 2>&1 | tee ../../../tst/procps-ng-check.log || true
#============================================================================
#Testsuite summary for procps-ng 3.3.16
#============================================================================
# TOTAL: 1
# PASS:  1
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/procps-ng
tgt-procps-ng: pkg2/procps-ng-$(PROCPS_VER).cpio.zst

# LFS-10.0-systemd :: 8.73. Util-linux-2.36
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/util-linux.html
# BUILD_TIME :: 1m 28s
# BUILD_TIME_WITH_TEST :: 2m 34s
UTILLINUX_OPT2+= ADJTIME_PATH=/var/lib/hwclock/adjtime
UTILLINUX_OPT2+= --docdir=/usr/share/doc/util-linux-$(UTIL_LINUX_VER)
UTILLINUX_OPT2+= --disable-chfn-chsh
UTILLINUX_OPT2+= --disable-login
UTILLINUX_OPT2+= --disable-nologin
UTILLINUX_OPT2+= --disable-su
UTILLINUX_OPT2+= --disable-setpriv
UTILLINUX_OPT2+= --disable-runuser
UTILLINUX_OPT2+= --disable-pylibmount
UTILLINUX_OPT2+= --disable-static
UTILLINUX_OPT2+= --without-python
UTILLINUX_OPT2+= --disable-nls
UTILLINUX_OPT2+= $(OPT_FLAGS)
pkg2/util-linux-$(UTIL_LINUX_VER).cpio.zst: pkg2/procps-ng-$(PROCPS_VER).cpio.zst
	rm -fr tmp/util-linux
	mkdir -p tmp/util-linux/bld
	tar -xJf src/util-linux-$(UTIL_LINUX_VER).tar.xz -C tmp/util-linux
	mkdir -p /var/lib/hwclock
	cd tmp/util-linux/bld && ../util-linux-$(UTIL_LINUX_VER)/configure $(UTILLINUX_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/util-linux/ins/bin/* tmp/util-linux/ins/usr/bin/
	cp -far tmp/util-linux/ins/sbin/* tmp/util-linux/ins/usr/sbin/
	cp -far tmp/util-linux/ins/lib/* tmp/util-linux/ins/usr/lib/
	rm -fr tmp/util-linux/ins/bin
	rm -fr tmp/util-linux/ins/lib
	rm -fr tmp/util-linux/ins/sbin
	rm -fr tmp/util-linux/ins/usr/share/doc
	rm -fr tmp/util-linux/ins/usr/share/man
	rm -f  tmp/util-linux/ins/usr/lib/*.la
	cd tmp/util-linux/ins/usr/lib && ln -sfv libblkid.so.1.1.0 libblkid.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libfdisk.so.1.1.0 libfdisk.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libmount.so.1.1.0 libmount.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libsmartcols.so.1.1.0 libsmartcols.so
	cd tmp/util-linux/ins/usr/lib && ln -sfv libuuid.so.1.3.0 libuuid.so
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/util-linux/ins/usr/bin/* || true
	strip --strip-unneeded tmp/util-linux/ins/usr/sbin/* || true
	strip --strip-unneeded tmp/util-linux/ins/usr/lib/*.so*
endif
	cd tmp/util-linux/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	chown -Rv tester tmp/util-linux/bld
#	mkdir -p tst && cd tmp/util-linux/bld && su tester -c "make -k check"
#---------------------------------------------------------------------
#  All 207 tests PASSED
#---------------------------------------------------------------------
#endif
	rm -fr tmp/util-linux
tgt-util-linux: pkg2/util-linux-$(UTIL_LINUX_VER).cpio.zst

# LFS-10.0-systemd :: 8.74. E2fsprogs-1.45.6
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/e2fsprogs.html
# BUILD_TIME :: 1m 3s
# BUILD_TIME_WITH_TEST :: 4m 30s
E2FSPROGS_OPT2+= --prefix=/usr
E2FSPROGS_OPT2+= --bindir=/usr/bin
E2FSPROGS_OPT2+= --libdir=/usr/lib
E2FSPROGS_OPT2+= --sbindir=/usr/sbin
E2FSPROGS_OPT2+= --with-root-prefix=""
E2FSPROGS_OPT2+= --enable-elf-shlibs
E2FSPROGS_OPT2+= --disable-libblkid
E2FSPROGS_OPT2+= --disable-libuuid
E2FSPROGS_OPT2+= --disable-uuidd
E2FSPROGS_OPT2+= --disable-fsck
E2FSPROGS_OPT2+= --disable-nls
E2FSPROGS_OPT2+= $(OPT_FLAGS)
pkg2/e2fsprogs-$(E2FSPROGS_VER).cpio.zst: pkg2/util-linux-$(UTIL_LINUX_VER).cpio.zst
	rm -fr tmp/e2fsprogs
	mkdir -p tmp/e2fsprogs/bld
	tar -xzf src/e2fsprogs-$(E2FSPROGS_VER).tar.gz -C tmp/e2fsprogs
	cd tmp/e2fsprogs/bld && ../e2fsprogs-$(E2FSPROGS_VER)/configure $(E2FSPROGS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	cp -far tmp/e2fsprogs/ins/lib/* tmp/e2fsprogs/ins/usr/lib/
	rm -fr tmp/e2fsprogs/ins/lib
	rm -fr tmp/e2fsprogs/ins/usr/share/info
	rm -fr tmp/e2fsprogs/ins/usr/share/man
	chmod -v u+w tmp/e2fsprogs/ins/usr/lib/*.a
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/e2fsprogs/ins/usr/bin/* || true
	strip --strip-unneeded tmp/e2fsprogs/ins/usr/sbin/* || true
	strip --strip-debug    tmp/e2fsprogs/ins/usr/lib/*.a
	strip --strip-unneeded tmp/e2fsprogs/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/e2fsprogs/ins/usr/lib/e2initrd_helper
endif
	cd tmp/e2fsprogs/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/e2fsprogs/bld && make check 2>&1 | tee ../../../tst/e2fsprogs-check.log || true
# 357 tests succeeded	0 tests failed
#endif
	rm -fr tmp/e2fsprogs
tgt-e2fsprogs: pkg2/e2fsprogs-$(E2FSPROGS_VER).cpio.zst

# extra BLFS-10.0-systemd ::dosfstools-4.1
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/postlfs/dosfstools.html
# BUILD_TIME :: 8s
DOS_FS_TOOLS_OPT2+= --prefix=/usr
DOS_FS_TOOLS_OPT2+= --enable-compat-symlinks
DOS_FS_TOOLS_OPT2+= --mandir=/usr/share/man
DOS_FS_TOOLS_OPT2+= --docdir=/usr/share/doc/dosfstools-$(DOS_FS_TOOLS_VER)
DOS_FS_TOOLS_OPT2+= $(OPT_FLAGS)
pkg2/dosfstools-$(DOS_FS_TOOLS_VER).cpio.zst: pkg2/e2fsprogs-$(E2FSPROGS_VER).cpio.zst
	rm -fr tmp/dosfstools
	mkdir -p tmp/dosfstools/bld
	tar -xJf src/dosfstools-$(DOS_FS_TOOLS_VER).tar.xz -C tmp/dosfstools
	cd tmp/dosfstools/bld && ../dosfstools-$(DOS_FS_TOOLS_VER)/configure $(DOS_FS_TOOLS_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/dosfstools/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/dosfstools/ins/usr/sbin/* || true
endif
	cd tmp/dosfstools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/dosfstools
tgt-dosfstools: pkg2/dosfstools-$(DOS_FS_TOOLS_VER).cpio.zst

# extra :: microcom-2023.09.0
#
# BUILD_TIME :: 14s
#MICROCOM_OPT2+= --prefix=/usr
#MICROCOM_OPT2+= --enable-can
#MICROCOM_OPT2+= $(OPT_FLAGS)
#pkg2/microcom-$(MICROCOM_VER).cpio.zst: pkg2/dosfstools-$(DOS_FS_TOOLS_VER).cpio.zst
#	rm -fr tmp/microcom
#	mkdir -p tmp/microcom/bld
#	tar -xzf src/microcom-$(MICROCOM_VER).tar.gz -C tmp/microcom
#	cd tmp/microcom/microcom-$(MICROCOM_VER) && autoreconf -i
#	cd tmp/microcom/bld && ../microcom-$(MICROCOM_VER)/configure $(MICROCOM_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/microcom/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/microcom/ins/usr/bin/microcom
#endif
#	cd tmp/microcom/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/microcom
#tgt-microcom: pkg2/microcom-$(MICROCOM_VER).cpio.zst

# extra BLFS-10.0-systemd :: PCRE-8.44
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/pcre.html
# BUILD_TIME :: 33s
# BUILD_TIME_WITH_TEST :: 43s
PCRE_OPT2+= --prefix=/usr
PCRE_OPT2+= --docdir=/usr/share/doc/pcre-$(PCRE_VER)
PCRE_OPT2+= --enable-unicode-properties
PCRE_OPT2+= --enable-pcre16
PCRE_OPT2+= --enable-pcre32
PCRE_OPT2+= --enable-pcregrep-libz
PCRE_OPT2+= --enable-pcregrep-libbz2
PCRE_OPT2+= --enable-pcretest-libreadline
PCRE_OPT2+= --disable-static
PCRE_OPT2+= $(OPT_FLAGS)
pkg2/pcre-$(PCRE_VER).cpio.zst: pkg2/dosfstools-$(DOS_FS_TOOLS_VER).cpio.zst
	rm -fr tmp/pcre
	mkdir -p tmp/pcre/bld
	tar -xzf src/pcre-$(PCRE_VER).tar.gz -C tmp/pcre
	cd tmp/pcre/bld && ../pcre-$(PCRE_VER)/configure $(PCRE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/pcre/ins/usr/share
	rm -f  tmp/pcre/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/pcre/ins/usr/bin/* || true
	strip --strip-unneeded tmp/pcre/ins/usr/lib/*.so*
endif
	cd tmp/pcre/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/pcre/bld && make check 2>&1 | tee ../../../tst/pcre-check.log || true
#============================================================================
#Testsuite summary for PCRE 8.44
#============================================================================
# TOTAL: 5
# PASS:  5
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/pcre
tgt-pcre: pkg2/pcre-$(PCRE_VER).cpio.zst

# extra BLFS-10.0-systemd :: Zip-3.0
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/zip.html
# BUILD_TIME :: 8s
#pkg2/zip$(ZIP_VER0).cpio.zst: pkg2/pcre-$(PCRE_VER).cpio.zst
#	rm -fr tmp/zip
#	mkdir -p tmp/zip
#	tar -xzf src/zip$(ZIP_VER0).tar.gz -C tmp/zip
#	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/zip/zip$(ZIP_VER0)/unix/configure
#	cd tmp/zip/zip$(ZIP_VER0) && make $(JOBS) -f unix/Makefile generic_gcc
#	mkdir -p tmp/zip/ins/usr
#	cd tmp/zip/zip$(ZIP_VER0) && make prefix=../ins/usr MANDIR=../ins/usr/share/man/man1 -f unix/Makefile install
#	rm -fr tmp/zip/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/zip/ins/usr/bin/* || true
#endif
#	cd tmp/zip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/zip
#tgt-zip: pkg2/zip$(ZIP_VER0).cpio.zst

# extra BLFS-10.0-systemd :: UnZip-6.0
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/unzip.html
# BUILD_TIME :: 7s
# WARNING: This unzip has problems with non-latin file-names! See 'Caution' on html-page above.
# Workaround1: Uze WinZip under Wine. -- Looks like terrific! (sarcasm)
# Workaround2: Use 'bsdtar -xf' (from libarchive) for unpack zip-files with convmv-fixing
# Workaround3: Use this UnZip and hope that filenames has no non-latin characters.
#pkg2/unzip$(UNZIP_VER0).cpio.zst: pkg2/zip$(ZIP_VER0).cpio.zst
#	rm -fr tmp/unzip
#	mkdir -p tmp/unzip
#	tar -xzf src/unzip$(UNZIP_VER0).tar.gz -C tmp/unzip
#	cp -f src/unzip-$(UNZIP_VER)-consolidated_fixes-1.patch tmp/unzip/
#	cd tmp/unzip/unzip$(UNZIP_VER0) && patch -Np1 -i ../unzip-$(UNZIP_VER)-consolidated_fixes-1.patch
#	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/unzip/unzip$(UNZIP_VER0)/unix/configure
#	cd tmp/unzip/unzip$(UNZIP_VER0) && make $(JOBS) -f unix/Makefile generic
#	mkdir -p tmp/unzip/ins/usr
#	cd tmp/unzip/unzip$(UNZIP_VER0) && make prefix=../ins/usr MANDIR=../ins/usr/share/man/man1 -f unix/Makefile install
#	rm -fr tmp/unzip/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/unzip/ins/usr/bin/* || true
#endif
#	cd tmp/unzip/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/unzip
#tgt-unzip: pkg2/unzip$(UNZIP_VER0).cpio.zst

# EXTRA: this pkg reccommended on UnZip LFS-page
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/unzip.html
# see ... Workaround2: Use 'bsdtar -xf' (from libarchive) for unpack zip-files with convmv-fixing
#### The following is an example for the zh_CN.UTF-8 locale:
#### convmv -f cp936 -t utf-8 -r --nosmart --notest </path/to/unzipped/files>
# BUILD_TIME :: 0s
#pkg2/convmv-$(CONVMV_VER).cpio.zst: pkg2/unzip$(UNZIP_VER0).cpio.zst
#	rm -fr tmp/convmv
#	mkdir -p tmp/convmv
#	tar -xzf src/convmv-$(CONVMV_VER).tar.gz -C tmp/convmv
#	mkdir -p tmp/convmv/ins/usr/bin
#	cp -f tmp/convmv/convmv-$(CONVMV_VER)/convmv tmp/convmv/ins/usr/bin
#	chown root:root tmp/convmv/ins/usr/bin/convmv
# Target is the single PERL file!
#	cd tmp/convmv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/convmv
#tgt-convmv: pkg2/convmv-$(CONVMV_VER).cpio.zst

# extra BLFS-10.0-systemd :: libarchive-3.4.3
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libarchive.html
# BUILD_TIME :: 1m 21s
# BUILD_TIME_WITH_TEST :: 
#LIBARCHIVE_OPT2+= --prefix=/usr
#LIBARCHIVE_OPT2+= --disable-static
#LIBARCHIVE_OPT2+= $(OPT_FLAGS)
#pkg2/libarchive-$(LIBARCHIVE_VER).cpio.zst: pkg2/convmv-$(CONVMV_VER).cpio.zst
#	rm -fr tmp/libarchive
#	mkdir -p tmp/libarchive/bld
#	tar -xJf src/libarchive-$(LIBARCHIVE_VER).tar.xz -C tmp/libarchive
#	cp -f src/libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch tmp/libarchive
#	cd tmp/libarchive/libarchive-$(LIBARCHIVE_VER) && patch -Np1 -i ../libarchive-$(LIBARCHIVE_VER)-testsuite_fix-1.patch
#	cd tmp/libarchive/bld && ../libarchive-$(LIBARCHIVE_VER)/configure $(LIBARCHIVE_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/libarchive/ins/usr/share
#	rm -f  tmp/libarchive/ins/usr/lib/*.la
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/libarchive/ins/usr/bin/* || true
#	strip --strip-unneeded tmp/libarchive/ins/usr/lib/*.so*
#endif
#	cd tmp/libarchive/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/libarchive/bld && LC_ALL=C make check 2>&1 | tee ../../../tst/libarchive-check.log || true
#============================================================================
#Testsuite summary for libarchive 3.4.3
#============================================================================
# TOTAL: 4
# PASS:  4
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
#	rm -fr tmp/libarchive
#tgt-libarchive: pkg2/libarchive-$(LIBARCHIVE_VER).cpio.zst

# extra BLFS-10.0-systemd :: SWIG-4.0.2
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/swig.html
# BUILD_TIME :: 48s
# BUILD_TIME_WITH_TEST :: 52m 15s (perl5, python, tcl)
SWIG_OPT2+= --prefix=/usr
SWIG_OPT2+= --without-maximum-compile-warnings
SWIG_OPT2+= $(OPT_FLAGS)
pkg2/swig-$(SWIG_VER).cpio.zst: pkg2/pcre-$(PCRE_VER).cpio.zst
	rm -fr tmp/swig
	mkdir -p tmp/swig/bld
	tar -xzf src/swig-$(SWIG_VER).tar.gz -C tmp/swig
	cd tmp/swig/bld && ../swig-$(SWIG_VER)/configure $(SWIG_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/swig/ins/usr/bin/* || true
endif
	cd tmp/swig/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	cd tmp/swig/bld && PY3=1 make -k check TCL_INCLUDE= || true
#make[3]: Leaving directory '/opt/mysdk/tmp/swig/bld/Examples/test-suite/python'
#make[2]: Target 'check' not remade because of errors.
#make[2]: Leaving directory '/opt/mysdk/tmp/swig/bld/Examples/test-suite/python'
#make[1]: *** [Makefile:241: check-python-test-suite] Error 1
#endif
	rm -fr tmp/swig
tgt-swig: pkg2/swig-$(SWIG_VER).cpio.zst

###############################################################################
# THIS POINT IS: 180m 50s ( 3h )
###############################################################################

# extra BLFS-10.0-systemd :: Popt-1.18
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/popt.html
# BUILD_TIME :: 13s
# BUILD_TIME_WITH_TEST ::
POPT_OPT2+= --prefix=/usr
POPT_OPT2+= --disable-static
POPT_OPT2+= --disable-nls
POPT_OPT2+= $(OPT_FLAGS)
pkg2/popt-$(POPT_VER).cpio.zst: pkg2/swig-$(SWIG_VER).cpio.zst
	rm -fr tmp/popt
	mkdir -p tmp/popt/bld
	tar -xzf src/popt-$(POPT_VER).tar.gz -C tmp/popt
	cd tmp/popt/bld && ../popt-$(POPT_VER)/configure $(POPT_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/popt/ins/usr/share
	rm -f tmp/popt/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/popt/ins/usr/lib/*.so*
endif
	cd tmp/popt/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/popt/bld && make check 2>&1 | tee ../../../tst/popt-check.log || true
#============================================================================
#Testsuite summary for popt 1.18
#============================================================================
# TOTAL: 1
# PASS:  1
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
#endif
	rm -fr tmp/popt
tgt-popt: pkg2/popt-$(POPT_VER).cpio.zst

# extra BLFS-10.0-systemd :: rsync-3.2.3
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/basicnet/rsync.html
# BUILD_TIME :: 48s
# BUILD_TIME_WITH_TEST ::
# groupadd -g 48 rsyncd && useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd -s /bin/false -u 48 rsyncd
RSYNC_OPT2+= --prefix=/usr
RSYNC_OPT2+= --disable-lz4
RSYNC_OPT2+= --disable-xxhash
RSYNC_OPT2+= --without-included-zlib
RSYNC_OPT2+= $(OPT_FLAGS)
pkg2/rsync-$(RSYNC_VER).cpio.zst: pkg2/popt-$(POPT_VER).cpio.zst
	rm -fr tmp/rsync
	mkdir -p tmp/rsync/bld
	tar -xzf src/rsync-$(RSYNC_VER).tar.gz -C tmp/rsync
	cd tmp/rsync/bld && ../rsync-$(RSYNC_VER)/configure $(RSYNC_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/rsync/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/rsync/ins/usr/bin/rsync
endif
	cd tmp/rsync/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#ifeq ($(RUN_TESTS),y)
#	mkdir -p tst && cd tmp/rsync/bld && make check 2>&1 | tee ../../../tst/rsync-check.log || true
#----- overall results:
#      40 passed
#      2 skipped
#endif
	rm -fr tmp/rsync
tgt-rsync: pkg2/rsync-$(RSYNC_VER).cpio.zst

# extra BLFS-10.0-systemd :: parted-3.3
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/postlfs/parted.html
# BUILD_TIME :: 1m 13s
# BUILD_TIME_WITH_TEST ::
PARTED_OPT2+= --prefix=/usr
PARTED_OPT2+= --disable-static
PARTED_OPT2+= --disable-nls
PARTED_OPT2+= --disable-device-mapper
PARTED_OPT2+= $(OPT_FLAGS)
pkg2/parted-$(PARTED_VER).cpio.zst: pkg2/rsync-$(RSYNC_VER).cpio.zst
	rm -fr tmp/parted
	mkdir -p tmp/parted/bld
	tar -xJf src/parted-$(PARTED_VER).tar.xz -C tmp/parted
	cd tmp/parted/bld && ../parted-$(PARTED_VER)/configure $(PARTED_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/parted/ins/usr/share
	rm -f  tmp/parted/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/parted/ins/usr/sbin/*
	strip --strip-unneeded tmp/parted/ins/usr/lib/*.so*
endif
	cd tmp/parted/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/parted
tgt-parted: pkg2/parted-$(PARTED_VER).cpio.zst

pkg2/ldd.cpio.zst: pkg2/parted-$(PARTED_VER).cpio.zst
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
	cd tmp/ldd && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../$@
	rm -fr tmp/ldd
tgt-ldd: pkg2/ldd.cpio.zst

# extra:: DTC (for uboot-xunlong)
# https://www.linuxfromscratch.org/blfs/view/svn/general/dtc.html
# BUILD_TIME :: 14s
DTC_MOPT2+= --prefix=/usr
DTC_MOPT2+= -Dpython=disabled
#DTC_MOPT2+= --buildtype=release
DTC_MOPT2+= -Ddebug=false
DTC_MOPT2+= -Doptimization=$(BASE_OPT_VAL)
DTC_MOPT2+= -Dc_args="$(RK3588_FLAGS)"
DTC_MOPT2+= -Dcpp_args="$(RK3588_FLAGS)"
DTC_BUILD_VERB=
ifeq ($(VERB),1)
DTC_BUILD_VERB=-v
endif
pkg2/dtc-$(DTC_VER).cpio.zst: pkg2/ldd.cpio.zst
	rm -fr tmp/dtc
	mkdir -p tmp/dtc/bld
	tar -xzf src/dtc-$(DTC_VER).tar.gz -C tmp/dtc
	cd tmp/dtc/bld && LANG=en_US.UTF-8 meson setup $(DTC_MOPT2) ../dtc-$(DTC_VER)
	cd tmp/dtc/bld && LANG=en_US.UTF-8 ninja $(DTC_BUILD_VERB)
	cd tmp/dtc/bld && LANG=en_US.UTF-8 DESTDIR=`pwd`/../ins ninja install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/dtc/ins/usr/bin/* || true
	strip --strip-unneeded tmp/dtc/ins/usr/lib/*.so*
	strip --strip-debug tmp/dtc/ins/usr/lib/*.a
endif
	cd tmp/dtc/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	cp -far tmp/dtc/ins/usr/lib/*.so* /usr/lib/
	cp -far tmp/dtc/ins/usr/bin/dtc /usr/bin/
	rm -fr tmp/dtc
tgt-dtc: pkg2/dtc-$(DTC_VER).cpio.zst

# extra blfs :: Wget-1.20.3
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/basicnet/wget.html
# BUILD_TIME :: 1m 20s
WGET_OPT2+= --prefix=/usr
WGET_OPT2+= --sysconfdir=/etc
WGET_OPT2+= --with-ssl=openssl
WGET_OPT2+= --disable-nls
WGET_OPT2+= $(OPT_FLAGS)
pkg2/wget-$(WGET_VER).cpio.zst: pkg2/dtc-$(DTC_VER).cpio.zst
	rm -fr tmp/wget
	mkdir -p tmp/wget/bld
	tar -xzf src/wget-$(WGET_VER).tar.gz -C tmp/wget
	cd tmp/wget/bld && ../wget-$(WGET_VER)/configure $(WGET_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/wget/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/wget/ins/usr/bin/wget
endif
	cd tmp/wget/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/wget
tgt-wget: pkg2/wget-$(WGET_VER).cpio.zst

# extra blfs :: libusb-1.0.23
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libusb.html
# BUILD_TIME :: 17s
LIBUSB_OPT2+= --prefix=/usr
LIBUSB_OPT2+= --disable-static
LIBUSB_OPT2+= $(OPT_FLAGS)
pkg2/libusb-$(LIBUSB_VER).cpio.zst: pkg2/wget-$(WGET_VER).cpio.zst
	rm -fr tmp/libusb
	mkdir -p tmp/libusb/bld
	tar -xjf src/libusb-$(LIBUSB_VER).tar.bz2 -C tmp/libusb
	sed -i "s/^PROJECT_LOGO/#&/" tmp/libusb/libusb-$(LIBUSB_VER)/doc/doxygen.cfg.in
	cd tmp/libusb/bld && ../libusb-$(LIBUSB_VER)/configure $(LIBUSB_OPT2) && make -j1 V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libusb/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libusb/ins/usr/lib/*.so*
endif
	cd tmp/libusb/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libusb
tgt-libusb: pkg2/libusb-$(LIBUSB_VER).cpio.zst

# extra blfs :: usbutils-012
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/usbutils.html
# BUILD_TIME :: 37s
pkg2/usbutils-$(USB_UTILS_VER).cpio.zst: pkg2/libusb-$(LIBUSB_VER).cpio.zst
	rm -fr tmp/usbutils
	mkdir -p tmp/usbutils
	tar -xJf src/usbutils-$(USB_UTILS_VER).tar.xz -C tmp/usbutils
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/usbutils/usbutils-$(USB_UTILS_VER)/autogen.sh
	cd tmp/usbutils/usbutils-$(USB_UTILS_VER) && ./autogen.sh --prefix=/usr --datadir=/usr/share/hwdata && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/usbutils/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/usbutils/ins/usr/bin/* || true
endif
	install -dm755 tmp/usbutils/ins/usr/share/hwdata/
	cat src/usb.ids.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/usbutils/ins/usr/share/hwdata/
	cd tmp/usbutils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/usbutils
tgt-usb-utils: pkg2/usbutils-$(USB_UTILS_VER).cpio.zst

# extra blfs :: libuv-1.38.1
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libuv.html
# BUILD_TIME :: 23s
LIBUV_OPT2+= --prefix=/usr
LIBUV_OPT2+= --disable-static
LIBUV_OPT2+= $(OPT_FLAGS)
pkg2/libuv-$(LIBUV_VER).cpio.zst: pkg2/usbutils-$(USB_UTILS_VER).cpio.zst
	rm -fr tmp/libuv
	mkdir -p tmp/libuv/bld
	tar -xzf src/libuv-$(LIBUV_VER).tar.gz -C tmp/libuv
	cd tmp/libuv/libuv-$(LIBUV_VER) && ./autogen.sh
	cd tmp/libuv/bld && ../libuv-$(LIBUV_VER)/configure $(LIBUV_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/libuv/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libuv/ins/usr/lib/*.so*
endif
	cd tmp/libuv/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libuv
tgt-libuv: pkg2/libuv-$(LIBUV_VER).cpio.zst

# extra blfs :: CMake-3.18.1
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/cmake.html
# BUILD_TIME :: 6m 13s
#CMAKE_BOPT2+= --prefix=/usr
#CMAKE_BOPT2+= --system-libs
#CMAKE_BOPT2+= --mandir=/share/man
#CMAKE_BOPT2+= --no-system-jsoncpp
#CMAKE_BOPT2+= --no-system-librhash
#CMAKE_BOPT2+= --docdir=/share/doc/cmake-$(CMAKE_VER)
#CMAKE_BOPT2+= --no-system-curl
#CMAKE_BOPT2+= --no-system-nghttp2
#CMAKE_BOPT2+= --parallel=$(JOB)
#CMAKE_BOPT2+= --verbose
#pkg2/cmake-$(CMAKE_VER).cpio.zst: pkg2/libuv-$(LIBUV_VER).cpio.zst
#	rm -fr tmp/cmake
#	mkdir -p tmp/cmake
#	tar -xzf src/cmake-$(CMAKE_VER).tar.gz -C tmp/cmake
#	sed -i '/"lib64"/s/64//' tmp/cmake/cmake-$(CMAKE_VER)/Modules/GNUInstallDirs.cmake
#	sed -i 's|-O3|$(BASE_OPT_FLAGS)|' tmp/cmake/cmake-$(CMAKE_VER)/Modules/Compiler/GNU.cmake
#	cd tmp/cmake/cmake-$(CMAKE_VER) && ./bootstrap $(CMAKE_BOPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/cmake/ins/usr/share/doc
#	rm -fr tmp/cmake/ins/usr/share/emacs
#	rm -fr tmp/cmake/ins/usr/share/vim
#	rm -fr tmp/cmake/ins/usr/share/cmake-$(CMAKE_VER0)/Help
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/cmake/ins/usr/bin/*
#endif
#	cd tmp/cmake/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/cmake
#tgt-cmake: pkg2/cmake-$(CMAKE_VER).cpio.zst

# extra blfs :: Net-tools-CVS_20101030
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/basicnet/net-tools.html
# BUILD_TIME :: 3s
pkg2/net-tools-CVS_$(NET_TOOLS_VER).cpio.zst: pkg2/libuv-$(LIBUV_VER).cpio.zst
	rm -fr tmp/net-tools
	mkdir -p tmp/net-tools
	tar -xzf src/net-tools-CVS_$(NET_TOOLS_VER).tar.gz -C tmp/net-tools
	cp -far src/net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch tmp/net-tools/
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && patch -Np1 -i ../net-tools-CVS_$(NET_TOOLS_VER)-remove_dups-1.patch
	sed -i '/#include <netinet\/ip.h>/d' tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER)/iptunnel.c
	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER)/Makefile
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && yes "" | make config
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && make $(JOBS)
	cd tmp/net-tools/net-tools-CVS_$(NET_TOOLS_VER) && make BASEDIR=`pwd`/../ins update
	rm -fr tmp/net-tools/ins/usr/share
	mv tmp/net-tools/ins/bin tmp/net-tools/ins/usr/
	mv tmp/net-tools/ins/sbin tmp/net-tools/ins/usr/
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/net-tools/ins/usr/bin/* || true
	strip --strip-unneeded tmp/net-tools/ins/usr/sbin/* || true
endif
	cd tmp/net-tools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/net-tools
tgt-net-tools: pkg2/net-tools-CVS_$(NET_TOOLS_VER).cpio.zst

# extra :: OpenSSH-8.3p1
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/postlfs/openssh.html
# BUILD_TIME :: 1m 28s
#OPENSSH_OPT2+= --prefix=/usr
#OPENSSH_OPT2+= --sysconfdir=/etc/ssh
#OPENSSH_OPT2+= --with-md5-passwords
#OPENSSH_OPT2+= --with-privsep-path=/var/lib/sshd
#OPENSSH_OPT2+= $(OPT_FLAGS)
#pkg2/openssh-$(OPENSSH_VER).cpio.zst: pkg2/net-tools-CVS_$(NET_TOOLS_VER).cpio.zst
#	rm -fr tmp/openssh
#	mkdir -p tmp/openssh/bld
#	tar -xzf src/openssh-$(OPENSSH_VER).tar.gz -C tmp/openssh
#	cd tmp/openssh/bld && ../openssh-$(OPENSSH_VER)/configure $(OPENSSH_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#	rm -fr tmp/openssh/ins/usr/share
#ifeq ($(BUILD_STRIP),y)
#	strip --strip-unneeded tmp/openssh/ins/usr/bin/* || true
#	strip --strip-unneeded tmp/openssh/ins/usr/sbin/* || true
#	strip --strip-unneeded tmp/openssh/ins/usr/libexec/* || true
#endif
#	cd tmp/openssh/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#	rm -fr tmp/openssh
#tgt-openssh: pkg2/openssh-$(OPENSSH_VER).cpio.zst
# OpenSSH has been configured with the following options:
#                      User binaries: /usr/bin
#                    System binaries: /usr/sbin
#                Configuration files: /etc/ssh
#                    Askpass program: /usr/libexec/ssh-askpass
#                       Manual pages: /usr/share/man/manX
#                           PID file: /var/run
#   Privilege separation chroot path: /var/lib/sshd
#             sshd default user PATH: /usr/bin:/bin:/usr/sbin:/sbin
#                     Manpage format: doc
#                        PAM support: no
#                    OSF SIA support: no
#                  KerberosV support: no
#                    SELinux support: no
#               MD5 password support: yes
#                    libedit support: no
#                    libldns support: no
#   Solaris process contract support: no
#            Solaris project support: no
#          Solaris privilege support: no
#        IP address in $DISPLAY hack: no
#            Translate v4 in v6 hack: yes
#                   BSD Auth support: no
#               Random number source: OpenSSL internal ONLY
#              Privsep sandbox style: seccomp_filter
#                    PKCS#11 support: yes
#                   U2F/FIDO support: yes
# 
#               Host: aarch64-unknown-linux-gnu
#           Compiler: cc
#     Compiler flags: -mcpu=cortex-a76.cortex-a55+crypto -Os -pipe -Wno-error=format-truncation -Wall -Wpointer-arith -Wuninitialized -Wsign-compare -Wformat-security -Wsizeof-pointer-memaccess -Wno-pointer-sign -Wno-unused-result -Wimplicit-fallthrough -fno-strict-aliasing -D_FORTIFY_SOURCE=2 -ftrapv -fno-builtin-memset -fstack-protector-strong -fPIE  
# Preprocessor flags: -mcpu=cortex-a76.cortex-a55+crypto -Os -D_XOPEN_SOURCE=600 -D_BSD_SOURCE -D_DEFAULT_SOURCE
#       Linker flags:  -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -fstack-protector-strong -pie 
#          Libraries: -lcrypto -ldl -lutil -lz  -lcrypt -lresolv




# RKDEVELOPTOOL
# https://github.com/PJK/libcbor
# BUILD_TIME :: 10s
pkg2/rkdeveloptool.cpio.zst: pkg2/net-tools-CVS_$(NET_TOOLS_VER).cpio.zst
	rm -fr tmp/rkdeveloptool
	mkdir -p tmp/rkdeveloptool/src
	mkdir -p tmp/rkdeveloptool/bld
	cat src/rkdeveloptool.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/rkdeveloptool/src
	cd tmp/rkdeveloptool/src && autoreconf -i
	cd tmp/rkdeveloptool/bld && ../src/configure --prefix=/usr CXXFLAGS="$(BASE_OPT_FLAGS)" && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/rkdeveloptool/ins/usr/bin/*
endif
	cd tmp/rkdeveloptool/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/rkdeveloptool
tgt-rkdeveloptool: pkg2/rkdeveloptool.cpio.zst

# UBOOT-TOOLS(mkimage)
# BUILD_TIME :: 25s
pkg2/uboot-tools.cpio.zst: pkg2/rkdeveloptool.cpio.zst
	cat pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/uboot-tools
	mkdir -p tmp/uboot-tools/uboot-$(UBOOT_VER)
	cat src/uboot-$(UBOOT_VER).src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot-tools/uboot-$(UBOOT_VER)
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/uboot-tools/uboot-$(UBOOT_VER)/Makefile
	sed -i "s/-march=armv8-a+crc/$(RK3588_FLAGS)/" tmp/uboot-tools/uboot-$(UBOOT_VER)/arch/arm/Makefile
	mkdir -p tmp/uboot-tools/bld
	cd tmp/uboot-tools/uboot-$(UBOOT_VER) && make V=$(VERB) O=../bld orangepi-5-plus-rk3588_defconfig
	cd tmp/uboot-tools/bld && make V=$(VERB) $(JOBS) tools
	mkdir -p tmp/uboot-tools/ins/usr/bin
	cp -f tmp/uboot-tools/bld/tools/dumpimage       tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/fdt_add_pubkey  tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/fdtgrep         tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/fit_check_sign  tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/fit_info        tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/gen_eth_addr    tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/gen_ethaddr_crc tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/img2srec        tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/mkenvimage      tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/mkimage         tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/proftool        tmp/uboot-tools/ins/usr/bin/
	cp -f tmp/uboot-tools/bld/tools/relocate-rela   tmp/uboot-tools/ins/usr/bin/
#	cp -f tmp/uboot-tools/bld/tools/spl_size_limit  tmp/uboot-tools/ins/usr/bin/
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/uboot-tools/ins/usr/bin/*
endif
	cd tmp/uboot-tools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	mkdir -p /usr/bin && cp -f tmp/uboot-tools/ins/usr/bin/mkimage /usr/bin/
	rm -fr tmp/uboot-tools
tgt-uboot-tools: pkg2/uboot-tools.cpio.zst

# Linux Out-Of-Src-Tree-BUILD :: Original from Orangepi :: Linux 5.10.110
# BUILD_TIME :: 48m
pkg2/kernel.5.10.110.xunlong.cpio.zst: pkg2/uboot-tools.cpio.zst
	rm -fr tmp/opi5-linux
	mkdir -p tmp/opi5-linux/src
	mkdir -p tmp/opi5-linux/bld
	cat src/orangepi5-linux510.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/opi5-linux/src
	find tmp/opi5-linux/src -name "Makefile" -exec sed -i "s/-O2/$(BASE_OPT_FLAGS)/" {} +
	find tmp/opi5-linux/src -name "Makefile" -exec sed -i "s/-O3/$(BASE_OPT_VALUE)/" {} +
#	find tmp/opi5-linux/src -name "Makefile.config" -exec sed -i "s/-O2/$(BASE_OPT_FLAGS)/" {} +
	sed -i "s/include \$$(TopDIR)\/drivers\/net\/wireless\/rtl88x2cs\/rtl8822c.mk/include \$$(src)\/rtl8822c.mk/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(BCMDHD_ROOT)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rkwifi\/bcmdhd\/include/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/include/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/core\/crypto/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/common.mk
	sed -i "s/phl_path_d1 := \$$(src)/phl_path_d1 := \$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/phl/phl.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/core\/crypto/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/hal/phydm/phydm.mk
	mkdir -p tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan
	cp -far tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan/
	cd tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan/rtl8852be && find . -name "*.c" -type f -delete
	cp -f cfg/kernel_opi5plus_my_defconfig tmp/opi5-linux/src/arch/arm64/configs/
	cd tmp/opi5-linux/src && make V=$(VERB) O=../bld kernel_opi5plus_my_defconfig
	sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" tmp/opi5-linux/bld/.config
	cd tmp/opi5-linux/bld && make LOCALVERSION= kernelversion > ../kerver.txt
	sed -i '/make/d' tmp/opi5-linux/kerver.txt
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) $(JOBS) KCFLAGS="$(BASE_OPT_FLAGS)" dtbs
	mkdir -p tmp/opi5-linux/ins/usr/share/myboot/boot-fat/dtb
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) INSTALL_DTBS_PATH=../ins/usr/share/myboot/boot-fat/dtb dtbs_install
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) $(JOBS) KCFLAGS="$(BASE_OPT_FLAGS)" Image
	cp -f tmp/opi5-linux/bld/arch/arm64/boot/Image tmp/opi5-linux/ins/usr/share/myboot/boot-fat/
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) $(JOBS) KCFLAGS="$(BASE_OPT_FLAGS)" modules
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) INSTALL_MOD_PATH=../ins/usr modules_install
	rm -fv tmp/opi5-linux/ins/usr/lib/modules/`cat tmp/opi5-linux/kerver.txt`/build
	rm -fv tmp/opi5-linux/ins/usr/lib/modules/`cat tmp/opi5-linux/kerver.txt`/source
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) INSTALL_HDR_PATH=../ins/usr headers_install
	cp -f tmp/opi5-linux/kerver.txt .
	cd tmp/opi5-linux/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/opi5-linux
tgt-linux-kernel: pkg2/kernel.5.10.110.xunlong.cpio.zst

tgt-linux-config:
	rm -fr tmp/opi5-linux
	mkdir -p tmp/opi5-linux/src
	mkdir -p tmp/opi5-linux/bld
	cat src/orangepi5-linux510.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/opi5-linux/src
	sed -i "s/include \$$(TopDIR)\/drivers\/net\/wireless\/rtl88x2cs\/rtl8822c.mk/include \$$(src)\/rtl8822c.mk/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(BCMDHD_ROOT)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rkwifi\/bcmdhd\/include/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/include/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/core\/crypto/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/common.mk
	sed -i "s/phl_path_d1 := \$$(src)/phl_path_d1 := \$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be/" tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be/phl/phl.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189es/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8189fs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8192eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8812au/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8811cu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8188eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2bu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/core\/crypto/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl88x2cs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8723du/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/include/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/platform/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/btc/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/phydm/" tmp/opi5-linux/src/drivers/net/wireless/rtl8822bs/hal/phydm/phydm.mk
	mkdir -p tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan
	cp -far tmp/opi5-linux/src/drivers/net/wireless/rockchip_wlan/rtl8852be tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan/
	cd tmp/opi5-linux/bld/drivers/net/wireless/rockchip_wlan/rtl8852be && find . -name "*.c" -type f -delete
	cp -f cfg/kernel_opi5plus_my_defconfig tmp/opi5-linux/src/arch/arm64/configs/
	cd tmp/opi5-linux/src && make V=$(VERB) O=../bld kernel_opi5plus_my_defconfig
	sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" tmp/opi5-linux/bld/.config
	cd tmp/opi5-linux/bld && make LOCALVERSION= kernelversion > ../kerver.txt
	sed -i '/make/d' tmp/opi5-linux/kerver.txt
	cd tmp/opi5-linux/bld && make LOCALVERSION= V=$(VERB) $(JOBS) KCFLAGS="$(BASE_OPT_FLAGS)" menuconfig

pkg2/kernel-headers.cpio.zst: pkg2/kernel.5.10.110.xunlong.cpio.zst
	rm -fr tmp/kernel
	mkdir -p tmp/kernel
	cat $< | zstd -d | cpio -iduH newc --quiet -D tmp/kernel
	rm -fr tmp/kernel/usr/lib
	rm -fr tmp/kernel/usr/share
	cd tmp/kernel && find . -print0 | cpio -o0H newc --quiet | zstd -z4T9 > ../../$@
	rm -fr tmp/kernel
tgt-headers: pkg2/kernel-headers.cpio.zst

pkg2/kernel-modules.cpio.zst: pkg2/kernel.5.10.110.xunlong.cpio.zst pkg2/kernel-headers.cpio.zst
	rm -fr tmp/kernel
	mkdir -p tmp/kernel
	cat $< | zstd -d | cpio -iduH newc --quiet -D tmp/kernel
	rm -fr tmp/kernel/usr/include
	rm -fr tmp/kernel/usr/share
	cd tmp/kernel && find . -print0 | cpio -o0H newc --quiet | zstd -z4T9 > ../../$@
	rm -fr tmp/kernel
tgt-modules: pkg2/kernel-modules.cpio.zst

# RK3588-BOOTSTRAP
# BUILD_TIME :: 5s
pkg2/rk3588-bootstrap.cpio.zst: pkg2/kernel-modules.cpio.zst
	rm -fr tmp/rk3588-bootstrap
	mkdir -p tmp/rk3588-bootstrap/bins
	cat src/orangepi5-rkbin-only_rk3588.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/rk3588-bootstrap/bins
	mkdir -p tmp/rk3588-bootstrap/ins
	cp -f tmp/rk3588-bootstrap/bins/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin tmp/rk3588-bootstrap/ins/
	cp -f tmp/rk3588-bootstrap/bins/rk3588_bl31_v1.28.elf tmp/rk3588-bootstrap/ins/
	cp -f tmp/rk3588-bootstrap/bins/rk3588_spl_loader_v1.08.111.bin tmp/rk3588-bootstrap/ins/
	mkdir -p tmp/rk3588-bootstrap/atf-src
	cat src/rockchip-rk35-atf.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/rk3588-bootstrap/atf-src
	sed -i "s/ASFLAGS		+=	\$$(march-directive)/ASFLAGS += $(BASE_OPT_FLAGS)/" tmp/rk3588-bootstrap/atf-src/Makefile
	sed -i "s/TF_CFLAGS   +=	\$$(march-directive)/TF_CFLAGS += $(BASE_OPT_FLAGS)/" tmp/rk3588-bootstrap/atf-src/Makefile
	sed -i "s|-O1|$(BASE_OPT_VALUE)|" tmp/rk3588-bootstrap/atf-src/Makefile
	cd tmp/rk3588-bootstrap/atf-src && make V=$(VERB) $(JOBS) PLAT=rk3588 bl31
	cp tmp/rk3588-bootstrap/atf-src/build/rk3588/release/bl31/bl31.elf tmp/rk3588-bootstrap/ins/
	cd tmp/rk3588-bootstrap/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	mkdir -p /usr/share/myboot && cp -f tmp/rk3588-bootstrap/bins/rk3588_spl_loader_v1.08.111.bin /usr/share/myboot/usb-loader.bin
	rm -fr tmp/rk3588-bootstrap
tgt-rk3588-bootstrap: pkg2/rk3588-bootstrap.cpio.zst

# ============== U-BOOT ===============
# +-----------------+-----------------+
# | OLD             | NEW             |
# +-----------------+-----------------+
# | bmp2gray16      |                 |
# | boot_merger     |                 |
# | dumpimage       | dumpimage       |
# |                 | fdt_add_pubkey  |
# | fdtgrep         | fdtgrep         |
# |                 | fit_check_sign  |
# |                 | fit_info        |
# | gen_eth_addr    | gen_eth_addr    |
# | gen_ethaddr_crc | gen_ethaddr_crc |
# |                 | img2srec        |
# | loaderimage     |                 |
# | mkenvimage      | mkenvimage      |
# | mkimage         | mkimage         |
# | proftool        | proftool        |
# | relocate-rela   | relocate-rela   |
# | resource_tool   |                 |
# | trust_merger    |                 |
# +-----------------+-----------------+

# UBOOT -- OFFICIAL
# BUILD_TIME :: 56s
pkg2/uboot-$(UBOOT_VER).cpio.zst: pkg2/rk3588-bootstrap.cpio.zst
	cat pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/uboot
	mkdir -p tmp/uboot/uboot-$(UBOOT_VER)
	cat src/uboot-$(UBOOT_VER).src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot/uboot-$(UBOOT_VER)
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/uboot/uboot-$(UBOOT_VER)/Makefile
	sed -i "s/-march=armv8-a+crc/$(RK3588_FLAGS)/" tmp/uboot/uboot-$(UBOOT_VER)/arch/arm/Makefile
	sed -i 's|#define BOOT_TARGETS	"mmc1 mmc0 nvme scsi usb pxe dhcp spi"|#define BOOT_TARGETS "mmc1 mmc0"|' tmp/uboot/uboot-$(UBOOT_VER)/include/configs/rockchip-common.h
	mkdir -p tmp/uboot/bld
	mkdir -p tmp/uboot/bins
	cat pkg2/rk3588-bootstrap.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot/bins
	cd tmp/uboot/uboot-$(UBOOT_VER) && make V=$(VERB) O=../bld orangepi-5-plus-rk3588_defconfig
	sed -i "s/CONFIG_BOOTDELAY=2/CONFIG_BOOTDELAY=5/" tmp/uboot/bld/.config
	cd tmp/uboot/bld && make V=$(VERB) $(JOBS) ROCKCHIP_TPL=../bins/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin BL31=../bins/bl31.elf
	mkdir -p tmp/uboot/ins/usr/share/myboot
	cp -f tmp/uboot/bld/u-boot-rockchip.bin tmp/uboot/ins/usr/share/myboot/
	cd tmp/uboot/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	mkdir -p /usr/share/myboot && cp -f tmp/uboot/ins/usr/share/myboot/* /usr/share/myboot/
	rm -fr tmp/uboot
tgt-uboot-new: pkg2/uboot-$(UBOOT_VER).cpio.zst

flash-uboot-new: pkg2/rk3588-bootstrap.cpio.zst
	@echo "FLASH Denx U-BOOT to EMMC"
	@echo "Connect usb-target, enter in maskrom, and press ENTER to continue"
	@read line
	rkdeveloptool db /usr/share/myboot/usb-loader.bin && rkdeveloptool wl 64 /usr/share/myboot/u-boot-rockchip.bin && rkdeveloptool rd

# blfs :: Python-2.7.18 (for xunlong u-boot)
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/python2.html
# BUILD_TIME :: 2m 46s
PYTHON2_OPT2+= --prefix=/usr
PYTHON2_OPT2+= --enable-shared
PYTHON2_OPT2+= --with-system-expat
PYTHON2_OPT2+= --with-system-ffi
PYTHON2_OPT2+= --with-ensurepip=yes
PYTHON2_OPT2+= --enable-unicode=ucs4
PYTHON2_OPT2+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
#$(RK3588_FLAGS)
#$(OPT_FLAGS)
pkg2/python2-$(PYTHON2_VER).cpio.zst: pkg2/uboot-$(UBOOT_VER).cpio.zst
	rm -fr tmp/python2
	mkdir -p tmp/python2/bld
	tar -xJf src/Python-$(PYTHON2_VER).tar.xz -C tmp/python2
	sed -i 's|-O3|$(BASE_OPT_VALUE)|' tmp/python2/Python-$(PYTHON2_VER)/configure
	cd tmp/python2/bld && ../Python-$(PYTHON2_VER)/configure $(PYTHON2_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/python2/ins/usr/share
	chmod -v 755 tmp/python2/ins/usr/lib/libpython2.7.so.1.0
ifeq ($(BUILD_STRIP),y)
	find tmp/python2/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/python2/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
endif
	cd tmp/python2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/python2
tgt-python2: pkg2/python2-$(PYTHON2_VER).cpio.zst

# UBOOT -- XUNLONG
# BUILD_TIME :: 48s
pkg2/uboot-xunlong.cpio.zst: pkg2/python2-$(PYTHON2_VER).cpio.zst
	rm -fr tmp/uboot-xunlong
	mkdir -p tmp/uboot-xunlong/src
	cat src/orangepi5-uboot.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot-xunlong/src
	sed -i "s/-march=armv8-a+nosimd/$(RK3588_FLAGS)/" tmp/uboot-xunlong/src/arch/arm/Makefile
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/uboot-xunlong/src/Makefile
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5b_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5_plus_defconfig
# If USB removed -- begin
	sed -i "s/obj-\$$(CONFIG_USB_OHCI_NEW)/# obj-\$$(CONFIG_USB_OHCI_NEW)/" tmp/uboot-xunlong/src/drivers/usb/host/Makefile
# If USB removed -- end
#	sed -i "s/U-Boot SPL board init/U-Boot SPL my board init/" tmp/uboot-xunlong/src/arch/arm/mach-rockchip/spl.c
	sed -i '8s/source .\//source /' tmp/uboot-xunlong/src/arch/arm/mach-rockchip/make_fit_atf.sh
	sed -i '9s/source .\//source /' tmp/uboot-xunlong/src/arch/arm/mach-rockchip/fit_nodes.sh
	mkdir -p tmp/uboot-xunlong/bld/arch/arm/mach-rockchip
	cp -far --no-preserve=timestamps tmp/uboot-xunlong/src/arch/arm/mach-rockchip/*.py tmp/uboot-xunlong/bld/arch/arm/mach-rockchip
	cp -f cfg/uboot_opi5plus_my_defconfig tmp/uboot-xunlong/src/configs/
	cd tmp/uboot-xunlong/src && make V=$(VERB) O=../bld uboot_opi5plus_my_defconfig
	mkdir -p tmp/uboot-xunlong/bins
	cat pkg2/rk3588-bootstrap.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot-xunlong/bins
	cd tmp/uboot-xunlong/bld && make V=$(VERB) $(JOBS) spl/u-boot-spl.bin BL31=../bins/bl31.elf u-boot.dtb u-boot.itb
	cd tmp/uboot-xunlong && bld/tools/mkimage -n rk3588 -T rksd -d "bins/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin:bld/spl/u-boot-spl.bin" uboot-head.bin
	dd of=tmp/uboot-xunlong/u-boot-xunlong.bin if=/dev/zero bs=1M count=8
# final: 64=head 16384=tail, prepared: 0=head 16320=tail
	dd of=tmp/uboot-xunlong/u-boot-xunlong.bin if=tmp/uboot-xunlong/uboot-head.bin seek=0 conv=notrunc
	dd of=tmp/uboot-xunlong/u-boot-xunlong.bin if=tmp/uboot-xunlong/bld/u-boot.itb seek=16320 conv=notrunc
	mkdir -p tmp/uboot-xunlong/ins/usr/share/myboot
	cp -f tmp/uboot-xunlong/uboot-head.bin tmp/uboot-xunlong/ins/usr/share/myboot/
	cp -f tmp/uboot-xunlong/bld/u-boot.itb tmp/uboot-xunlong/ins/usr/share/myboot/
	cp -f tmp/uboot-xunlong/u-boot-xunlong.bin tmp/uboot-xunlong/ins/usr/share/myboot/
	cd tmp/uboot-xunlong/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/uboot-xunlong
tgt-uboot-old: pkg2/uboot-xunlong.cpio.zst

uboot-cfg:
	rm -fr tmp/uboot-xunlong
	mkdir -p tmp/uboot-xunlong/src
	cat src/orangepi5-uboot.src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/uboot-xunlong/src
	sed -i "s/-march=armv8-a+nosimd/$(RK3588_FLAGS)/" tmp/uboot-xunlong/src/arch/arm/Makefile
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" tmp/uboot-xunlong/src/Makefile
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5b_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" tmp/uboot-xunlong/src/configs/orangepi_5_plus_defconfig
	sed -i "s/U-Boot SPL board init/U-Boot SPL my board init/" tmp/uboot-xunlong/src/arch/arm/mach-rockchip/spl.c
	sed -i '8s/source .\//source /' tmp/uboot-xunlong/src/arch/arm/mach-rockchip/make_fit_atf.sh
	sed -i '9s/source .\//source /' tmp/uboot-xunlong/src/arch/arm/mach-rockchip/fit_nodes.sh
	mkdir -p tmp/uboot-xunlong/bld/arch/arm/mach-rockchip
	cp -far --no-preserve=timestamps tmp/uboot-xunlong/src/arch/arm/mach-rockchip/*.py tmp/uboot-xunlong/bld/arch/arm/mach-rockchip
	cd tmp/uboot-xunlong/src && make V=$(VERB) O=../bld orangepi_5_plus_defconfig


flash-uboot-old: pkg2/uboot-xunlong.cpio.zst
	@echo "FLASH Xunlong U-BOOT to EMMC"
	@echo "Connect usb-target, enter in maskrom, and press ENTER to continue"
	@read line
	rkdeveloptool db /usr/share/myboot/usb-loader.bin && rkdeveloptool wl 64 /usr/share/myboot/u-boot-xunlong.bin && rkdeveloptool rd

flash-uboot: flash-uboot-old

pkg2/boot-scr.cpio.zst: pkg2/uboot-xunlong.cpio.zst
	rm -fr tmp/boot-scr
	mkdir -p tmp/boot-scr/src
	echo 'setenv load_addr "0x9000000"' > tmp/boot-scr/src/boot.cmd
	echo 'setenv overlay_error "false"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv rootdev "/dev/mmcblk0p1"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv verbosity "1"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv console "display"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv console "serial"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv console "both"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv bootlogo "false"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv rootfstype "ext4"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv docker_optimizations "on"' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv earlycon "off"' >> tmp/boot-scr/src/boot.cmd
	echo 'echo "Boot script loaded from $${devtype} $${devnum}"' >> tmp/boot-scr/src/boot.cmd
	echo 'if test -e $${devtype} $${devnum} $${prefix}orangepiEnv.txt; then' >> tmp/boot-scr/src/boot.cmd
	echo '	load $${devtype} $${devnum} $${load_addr} $${prefix}orangepiEnv.txt' >> tmp/boot-scr/src/boot.cmd
	echo '	env import -t $${load_addr} $${filesize}' >> tmp/boot-scr/src/boot.cmd
	echo 'fi' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${logo}" = "disabled"; then setenv logo "logo.nologo"; fi' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${console}" = "display" || test "$${console}" = "both"; then setenv consoleargs "console=tty1"; fi' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${console}" = "serial" || test "$${console}" = "both"; then setenv consoleargs "console=ttyS2,1500000 $${consoleargs}"; fi' >> tmp/boot-scr/src/boot.cmd
#	echo 'setenv consoleargs "console=/dev/tty1 $${consoleargs}"' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${earlycon}" = "on"; then setenv consoleargs "earlycon $${consoleargs}"; fi' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${bootlogo}" = "true"; then' >> tmp/boot-scr/src/boot.cmd
	echo '        setenv consoleargs "splash plymouth.ignore-serial-consoles $${consoleargs}"' >> tmp/boot-scr/src/boot.cmd
	echo 'else' >> tmp/boot-scr/src/boot.cmd
	echo '        setenv consoleargs "splash=verbose $${consoleargs}"' >> tmp/boot-scr/src/boot.cmd
	echo 'fi' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${devtype}" = "mmc"; then part uuid mmc $${devnum}:1 partuuid; fi' >> tmp/boot-scr/src/boot.cmd
	echo 'setenv bootargs "root=$${rootdev} rootfstype=$${rootfstype} $${consoleargs} myboot=$${devnum} consoleblank=0 loglevel=$${verbosity} ubootpart=$${partuuid} $${extraargs} $${extraboardargs}"' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${docker_optimizations}" = "on"; then setenv bootargs "$${bootargs} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1"; fi' >> tmp/boot-scr/src/boot.cmd
	echo 'load $${devtype} $${devnum} $${ramdisk_addr_r} $${prefix}uInitrd' >> tmp/boot-scr/src/boot.cmd
	echo 'load $${devtype} $${devnum} $${kernel_addr_r} $${prefix}Image' >> tmp/boot-scr/src/boot.cmd
	echo 'load $${devtype} $${devnum} $${fdt_addr_r} $${prefix}dtb/$${fdtfile}' >> tmp/boot-scr/src/boot.cmd
	echo 'fdt addr $${fdt_addr_r}' >> tmp/boot-scr/src/boot.cmd
	echo 'fdt resize 65536' >> tmp/boot-scr/src/boot.cmd
	echo 'for overlay_file in $${overlays}; do' >> tmp/boot-scr/src/boot.cmd
	echo '	if load $${devtype} $${devnum} $${load_addr} $${prefix}dtb/rockchip/overlay/$${overlay_prefix}-$${overlay_file}.dtbo; then' >> tmp/boot-scr/src/boot.cmd
	echo '		echo "Applying kernel provided DT overlay $${overlay_prefix}-$${overlay_file}.dtbo"' >> tmp/boot-scr/src/boot.cmd
	echo '		fdt apply $${load_addr} || setenv overlay_error "true"' >> tmp/boot-scr/src/boot.cmd
	echo '	fi' >> tmp/boot-scr/src/boot.cmd
	echo 'done' >> tmp/boot-scr/src/boot.cmd
	echo 'for overlay_file in $${user_overlays}; do' >> tmp/boot-scr/src/boot.cmd
	echo '	if load $${devtype} $${devnum} $${load_addr} $${prefix}overlay-user/$${overlay_file}.dtbo; then' >> tmp/boot-scr/src/boot.cmd
	echo '		echo "Applying user provided DT overlay $${overlay_file}.dtbo"' >> tmp/boot-scr/src/boot.cmd
	echo '		fdt apply $${load_addr} || setenv overlay_error "true"' >> tmp/boot-scr/src/boot.cmd
	echo '	fi' >> tmp/boot-scr/src/boot.cmd
	echo 'done' >> tmp/boot-scr/src/boot.cmd
	echo 'if test "$${overlay_error}" = "true"; then' >> tmp/boot-scr/src/boot.cmd
	echo '	echo "Error applying DT overlays, restoring original DT"' >> tmp/boot-scr/src/boot.cmd
	echo '	load $${devtype} $${devnum} $${fdt_addr_r} $${prefix}dtb/$${fdtfile}' >> tmp/boot-scr/src/boot.cmd
	echo 'else' >> tmp/boot-scr/src/boot.cmd
	echo '	if load $${devtype} $${devnum} $${load_addr} $${prefix}dtb/rockchip/overlay/$${overlay_prefix}-fixup.scr; then' >> tmp/boot-scr/src/boot.cmd
	echo '		echo "Applying kernel provided DT fixup script ($${overlay_prefix}-fixup.scr)"' >> tmp/boot-scr/src/boot.cmd
	echo '		source $${load_addr}' >> tmp/boot-scr/src/boot.cmd
	echo '	fi' >> tmp/boot-scr/src/boot.cmd
	echo '	if test -e $${devtype} $${devnum} $${prefix}fixup.scr; then' >> tmp/boot-scr/src/boot.cmd
	echo '		load $${devtype} $${devnum} $${load_addr} $${prefix}fixup.scr' >> tmp/boot-scr/src/boot.cmd
	echo '		echo "Applying user provided fixup script (fixup.scr)"' >> tmp/boot-scr/src/boot.cmd
	echo '		source $${load_addr}' >> tmp/boot-scr/src/boot.cmd
	echo '	fi' >> tmp/boot-scr/src/boot.cmd
	echo 'fi' >> tmp/boot-scr/src/boot.cmd
	echo 'booti $${kernel_addr_r} $${ramdisk_addr_r} $${fdt_addr_r}' >> tmp/boot-scr/src/boot.cmd
	mkdir -p tmp/boot-scr/ins/usr/share/myboot/boot-fat
	cp -f tmp/boot-scr/src/boot.cmd tmp/boot-scr/ins/usr/share/myboot/boot-fat/
	mkimage -C none -A arm -T script -d tmp/boot-scr/src/boot.cmd tmp/boot-scr/ins/usr/share/myboot/boot-fat/boot.scr
	echo 'verbosity=1' > tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'bootlogo=false' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'extraargs=cma=128M' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'overlay_prefix=rk3588' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'rootdev=UUID=0b9501f8-db3c-4b33-940a-7fce0931dc2c' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'fdtfile=rockchip/rk3588-orangepi-5-plus.dtb' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	echo 'overlays=can0-m0 can1-m0' >> tmp/boot-scr/ins/usr/share/myboot/boot-fat/orangepiEnv.txt
	cd tmp/boot-scr/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/boot-scr
tgt-boot-scr: pkg2/boot-scr.cpio.zst

pkg2/issue.cpio.zst: pkg2/boot-scr.cpio.zst
	rm -fr tmp/issue
	mkdir -p tmp/issue
	echo '#!/bin/sh' > tmp/issue/issue.sh
#	echo 'echo -ne "$(TODAY_CODE)\033[9;0]" > issue' >> tmp/issue/issue.sh
	echo 'echo -ne "\033[9;0]" > issue' >> tmp/issue/issue.sh
	chmod ugo+x tmp/issue/issue.sh
	cd tmp/issue && ./issue.sh
	rm -f tmp/issue/issue.sh
	cd tmp/issue && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../$@
	rm -fr tmp/issue
tgt-issue: pkg2/issue.cpio.zst


pkg2/dbus-min.cpio.zst: pkg2/issue.cpio.zst
	rm -fr tmp/dbus
	mkdir -p tmp/dbus
	cat pkg2/dbus-1.12.20.cpio.zst | zstd -d | cpio -idumH newc -D tmp/dbus
	rm -fr tmp/dbus/usr/include
#	rm -fr tmp/dbus/usr/lib/systemd
	cd tmp/dbus && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../$@
	rm -fr tmp/dbus
tgt-dbus-min: pkg2/dbus-min.cpio.zst

# systemd ExecStart= , what is 'minus' means? I.e. ExecStart=-/bin/bash
# https://unix.stackexchange.com/questions/404199/documentation-of-equals-minus-in-systemd-unit-files

INITRD_GZIP=y
#INITRD_GZIP=n

pkg2/boot-initrd.cpio.zst: pkg2/dbus-min.cpio.zst
	rm -fr tmp/initrd
	mkdir -p tmp/initrd
# system
	mkdir -p tmp/initrd/dev/pts
	mknod -m 600  tmp/initrd/dev/console c 5 1 || true
	mknod -m 666  tmp/initrd/dev/null c 1 3 || true
	mkdir -p      tmp/initrd/root
	mkdir -p      tmp/initrd/proc
	mkdir -p      tmp/initrd/sys
	mkdir -p      tmp/initrd/usr/lib/modules
	mkdir -p      tmp/initrd/usr/local/bin
	mkdir -p      tmp/initrd/usr/local/lib
	mkdir -p      tmp/initrd/usr/local/sbin
	cd tmp/initrd && ln -sf usr/lib lib
	mkdir -p      tmp/initrd/usr/bin
	cd tmp/initrd && ln -sf usr/bin bin
	mkdir -p      tmp/initrd/usr/sbin
	cd tmp/initrd && ln -sf usr/sbin sbin
# --- modules
	cat pkg2/kernel-modules.cpio.zst | zstd -d | cpio -idH newc -D tmp/initrd
# --- glibc
	cp -far /usr/lib/ld-*     tmp/initrd/usr/lib/
	cp -far /usr/lib/libc-*   tmp/initrd/usr/lib/
	cp -far /usr/lib/libc.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libdl-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libdl.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libm-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libm.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libpthread-*   tmp/initrd/usr/lib/
	cp -far /usr/lib/libpthread.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libresolv-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libresolv.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/librt-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/librt.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libcrypt-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libcrypt.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_dns-*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_dns*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_files-*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_files*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_db-*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_db*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libutil-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libutil.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_compat-*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_compat*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_hesiod-*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_hesiod*.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_myhostname.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_mymachines.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_resolve.so* tmp/initrd/usr/lib/
	cp -f /usr/sbin/ldconfig tmp/initrd/usr/sbin/
	mkdir -p tmp/initrd/etc/ld.so.conf.d
	echo '/usr/local/lib' > tmp/initrd/etc/ld.so.conf
	echo '# Add an include directory' >> tmp/initrd/etc/ld.so.conf
	echo 'include /etc/ld.so.conf.d/*.conf' >> tmp/initrd/etc/ld.so.conf
# --- libs
	cp -far /usr/lib/libreadlin*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libhistor*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libcurs*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libncurs*.so* tmp/initrd/usr/lib/
	cd tmp/initrd/usr/lib/ && ln -sf libncursesw.so.6.2 libtinfow.so.6.2
	cd tmp/initrd/usr/lib/ && ln -sf libtinfow.so.6.2 libtinfow.so.6
	cd tmp/initrd/usr/lib/ && ln -sf libtinfow.so.6 libtinfow.so
	cp -far /usr/lib/libz.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/liblzma.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libkmod.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libblkid.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libmount.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libzstd.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libcap.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libattr.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libacl.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libmagic.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libbz2.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libssl.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libcrypto.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libnss_systemd.so* tmp/initrd/usr/lib/
	cp -far /usr/lib/libexpat.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libsystemd.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libparted.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libuuid.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libelf-*.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libelf.*so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libmnl.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libprocps.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libfdisk.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libcrypt.so*  tmp/initrd/usr/lib/
	cp -far /usr/lib/libpcre.so*  tmp/initrd/usr/lib/
# --- apps
	cat pkg2/ldd.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/initrd/usr/bin
	cp -f /usr/bin/bash tmp/initrd/usr/bin/
	cd tmp/initrd/bin && ln -sf bash sh
	cp -f /usr/bin/dmesg tmp/initrd/usr/bin/
	cp -f /usr/bin/cat tmp/initrd/usr/bin/
	cp -f /usr/bin/ls tmp/initrd/usr/bin/
	cp -f /usr/bin/less tmp/initrd/usr/bin/
	cp -f /usr/bin/make tmp/initrd/usr/bin/
	cp -f /usr/bin/cpio tmp/initrd/usr/bin/
	cp -f /usr/bin/find tmp/initrd/usr/bin/
	cp -f /usr/bin/zstd tmp/initrd/usr/bin/
	cp -f /usr/bin/which tmp/initrd/usr/bin/
	cp -f /usr/bin/mount tmp/initrd/usr/bin/
	cp -f /usr/bin/umount tmp/initrd/usr/bin/
	cp -f /usr/bin/dtc tmp/initrd/usr/bin/
	cp -f /usr/bin/mkimage tmp/initrd/usr/bin/
	cp -f /usr/bin/ln tmp/initrd/usr/bin/
	cp -f /usr/bin/df tmp/initrd/usr/bin/
	cp -f /usr/bin/sync tmp/initrd/usr/bin/
	cp -f /usr/bin/nano tmp/initrd/usr/bin/
	cp -fa  /usr/bin/rnano   tmp/initrd/usr/bin/
	mkdir -p tmp/initrd/usr/share/nano
	cp -far /usr/share/nano/* tmp/initrd/usr/share/nano/
	sed -i 's|blue|cyan|' tmp/initrd/usr/share/nano/makefile.nanorc
	cp -f /usr/bin/grep tmp/initrd/usr/bin/
	cp -f /usr/bin/head tmp/initrd/usr/bin/
	cp -f /usr/bin/printenv tmp/initrd/usr/bin/
	cp -f /usr/bin/pstree tmp/initrd/usr/bin/
	cp -f /usr/bin/ps tmp/initrd/usr/bin/
	cp -f /usr/bin/echo tmp/initrd/usr/bin/
	cp -f /usr/bin/mkdir tmp/initrd/usr/bin/
	cp -f /usr/bin/dd tmp/initrd/usr/bin/
	cp -f /usr/bin/find tmp/initrd/usr/bin/
	cp -f /usr/bin/kmod tmp/initrd/usr/bin/
	cp -f /usr/bin/stat tmp/initrd/usr/bin/
#	cp -f /usr/bin/free tmp/initrd/usr/bin/
#	cp -f /usr/sbin/swapon tmp/initrd/usr/bin/
#	cp -f /usr/sbin/swapoff tmp/initrd/usr/bin/
#	cp -f /usr/sbin/swaplabel tmp/initrd/usr/bin/
	cd tmp/initrd/usr/sbin/ && ln -sf ../bin/kmod depmod && ln -sf ../bin/kmod insmod && ln -sf ../bin/kmod lsmod && ln -sf ../bin/kmod modinfo && ln -sf ../bin/kmod modprobe && ln -sf ../bin/kmod rmmod
	cp -f /usr/bin/cp tmp/initrd/usr/bin/
	cp -f /usr/bin/mv tmp/initrd/usr/bin/
	cp -f /usr/bin/rm tmp/initrd/usr/bin/
	cp -f /usr/bin/hexdump tmp/initrd/usr/bin/
	cp -f /usr/sbin/parted tmp/initrd/usr/sbin/
	cp -f /usr/sbin/ip tmp/initrd/usr/sbin/
	cp -f /usr/sbin/agetty tmp/initrd/usr/sbin/
#	cp -f cfg/boot-src.sh tmp/initrd/usr/local/sbin/
#	chmod ugo+x tmp/initrd/usr/local/sbin/boot-src.sh
	cp -f cfg/my-* tmp/initrd/usr/local/sbin/
	chmod ugo+x tmp/initrd/usr/local/sbin/my-*.sh
# --- share
	mkdir -p tmp/initrd/usr/share/terminfo/l
	cp -f /usr/share/terminfo/l/linux tmp/initrd/usr/share/terminfo/l/
	mkdir -p tmp/initrd/usr/share/terminfo/v
	cp -f /usr/share/terminfo/v/vt100 tmp/initrd/usr/share/terminfo/v/
	mkdir -p tmp/initrd/usr/share/terminfo/x
	cp -f /usr/share/terminfo/x/xterm-256color tmp/initrd/usr/share/terminfo/x/
# --- systemd
# Targets and Services
# https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
# StandardOutput=
# inherit, null, tty, journal, kmsg, journal+console, kmsg+console, file:path, append:path, truncate:path, socket or fd:name.
# https://opensource.com/article/20/5/systemd-startup
	mkdir -p tmp/initrd/etc/systemd/system
	rm -fr tmp/systemd
	mkdir -p tmp/systemd
	cat pkg2/systemd-$(SYSTEMD_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/systemd
	rm -fr tmp/systemd/usr/include
	rm -fr tmp/systemd/usr/share/pkgconfig
	rm -fr tmp/systemd/usr/share/zsh
	rm -fr tmp/systemd/usr/share/systemd/*
	echo "# Generated from system-config-keyboard's model list" > tmp/systemd/usr/share/systemd/kbd-model-map
	echo "# consolelayout		xlayout	xmodel		xvariant	xoptions" >> tmp/systemd/usr/share/systemd/kbd-model-map
	echo "us			us	pc105+inet	-		terminate:ctrl_alt_bksp" >> tmp/systemd/usr/share/systemd/kbd-model-map
	rm -f tmp/systemd/usr/sbin/init
	rm -fr tmp/systemd/usr/lib/kernel
	rm -fr tmp/systemd/usr/lib/pkgconfig
	mv tmp/systemd/usr/lib/systemd/catalog/systemd.catalog tmp/systemd/usr/lib/systemd/
	rm -f tmp/systemd/usr/lib/systemd/catalog/*
	mv tmp/systemd/usr/lib/systemd/systemd.catalog tmp/systemd/usr/lib/systemd/catalog/
	mkdir -p tmp/initrd/var/
	cp -far tmp/systemd/var/* tmp/initrd/var/
	cp -far tmp/systemd/etc/* tmp/initrd/etc/
	cp -far tmp/systemd/usr/* tmp/initrd/usr/
	rm -fr tmp/systemd
	cp -far cfg/systemd/system/* tmp/initrd/etc/systemd/system/
#	rm -fr tmp/initrd/usr/lib/systemd/network
	mkdir -p tmp/initrd/etc/systemd/network/
	cp -far cfg/systemd/network/* tmp/initrd/etc/systemd/network/
#	cd tmp/initrd/etc/systemd/system/ && ln -sf /etc/systemd/system/multi-user.target default.target
	cd tmp/initrd/usr/lib/systemd/system && ln -sf multi-user.target default.target
	cd tmp/initrd/etc/systemd/system && ln -sf poweroff.target ctrl-alt-del.target
#	mkdir -p tmp/initrd/etc/systemd/system/multi-user.target.wants
#	cd tmp/initrd/etc/systemd/system/multi-user.target.wants && ln -sf ../nvme-opt.mount nvme-opt.mount
#	cp -f cfg/etc/systemd/system.conf tmp/initrd/etc/systemd
# === sulogin , shutdown , nscd
	cp -f /usr/sbin/sulogin tmp/initrd/usr/sbin/
	cp -f /usr/sbin/shutdown tmp/initrd/usr/sbin/
#	cp -f /usr/sbin/nscd tmp/initrd/usr/sbin/
#	cp -f /usr/sbin/e2scrub tmp/initrd/usr/sbin/
#	cp -f /usr/sbin/e2scrub_all tmp/initrd/usr/sbin/
# === util-linux systemd : fstrim.service, fstrim.timer, uuidd.service, uuidd.socket
	rm -fr tmp/util-linux
	mkdir -p tmp/util-linux
	cat pkg2/util-linux-$(UTIL_LINUX_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/util-linux
	cp -far tmp/util-linux/usr/lib/systemd/system/* tmp/initrd/usr/lib/systemd/system/
	rm -fr tmp/util-linux
# === glibc systemd: nscd.service
#	rm -fr tmp/glibc
#	mkdir -p tmp/glibc
#	cat pkg2/glibc-$(GLIBC_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/glibc
#	cp -far tmp/glibc/usr/lib/systemd/system/* tmp/initrd/usr/lib/systemd/system/
#	rm -fr tmp/glibc
# === e2fsprogs systemd: e2scrub_all.service, e2scrub_all.timer, e2scrub_fail@.service, e2scrub_reap.service, e2scrub@.service
#	rm -fr tmp/e2fsprogs
#	mkdir -p tmp/e2fsprogs
#	cat pkg2/e2fsprogs-$(E2FSPROGS_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/e2fsprogs
#	cp -far tmp/e2fsprogs/usr/lib/systemd/system/* tmp/initrd/usr/lib/systemd/system/
#	rm -fr tmp/e2fsprogs
# === inetutils
	rm -fr tmp/inet
	mkdir -p tmp/inet
	cat pkg2/inetutils-$(INET_UTILS_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/inet
	cp -far tmp/inet/* tmp/initrd/
	rm -fr tmp/inet
# === iproute
	rm -fr tmp/ip
	mkdir -p tmp/ip
	cat pkg2/iproute2-$(IP_ROUTE2_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/ip
	rm -fr tmp/ip/usr/include
	cp -far tmp/ip/* tmp/initrd/
	rm -fr tmp/ip
# === shadow
	rm -fr tmp/shadow
	mkdir -p tmp/shadow
	cat pkg2/shadow-$(SHADOW_VER).cpio.zst | zstd -d | cpio -idumH newc -D tmp/shadow
	cp -far tmp/shadow/etc/* tmp/initrd/etc/
	sed -i 's|MAIL_CHECK_ENAB|#MAIL_CHECK_ENAB|' tmp/initrd/etc/login.defs
	cp -far tmp/shadow/usr/* tmp/initrd/usr/
	rm -fr tmp/shadow
# === dbus
	cat pkg2/dbus-min.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/initrd
# ===
	mkdir -p      tmp/initrd/boot
	mkdir -p      tmp/initrd/opt
	mkdir -p      tmp/initrd/run
	mkdir -p      tmp/initrd/var/cache
	mkdir -p      tmp/initrd/var/lib/arpd
	mkdir -p      tmp/initrd/var/lib/color
	mkdir -p      tmp/initrd/var/lib/dbus
	mkdir -p      tmp/initrd/var/lib/hwclock
	mkdir -p      tmp/initrd/var/lib/locate
	mkdir -p      tmp/initrd/var/lib/misc
	mkdir -p      tmp/initrd/var/lib/nss_db
	mkdir -p      tmp/initrd/var/lib/systemd
	mkdir -p      tmp/initrd/var/local
	mkdir -p      tmp/initrd/var/log/journal
	touch         tmp/initrd/var/log/btmp
	touch         tmp/initrd/var/log/lastlog
	touch         tmp/initrd/var/log/faillog
	touch         tmp/initrd/var/log/wtmp
	chgrp -v utmp tmp/initrd/var/log/lastlog
	chmod -v 664  tmp/initrd/var/log/lastlog
	chmod -v 600  tmp/initrd/var/log/btmp
	mkdir -p      tmp/initrd/var/mail
	mkdir -p      tmp/initrd/var/opt
	mkdir -p      tmp/initrd/var/spool
	mkdir -p      tmp/initrd/var/myboot/etc
	cd tmp/initrd/var && ln -sf ../run run
	install -d -m 1777 tmp/initrd/run/lock
	cd tmp/initrd/var && ln -sf ../run/lock lock
	install -d -m 1777 tmp/initrd/tmp
	install -d -m 1777 tmp/initrd/var/tmp
	chown -R root:root tmp/initrd/*
#	mkdir -p tmp/initrd/etc/rc.d
	mkdir -p tmp/initrd/etc
	cd tmp/initrd/etc && ln -sf ../proc/self/mounts mtab
#nscd.conf
#	cp -f cfg/etc/nscd.conf tmp/initrd/etc/
#	mkdir -p tmp/initrd/run/nscd
#	mkdir -p tmp/initrd/var/cache/nscd
# time
	mkdir -p tmp/initrd/usr/share/zoneinfo
	cp -far /usr/share/zoneinfo/* tmp/initrd/usr/share/zoneinfo
	cd tmp/initrd/etc && ln -sfv /usr/share/zoneinfo/Etc/GMT localtime
	cp -f /usr/bin/date tmp/initrd/usr/bin/
	cp -f /usr/sbin/hwclock tmp/initrd/usr/sbin/
# issue
	cat pkg2/issue.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/initrd/etc
# (1) /etc/environment
	touch tmp/initrd/etc/environment
# (2) /etc/profile
	echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"' > tmp/initrd/etc/profile
	echo '/bin/cat /etc/issue' >> tmp/initrd/etc/profile
	echo 'umask 022' >> tmp/initrd/etc/profile
# (3) $HOME/.profile
	echo 'alias ls="ls --color"' > tmp/initrd/root/.profile
	echo 'export PS1="\u@\h:\w# "' >> tmp/initrd/root/.profile
# (4) $HOME/.env (ABSENT)
#
# .bashrc (for non-interactive)
#	echo 'alias ls="ls --color"' >> tmp/initrd/root/.bashrc
#	echo 'export PS1="\u@\h:\w# "' >> tmp/initrd/root/.bashrc
# group
#	cp -f cfg/etc/group tmp/initrd/etc/
#	echo "root:x:0:" > tmp/initrd/etc/group
#	echo "daemon:x:1:" >> tmp/initrd/etc/group
#	echo "bin:x:2:" >> tmp/initrd/etc/group
#	echo "sys:x:3:" >> tmp/initrd/etc/group
#	echo "adm:x:4:" >> tmp/initrd/etc/group
#	echo "tty:x:5:" >> tmp/initrd/etc/group
#	echo "disk:x:6:" >> tmp/initrd/etc/group
#	echo "lp:x:7:" >> tmp/initrd/etc/group
#	echo "mail:x:8:" >> tmp/initrd/etc/group
#	echo "kmem:x:9:" >> tmp/initrd/etc/group
#	echo "wheel:x:10:root" >> tmp/initrd/etc/group
#	echo "cdrom:x:11:" >> tmp/initrd/etc/group
#	echo "dialout:x:18:" >> tmp/initrd/etc/group
#	echo "floppy:x:19:" >> tmp/initrd/etc/group
#	echo "video:x:28:" >> tmp/initrd/etc/group
#	echo "audio:x:29:" >> tmp/initrd/etc/group
#	echo "tape:x:32:" >> tmp/initrd/etc/group
#	echo "www-data:x:33:" >> tmp/initrd/etc/group
#	echo "operator:x:37:" >> tmp/initrd/etc/group
#	echo "utmp:x:43:" >> tmp/initrd/etc/group
#	echo "plugdev:x:46:" >> tmp/initrd/etc/group
#	echo "staff:x:50:" >> tmp/initrd/etc/group
#	echo "lock:x:54:" >> tmp/initrd/etc/group
#	echo "netdev:x:82:" >> tmp/initrd/etc/group
#	echo "users:x:100:" >> tmp/initrd/etc/group
#	echo "nobody:x:65534:" >> tmp/initrd/etc/group
# passwd
#	install -o tester -d tmp/initrd/home/tester
	passwd -d root
	groupadd -f lfs
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true
	echo "lfs:1234" | chpasswd
	cp -f /etc/group tmp/initrd/etc/
	echo "sshd:x:50:" >> tmp/initrd/etc/group
	cp -f /etc/passwd tmp/initrd/etc/
	echo "sshd:x:50:50:sshd PrivSep:/var/lib/sshd:/bin/false" >> tmp/initrd/etc/passwd
	cp -f /etc/shadow tmp/initrd/etc/
	cp -far /home tmp/initrd/
	echo 'alias ls="ls --color"' > tmp/initrd/home/lfs/.profile
	echo 'export PS1="\u@\h:\w$$ "' >> tmp/initrd/home/lfs/.profile
	chown lfs tmp/initrd/home/lfs/.profile
	chgrp lfs tmp/initrd/home/lfs/.profile
#	cp -f tmp/initrd/root/.profile tmp/initrd/home/lfs/
#	sed -i 's|root:x:0:0:root:/root:/bin/bash|root::0:0:root:/root:/bin/bash|' tmp/initrd/etc/passwd
##	echo "root::0:0:root:/root:/abin/sh" > tmp/initrd/etc/passwd
#	echo "daemon:x:1:1:daemon:/usr/sbin:/abin/false" >> tmp/initrd/etc/passwd
#	echo "bin:x:2:2:bin:/abin:/abin/false" >> tmp/initrd/etc/passwd
#	echo "sys:x:3:3:sys:/dev:/abin/false" >> tmp/initrd/etc/passwd
#	echo "sync:x:4:100:sync:/abin:/abin/sync" >> tmp/initrd/etc/passwd
#	echo "mail:x:8:8:mail:/var/spool/mail:/abin/false" >> tmp/initrd/etc/passwd
#	echo "www-data:x:33:33:www-data:/var/www:/abin/false" >> tmp/initrd/etc/passwd
#	echo "operator:x:37:37:Operator:/var:/abin/false" >> tmp/initrd/etc/passwd
#	echo "nobody:x:65534:65534:nobody:/home:/abin/false" >> tmp/initrd/etc/passwd
# protocols & services
#	cp -f cfg/etc/protocols tmp/initrd/etc/
	cp -f /etc/protocols tmp/initrd/etc/
	cp -f /etc/services tmp/initrd/etc/
# rpc
	cp -f /etc/rpc tmp/initrd/etc/
#
	cp -f /etc/nsswitch.conf tmp/initrd/etc/
#/etc/fstab: Creating the /etc/fstab File
#	echo "# <file system>     <mount point>  <type>  <options>   <dump>  <fsck>" > tmp/initrd/etc/fstab
#	echo "/dev/nvme0n1p1 /opt ext4 rw,relatime 0 0" >> tmp/initrd/etc/fstab
#	echo "/dev/mmcblk0p1 /mnt/sd ext4 auto rw,relatime 0 0" >> tmp/initrd/etc/fstab
#/etc/inputrc: Creating the /etc/inputrc File
	echo '# /etc/inputrc - global inputrc for libreadline' > tmp/initrd/etc/inputrc
	echo '# Allow the command prompt to wrap to the next line' >> tmp/initrd/etc/inputrc
	echo 'set horizontal-scroll-mode Off' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# Enable 8bit input' >> tmp/initrd/etc/inputrc
	echo 'set meta-flag On' >> tmp/initrd/etc/inputrc
	echo 'set input-meta On' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# To allow the use of 8bit-characters like the german umlauts, uncomment' >> tmp/initrd/etc/inputrc
	echo '# the line below. However this makes the meta key not work as a meta key,' >> tmp/initrd/etc/inputrc
	echo '# which is annoying to those which dont need to type in 8-bit characters.' >> tmp/initrd/etc/inputrc
	echo '# Turns off 8th bit stripping' >> tmp/initrd/etc/inputrc
	echo 'set convert-meta Off' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# Keep the 8th bit for display' >> tmp/initrd/etc/inputrc
	echo 'set output-meta On' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# try to enable the application keypad when it is called.  Some systems' >> tmp/initrd/etc/inputrc
	echo '# need this to enable the arrow keys.' >> tmp/initrd/etc/inputrc
	echo '# set enable-keypad on' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# none, visible or audible' >> tmp/initrd/etc/inputrc
	echo 'set bell-style none' >> tmp/initrd/etc/inputrc
	echo '# set bell-style visible' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# All of the following map the escape sequence of the value' >> tmp/initrd/etc/inputrc
	echo '# contained in the 1st argument to the readline specific functions' >> tmp/initrd/etc/inputrc
	echo '"\eOd": backward-word' >> tmp/initrd/etc/inputrc
	echo '"\eOc": forward-word' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# FOR LINUX CONSOLE' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# allow the use of the Home/End keys' >> tmp/initrd/etc/inputrc
	echo '"\e[1~": beginning-of-line' >> tmp/initrd/etc/inputrc
	echo '"\e[4~": end-of-line' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# alternate mappings for "page up" and "page down" to search the history' >> tmp/initrd/etc/inputrc
	echo '# "\e[5~": history-search-backward' >> tmp/initrd/etc/inputrc
	echo '# "\e[6~": history-search-forward' >> tmp/initrd/etc/inputrc
	echo '"\e[5~": beginning-of-history' >> tmp/initrd/etc/inputrc
	echo '"\e[6~": end-of-history' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# allow the use of the Delete/Insert keys' >> tmp/initrd/etc/inputrc
	echo '"\e[3~": delete-char' >> tmp/initrd/etc/inputrc
	echo '"\e[2~": quoted-insert' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# for xterm' >> tmp/initrd/etc/inputrc
	echo '"\eOH": beginning-of-line' >> tmp/initrd/etc/inputrc
	echo '"\eOF": end-of-line' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# for freebsd Konsole' >> tmp/initrd/etc/inputrc
	echo '"\e[H": beginning-of-line' >> tmp/initrd/etc/inputrc
	echo '"\e[F": end-of-line' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving' >> tmp/initrd/etc/inputrc
	echo '"\e[1;5C": forward-word' >> tmp/initrd/etc/inputrc
	echo '"\e[1;5D": backward-word' >> tmp/initrd/etc/inputrc
	echo '"\e[5C": forward-word' >> tmp/initrd/etc/inputrc
	echo '"\e[5D": backward-word' >> tmp/initrd/etc/inputrc
	echo '"\e\e[C": forward-word' >> tmp/initrd/etc/inputrc
	echo '"\e\e[D": backward-word' >> tmp/initrd/etc/inputrc
	echo '' >> tmp/initrd/etc/inputrc
	echo '# End /etc/inputrc' >> tmp/initrd/etc/inputrc
#/etc/ld.so.conf: Configuring the Dynamic Loader
#/etc/lfs-release: The End
#/etc/localtime: Configuring Glibc
#/etc/lsb-release: The End
#/etc/modprobe.d/usb.conf: Configuring Linux Module Load Order
#/etc/os-release: The End
#/etc/resolv.conf: Creating the /etc/resolv.conf File
	cd tmp/initrd/etc && ln -sf ../run/systemd/resolve/resolv.conf resolv.conf
# shells
	echo "/bin/sh" > tmp/initrd/etc/shells
	echo "/bin/bash" >> tmp/initrd/etc/shells
#	echo "/abin/sh" >> tmp/initrd/etc/shells
#	echo "/abin/ash" >> tmp/initrd/etc/shells
# shadow
#	cp -f /etc/shadow tmp/initrd/etc/
#	echo "root::19701::::::" > tmp/initrd/etc/shadow
#	echo "daemon:*:::::::" >> tmp/initrd/etc/shadow
#	echo "bin:*:::::::" >> tmp/initrd/etc/shadow
#	echo "sys:*:::::::" >> tmp/initrd/etc/shadow
#	echo "sync:*:::::::" >> tmp/initrd/etc/shadow
#	echo "mail:*:::::::" >> tmp/initrd/etc/shadow
#	echo "www-data:*:::::::" >> tmp/initrd/etc/shadow
#	echo "operator:*:::::::" >> tmp/initrd/etc/shadow
#	echo "nobody:*:::::::" >> tmp/initrd/etc/shadow
# hostname
#	cp -f cfg/etc/HOSTNAME tmp/initrd/etc/
	echo 'opi5plus' > tmp/initrd/etc/hostname
# hosts
	echo "127.0.0.1	localhost" > tmp/initrd/etc/hosts
	echo "127.0.1.1	opi5plus" >> tmp/initrd/etc/hosts
	echo "# The following lines are desirable for IPv6 capable hosts" >> tmp/initrd/etc/hosts
	echo "::1     ip6-localhost ip6-loopback" >> tmp/initrd/etc/hosts
	echo "fe00::0 ip6-localnet" >> tmp/initrd/etc/hosts
	echo "ff00::0 ip6-mcastprefix" >> tmp/initrd/etc/hosts
	echo "ff02::1 ip6-allnodes" >> tmp/initrd/etc/hosts
	echo "ff02::2 ip6-allrouters" >> tmp/initrd/etc/hosts
#	echo "127.0.0.1 localhost `hostname`" > tmp/initrd/etc/hosts
#	echo -e "127.0.0.1\tlocalhost" > tmp/initrd/etc/hosts
# host.conf
#	cp -f cfg/etc/host.conf tmp/initrd/etc/
# networks
#	cp -f cfg/etc/networks tmp/initrd/etc/
# udhcp.sh
#	mkdir -p tmp/initrd/etc/scripts
#	cp -far cfg/etc/scripts tmp/initrd/etc/
#	chmod ugo+x tmp/initrd/etc/scripts/udhcp.sh
# MAIN init
	cd tmp/initrd && ln -sf /usr/lib/systemd/systemd init
# Initrd
ifeq ($(INITRD_GZIP),y)
	cd tmp/initrd && find . -print | cpio -oH newc | gzip > ../Initrd
	mkimage -A arm64 -O linux -T ramdisk -C gzip -n uInitrd -d tmp/Initrd tmp/uInitrd
else
	cd tmp/initrd && find . -print | cpio -oH newc > ../Initrd
	mkimage -A arm64 -O linux -T ramdisk -C none -n uInitrd -d tmp/Initrd tmp/uInitrd
endif
	rm -f  tmp/Initrd
#	rm -fr tmp/initrd
	mkdir -p tmp/initrd_ins/usr/share/myboot/boot-fat
	mv -f tmp/uInitrd tmp/initrd_ins/usr/share/myboot/boot-fat/
	cd tmp/initrd_ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/initrd_ins
tgt-rd: pkg2/boot-initrd.cpio.zst

pkg2/boot-fat.cpio.zst: pkg2/boot-initrd.cpio.zst
	rm -fr tmp/fat
	mkdir -p tmp/fat/ins/usr/share/myboot
# (!!!) seek=X, type here value-1 from ODS (117 for example)
	dd of=tmp/fat/mmc-fat.bin if=/dev/zero bs=1M count=0 seek=211
	mkfs.fat -F 32 -n "our_boot" -i A77ACF93 tmp/fat/mmc-fat.bin
	mkdir -p tmp/fat/mnt
	mount tmp/fat/mmc-fat.bin tmp/fat/mnt
	cp --force --no-preserve=all --recursive /usr/share/myboot/boot-fat/* tmp/fat/mnt
	mkdir -p tmp/fat/mnt/zst
	cp --force --no-preserve=all --recursive pkg2/wget-$(WGET_VER).cpio.zst tmp/fat/mnt/zst/wget.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/kernel-modules.cpio.zst tmp/fat/mnt/zst/
	cp --force --no-preserve=all --recursive pkg2/kernel-headers.cpio.zst tmp/fat/mnt/zst/
	cp --force --no-preserve=all --recursive pkg2/binutils-$(BINUTILS_VER).cpio.zst tmp/fat/mnt/zst/binutils.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/gcc-$(GCC_VER).cpio.zst tmp/fat/mnt/zst/gcc.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/isl-$(ISL_VER).cpio.zst tmp/fat/mnt/zst/isl.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/gmp-$(GMP_VER).cpio.zst tmp/fat/mnt/zst/gmp.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/mpc-$(MPC_VER).cpio.zst tmp/fat/mnt/zst/mpc.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/mpfr-$(MPFR_VER).cpio.zst tmp/fat/mnt/zst/mpfr.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/glibc-$(GLIBC_VER).cpio.zst tmp/fat/mnt/zst/glibc.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/coreutils-$(CORE_UTILS_VER).cpio.zst tmp/fat/mnt/zst/coreutils.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/acl-$(ACL_VER).cpio.zst tmp/fat/mnt/zst/acl.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/attr-$(ATTR_VER).cpio.zst tmp/fat/mnt/zst/attr.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/util-linux-$(UTIL_LINUX_VER).cpio.zst tmp/fat/mnt/zst/util-linux.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/tar-$(TAR_VER).cpio.zst tmp/fat/mnt/zst/tar.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/xz-$(XZ_VER).cpio.zst tmp/fat/mnt/zst/xz-utils.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/sed-$(SED_VER).cpio.zst tmp/fat/mnt/zst/sed.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/gawk-$(GAWK_VER).cpio.zst tmp/fat/mnt/zst/gawk.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/diffutils-$(DIFF_UTILS_VER).cpio.zst tmp/fat/mnt/zst/diffutils.cpio.zst
	cp --force --no-preserve=all --recursive pkg2/flex-$(FLEX_VER).cpio.zst tmp/fat/mnt/zst/flex.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/gzip-$(GZIP_VER).cpio.zst tmp/fat/mnt/zst/gzip.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/patch-$(PATCH_VER).cpio.zst tmp/fat/mnt/zst/patch.cpio.zst
#	cp --force --no-preserve=all --recursive pkg2/openssh-$(OPENSSH_VER).cpio.zst tmp/fat/mnt/zst/openssh.cpio.zst
	mkdir -p tmp/fat/etc/ssh
	cp -far cfg/etc/* tmp/fat/etc
#
#	ssh-keygen -A
#	cp -farv /etc/ssh/*key* tmp/fat/etc/ssh
#
#	echo '#include <stdio.h>' > tmp/fat/etc/myetc/mytest.c
#	echo 'int main() {' >> tmp/fat/etc/myetc/mytest.c
#	echo '  printf("Hello, World!\n");' >> tmp/fat/etc/myetc/mytest.c
#	echo '  return 0;' >> tmp/fat/etc/myetc/mytest.c
#	echo '}' >> tmp/fat/etc/myetc/mytest.c
	cd tmp/fat/etc && find . -print0 | cpio -o0H newc --quiet > ../mnt/etc.cpio
	umount tmp/fat/mnt
	mv -f tmp/fat/mmc-fat.bin tmp/fat/ins/usr/share/myboot/
	cd tmp/fat/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/fat
tgt-fat: pkg2/boot-fat.cpio.zst

#TGT_UBOOT=u-boot-rockchip.bin
TGT_UBOOT=u-boot-xunlong.bin

mmc.img: pkg2/boot-fat.cpio.zst
	rm -fr tmp/init
	mkdir -p tmp/init
# (!!!) seek=X, type here value-10 from ODS (256 for example)
	dd of=tmp/init/mmc.img if=/dev/zero bs=1M count=0 seek=222
	dd of=tmp/init/mmc.img if=/usr/share/myboot/$(TGT_UBOOT) seek=64    conv=notrunc
	dd of=tmp/init/mmc.img if=/usr/share/myboot/mmc-fat.bin  seek=20480 conv=notrunc
	parted -s tmp/init/mmc.img mklabel gpt
# (!!!) last value, type here value-5 from ODS (260095 for example)
	parted -s tmp/init/mmc.img unit s mkpart bootfs 20480 452607
#	cp -f tmp/init/mmc.img .
	mkdir -p tmp/init/ins
	cp -f tmp/init/mmc.img tmp/init/ins/
	cat tmp/init/mmc.img | zstd -z9T9 > tmp/init/ins/mmc.zst
# (!!!) count=X, type here value-3 from ODS (239616 for example)
	dd if=tmp/init/ins/mmc.img of=tmp/init/ins/fat.bin skip=20480 count=432128
	mkdir -p tmp/init/ins/fat
	mount tmp/init/ins/fat.bin tmp/init/ins/fat
	cp --force --no-preserve=all tmp/init/ins/mmc.zst tmp/init/ins/fat
	umount tmp/init/ins/fat.bin
	dd of=tmp/init/ins/mmc.img if=tmp/init/ins/fat.bin seek=20480 conv=notrunc
	cp -f tmp/init/ins/mmc.img .
	rm -fr tmp/init
#mmc: mmc.img

#mmc-sd: mmc.img
#	rm -fr tmp/mmc-sd
#	mkdir -p tmp/mmc-sd/fat
#	cp -f $< tmp/mmc-sd/
#	cat $< | zstd -z9T9 > tmp/mmc-sd/mmc.zst
#	dd if=tmp/mmc-sd/mmc.img of=tmp/mmc-sd/fat.bin skip=20480 count=182272
#	mount tmp/mmc-sd/fat.bin tmp/mmc-sd/fat
#	cp --force --no-preserve=all tmp/mmc-sd/mmc.zst tmp/mmc-sd/fat
#	umount tmp/mmc-sd/fat.bin
#	dd of=tmp/init/mmc.img if=/usr/share/myboot/mmc-fat.bin  seek=20480 conv=notrunc

flash: mmc.img
	@echo "FLASH ALL - whole mmc.img to EMMC"
	@echo "Connect usb-target, enter in maskrom, and press ENTER to continue"
	@read line
	rkdeveloptool db /usr/share/myboot/usb-loader.bin && rkdeveloptool wl 0 mmc.img && rkdeveloptool rd


#	mkdir -p /boot
#	mkdir -p /home
#	mkdir -p /media
#	mkdir -p /mnt
#	mkdir -p /srv
#	mkdir -p /etc/opt
#	mkdir -p /etc/sysconfig
#	mkdir -p /lib/firmware
## mkdir -p /media/{floppy,cdrom}
#	mkdir -p /usr/local/bin
#	mkdir -p /usr/local/include
#	mkdir -p /usr/local/lib
#	mkdir -p /usr/local/sbin
#	mkdir -p /usr/local/src
## mkdir -p /usr/{,local/}share/{color,dict,doc,info,locale,man}
#	mkdir -p /usr/share/misc
#	mkdir -p /usr/share/terminfo
#	mkdir -p /usr/share/zoneinfo
#	mkdir -p /usr/local/share/misc
#	mkdir -p /usr/local/share/terminfo
#	mkdir -p /usr/local/share/zoneinfo
## mkdir -p /usr/{,local/}share/man/man{1..8}
#	install -dv -m 0750 /root
#	ln -sfv /proc/self/mounts /etc/mtab

# Extra :: python 'pyelftools' (for uboot)
# https://github.com/eliben/pyelftools/wiki/User's-guide
# https://github.com/eliben/pyelftools
# BUILD_TIME :: 2s
#pkg3/pyelftools-$(PYELFTOOLS_VER).cpio.zst: pkg3/libarchive-$(LIBARCHIVE_VER).cpio.zst
#	rm -fr tmp/pyelftools
#	mkdir -p tmp/pyelftools
#	bsdtar -xf pkg/pyelftools-$(PYELFTOOLS_VER).zip -C tmp/pyelftools
#	cd tmp/pyelftools/pyelftools-$(PYELFTOOLS_VER) && python3 setup.py install
### /usr/lib/python3.8/site-packages/easy-install.pth
### /usr/lib/python3.8/site-packages/pyelftools-0.30-py3.8.egg/
## backward pack from rfs
#	rm -f /usr/lib/python$(PYTHON_VER0)/site-packages/easy-install.pth
#	mkdir -p tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/pyelftools-$(PYELFTOOLS_VER)-py$(PYTHON_VER0).egg
##	cp -f /usr/lib/python$(PYTHON_VER0)/site-packages/easy-install.pth tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cp -far /usr/lib/python$(PYTHON_VER0)/site-packages/pyelftools-$(PYELFTOOLS_VER)-py$(PYTHON_VER0).egg tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cd tmp/pyelftools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
#	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
#pkg3/pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst:
##	pip3 install pyelftools
#	rm -fr tmp/pyelftools
#	mkdir -p tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages
#	cp -far /usr/lib/python3.8/site-packages/elftools tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cp -far /usr/lib/python3.8/site-packages/pyelftools-$(PYELFTOOLS_VER).dist-info tmp/pyelftools/ins/usr/lib/python$(PYTHON_VER0)/site-packages/
#	cd tmp/pyelftools/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
## backward pack from rfs
#tgt-pyelftools: pkg3/pyelftools-$(PYELFTOOLS_VER).pip3.cpio.zst

# pip3 install pyelftools
# /usr/lib/python3.8/site-packages/pyelftools-$(PYELFTOOLS_VER)
# /usr/lib/python3.8/site-packages/elftools/*


# extra BLFS-10.0-systemd :: Boost-1.74.0
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/boost.html

# https://netfilter.org/projects/nftables/
# https://netfilter.org/projects/nftables/downloads.html
# https://netfilter.org/projects/nftables/files/nftables-1.0.9.tar.xz

# https://git.kernel.org/cgit/linux/kernel/git/netfilter/nf-next.git
# https://git.netfilter.org/libnftnl/
# https://git.netfilter.org/nftables/
# https://git.netfilter.org/iptables/

# extra :: libnetfilter_conntrack
# https://netfilter.org/projects/libnetfilter_conntrack/
# https://git.netfilter.org/libnetfilter_conntrack/
# https://netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-1.0.8.tar.bz2
# https://netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-1.0.9.tar.bz2

# extra :: libnfnetlink
# https://netfilter.org/projects/libnfnetlink/
# https://git.netfilter.org/libnfnetlink/
# https://netfilter.org/projects/libnfnetlink/files/libnfnetlink-1.0.2.tar.bz2

# extra
# https://github.com/toszr/bpf-utils

# BlueZ-5.54, libnl-3.5.0, libusb-1.0.23,

# extra blfs :: libpcap-1.9.1
# https://www.linuxfromscratch.org/blfs/view/10.0/basicnet/libpcap.html

# ===

# extra CAN-UTILS
# BUILD_TIME :: 3s
ifeq ($(VERB),1)
CAN_UTILS_BUILD_VERB=-v
endif
pkg3/can-utils.cpio.zst: pkg3/cmake-$(CMAKE_VER).cpio.zst
	rm -fr tmp/can-utils
	mkdir -p tmp/can-utils/src
	mkdir -p tmp/can-utils/bld
	cat pkg/can-utils-$(CAN_UTILS_VER).src.cpio.zst | zstd -d | cpio -iduH newc --quiet -D tmp/can-utils/src
	cd tmp/can-utils/bld && cmake -GNinja ../src
	cd tmp/can-utils/bld && LANG=en_US.UTF-8 ninja $(CAN_UTILS_BUILD_VERB)
	cd tmp/can-utils/bld && LANG=en_US.UTF-8 DESTDIR=`pwd`/../ins ninja install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/can-utils/ins/usr/local/bin/*
endif
	cd tmp/can-utils/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/can-utils
tgt-can-utils: pkg3/can-utils.cpio.zst

# extra blfs :: libtasn1-4.16.0
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libtasn1.html
# BUILD_TIME :: 44s
LIBTASN1_OPT3+= --prefix=/usr
LIBTASN1_OPT3+= --disable-static
LIBTASN1_OPT3+= $(OPT_FLAGS)
pkg3/libtasn1-$(LIBTASN1_VER).cpio.zst:
	rm -fr tmp/libtasn1
	mkdir -p tmp/libtasn1/bld
	tar -xzf pkg/libtasn1-$(LIBTASN1_VER).tar.gz -C tmp/libtasn1
	cd tmp/libtasn1/bld && ../libtasn1-$(LIBTASN1_VER)/configure $(LIBTASN1_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libtasn1/ins/usr/share
	rm -fr tmp/libtasn1/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
#	strip --strip-debug    tmp/libtasn1/ins/usr/lib/*.a
	strip --strip-unneeded tmp/libtasn1/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/libtasn1/ins/usr/bin/* || true
endif
	cd tmp/libtasn1/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libtasn1
tgt-libtasn1: pkg3/libtasn1-$(LIBTASN1_VER).cpio.zst

# extra blfs :: libunistring-0.9.10
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libunistring.html
# BUILD_TIME :: 2m 51s
LIBUNISTRING_OPT3+= --prefix=/usr
LIBUNISTRING_OPT3+= --disable-static
LIBUNISTRING_OPT3+= --docdir=/usr/share/doc/libunistring-$(LIBUNISTRING_VER)
LIBUNISTRING_OPT3+= $(OPT_FLAGS)
pkg3/libunistring-$(LIBUNISTRING_VER).cpio.zst:
	rm -fr tmp/libunistring
	mkdir -p tmp/libunistring/bld
	tar -xJf pkg/libunistring-$(LIBUNISTRING_VER).tar.xz -C tmp/libunistring
	cd tmp/libunistring/bld && ../libunistring-$(LIBUNISTRING_VER)/configure $(LIBUNISTRING_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libunistring/ins/usr/share
	rm -fr tmp/libunistring/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libunistring/ins/usr/lib/*.so*
endif
	cd tmp/libunistring/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libunistring
tgt-libunistring: pkg3/libunistring-$(LIBUNISTRING_VER).cpio.zst

# extra blfs :: libidn2-2.3.0
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/general/libidn2.html
# BUILD_TIME :: 50s
# DEPENDENCY: libunistring
LIBIDN2_OPT3+= --prefix=/usr
LIBIDN2_OPT3+= --disable-static
LIBIDN2_OPT3+= --disable-nls
LIBIDN2_OPT3+= $(OPT_FLAGS)
pkg3/libidn2-$(LIBIDN2_VER).cpio.zst:
	rm -fr tmp/libidn2
	mkdir -p tmp/libidn2/bld
	tar -xzf pkg/libidn2-$(LIBIDN2_VER).tar.gz -C tmp/libidn2
	cd tmp/libidn2/bld && ../libidn2-$(LIBIDN2_VER)/configure $(LIBIDN2_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/libidn2/ins/usr/share
	rm -f tmp/libidn2/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libidn2/ins/usr/bin/* || true
	strip --strip-unneeded tmp/libidn2/ins/usr/lib/*.so* || true
endif
	cd tmp/libidn2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libidn2
tgt-libidn2: pkg3/libidn2-$(LIBIDN2_VER).cpio.zst

# extra
# BUILD_TIME :: 5s
LIBCBOR_CMAKE3+= -DCMAKE_BUILD_TYPE=Release
LIBCBOR_CMAKE3+= -DCBOR_CUSTOM_ALLOC=ON
LIBCBOR_CMAKE3+= -DCMAKE_C_FLAGS_RELEASE="$(BASE_OPT_FLAGS)"
LIBCBOR_CMAKE3+= -DCMAKE_VERBOSE_MAKEFILE=true
LIBCBOR_CMAKE3+= -DCMAKE_INSTALL_PREFIX=/usr
pkg3/libcbor-$(LIBCBOR_VER).cpio.zst:
	rm -fr tmp/libcbor
	mkdir -p tmp/libcbor/bld
	bsdtar -xf pkg/libcbor-$(LIBCBOR_VER).zip -C tmp/libcbor
	sed -i "s|-O3||" tmp/libcbor/libcbor-$(LIBCBOR_VER)/CMakeLists.txt
	cd tmp/libcbor/bld && cmake $(LIBCBOR_CMAKE3) ../libcbor-$(LIBCBOR_VER) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/libcbor/ins/usr/lib/*.so* || true
endif
	cd tmp/libcbor/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/libcbor
tgt-libcbor: pkg3/libcbor-$(LIBCBOR_VER).cpio.zst

# EXTRA: BLFS-10: nghtt2
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/basicnet/nghttp2.html
# BUILD_TIME :: 29s
NGHTTP2_OPT3+= --prefix=/usr
NGHTTP2_OPT3+= --disable-static
NGHTTP2_OPT3+= --enable-lib-only
NGHTTP2_OPT3+= --docdir=/usr/share/doc/nghttp2-$(NGHTTP2_VER)
NGHTTP2_OPT3+= $(OPT_FLAGS)
pkg3/nghttp2-$(NGHTTP2_VER).cpio.zst:
	rm -fr tmp/nghttp2
	mkdir -p tmp/nghttp2/bld
	tar -xJf pkg/nghttp2-$(NGHTTP2_VER).tar.xz -C tmp/nghttp2
	cd tmp/nghttp2/bld && ../nghttp2-$(NGHTTP2_VER)/configure $(NGHTTP2_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/nghttp2/ins/usr/share/doc
	rm -fr tmp/nghttp2/ins/usr/share/man
	rm -fr tmp/nghttp2/ins/usr/bin
	rm -fr tmp/nghttp2/ins/usr/lib/*.la
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/nghttp2/ins/usr/lib/*.so* || true
endif
	cd tmp/nghttp2/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/nghttp2
tgt-nghttp2: pkg3/nghttp2-$(NGHTTP2_VER).cpio.zst

# EXTRA
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/postlfs/cyrus-sasl.html
# BUILD_TIME :: 43s
SASL_OPT3+= --prefix=/usr
SASL_OPT3+= --sysconfdir=/etc
SASL_OPT3+= --enable-auth-sasldb 
SASL_OPT3+= --with-dbpath=/var/lib/sasl/sasldb2
SASL_OPT3+= --with-saslauthd=/var/run/saslauthd
SASL_OPT3+= $(OPT_FLAGS)
pkg3/cyrus-sasl-$(SASL_VER).cpio.zst:
	rm -fr tmp/sasl
	mkdir -p tmp/sasl/bld
	tar -xzf pkg/cyrus-sasl-$(SASL_VER).tar.gz -C tmp/sasl
	cp -far pkg/cyrus-sasl-$(SASL_VER)-doc_fixes-1.patch tmp/sasl/
	cd tmp/sasl/cyrus-sasl-$(SASL_VER) && patch -Np1 -i ../cyrus-sasl-$(SASL_VER)-doc_fixes-1.patch
	cd tmp/sasl/bld && ../cyrus-sasl-$(SASL_VER)/configure $(SASL_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -f tmp/sasl/ins/usr/lib/*.la
	rm -f tmp/sasl/ins/usr/lib/sasl2/*.la
	rm -fr tmp/sasl/ins/usr/share
	install -v -dm700 tmp/sasl/ins/var/lib/sasl
ifeq ($(BUILD_STRIP),y)
	strip --strip-unneeded tmp/sasl/ins/usr/lib/*.so* || true
	strip --strip-unneeded tmp/sasl/ins/usr/lib/sasl2/*.so* || true
	strip --strip-unneeded tmp/sasl/ins/usr/sbin/* || true
endif
	cd tmp/sasl/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	cat $@ | zstd -d | cpio -iduH newc --quiet -D /
	rm -fr tmp/sasl
tgt-sasl: pkg3/cyrus-sasl-$(SASL_VER).cpio.zst


# extra
# http://www.openslp.org/
# BUILD_TIME ::
#OPENSLP_OPT3+= --prefix=/usr
#OPENSLP_OPT3+= --disable-static
#OPENSLP_OPT3+= --disable-slpv1
#OPENSLP_OPT3+= --enable-slpv2-security
#OPENSLP_OPT3+= --disable-debug
#OPENSLP_OPT3+= $(OPT_FLAGS)
# common/slp_crypto.c
#SLPCryptoDSAKey * SLPCryptoDSAKeyDup(SLPCryptoDSAKey * dsa)
#{
#   SLPCryptoDSAKey * result;
#
#   result =  DSA_new();
#   if (result)
#   {
#      DSA_set0_pqg(result, DSA_get0_p(dsa), DSA_get0_q(dsa), DSA_get0_g(dsa));
#      DSA_set0_key(result, DSA_get0_pub_key(dsa), DSA_get0_priv_key(dsa));
#      //result->p = BN_dup(dsa->p);
#      //result->q = BN_dup(dsa->q);
#      //result->g = BN_dup(dsa->g);
#      //result->priv_key = BN_dup(dsa->priv_key);
#      //result->pub_key = BN_dup(dsa->pub_key);
#   }
#   return result;
#}
#pkg3/openslp-$(OPENSLP_VER).cpio.zst: pkg3/net-tools-CVS_$(NET_TOOLS_VER).cpio.zst
#	rm -fr tmp/openslp
#	mkdir -p tmp/openslp/bld
#	tar -xzf pkg/openslp-$(OPENSLP_VER).tar.gz -C tmp/openslp
#	sed -i 's|-O2|$(BASE_OPT_FLAGS)|' tmp/openslp/openslp-$(OPENSLP_VER)/configure
#	cd tmp/openslp/bld && ../openslp-$(OPENSLP_VER)/configure $(OPENSLP_OPT3) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
#tgt-openslp: pkg3/openslp-$(OPENSLP_VER).cpio.zst

# EXTRA: OpenLDAP-2.4.51
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/server/openldap.html
# BUILD_TIME ::
pkg3/openldap-$(OPENLDAP_VER).cpio.zst:
	groupadd -g 83 ldap && useradd  -c "OpenLDAP Daemon Owner" -d /var/lib/openldap -u 83 -g ldap -s /bin/false ldap
	rm -fr tmp/openldap
	mkdir -p tmp/openldap/bld
	tar -xzf pkg/openldap-$(OPENLDAP_VER).tgz -C tmp/openldap
	cp -far pkg/openldap-$(OPENLDAP_VER)-consolidated-2.patch tmp/openldap/
	cd tmp/openldap/openldap-$(OPENLDAP_VER) && patch -Np1 -i ../openldap-$(OPENLDAP_VER)-consolidated-2.patch
tgt-openldap: pkg3/openldap-$(OPENLDAP_VER).cpio.zst
