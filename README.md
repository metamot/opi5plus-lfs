# OrangePi5+ LFS

## Initial Requirements:

Target is : **OrangePi5+** (only!) - there are others RK3588-devices are not supported (i.e. classic Opi5 due to uboot diffirences).

Build host is: any RK3588-device with Debian/Ubuntu. I.e. OrangePi5/5b/5+ with Debian11 or Ubuntu22.04. Original "Orange" Debian-11 (Bullseye) XFCE from Xunlong - is highly recomended.

## Clone:

    sudo chmod 777 /opt
    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs
    cd /opt/opi5plus-lfs

**NOTE:** Home-catalog is not suitable for builds. You need do clone directly inside to "/opt". Sub-dirs (i.e. /opt/some-dirs/opi5plus-lfs) are not supported.

<details>
  <summary>Why not HOME-dir?</summary>
    You can rename "/opt/opiplus-lfs" for example, to as "/opt/mysdk" or somthihg else. 
    You can clone to different dir in the /opt,  as is "git clone https://github.com/metamot/opi5plus-lfs my-new-sdk" or somethimg else. 
    You can use different name.
    But you cant(!) create something in "deep more" below this.
    No more as "/opt/SubDir/MySdk" - stringly is not available, there is only "/opt/MySdk" is avialable.
    The problem is - You can watch "tmp"-dir to show what is the package is builds now.
    You can see "watch /opt/mysdk/tmp" it is WHAT NOW PACKAGE IS IN BUILD. To see the progress.
    So, There are two builds are exist. Stage-1 (host tools-builds) AND Stage-2 (the new sytem under chroot).
    The chroot-system has no avialable to see anything far that '/' (The root). 
</details>

NOTE(!): You can clone repo with another name(!). Here is example for "mydsk".

    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs mysdk
    cd mysdk

## Setup host (need only once at first run):

For Debian host, we need to choose **bash** instead of dash (say "no" for dash):

    sudo dpkg-reconfigure dash

Show help:

    make

Configure-host (again say "no" for dash):

    make host

**WARNING**: The 'make host' adds your account to sudoers, so you never be asked for sudo-password in future. See 'Makefile' for details.

## Download packages

    make src

***IMPORTANT!*** After this operation, Please check again that all packages are done at this point ("Repeat-command result"):

    make src
    make: Nothing to be done for 'src'.

To see downloads (accending for download time), pls run:

    ls -1tr src

<details>
  <summary>Here are the reference list:</summary>
    
bash-5.0-upstream_fixes-1.patch

bzip2-1.0.8-install_docs-1.patch

coreutils-8.32-i18n-1.patch

glibc-2.32-fhs-1.patch

kbd-2.3.0-backspace-1.patch

libarchive-3.4.3-testsuite_fix-1.patch

unzip-6.0-consolidated_fixes-1.patch

cyrus-sasl-2.1.27-doc_fixes-1.patch

net-tools-CVS_20101030-remove_dups-1.patch

openldap-2.4.51-consolidated-2.patch

acl-2.2.53.tar.gz

attr-2.4.48.tar.gz

autoconf-2.69.tar.xz

automake-1.16.2.tar.xz

bash-5.0.tar.gz

bc-3.1.5.tar.xz

binutils-2.35.tar.xz

bison-3.7.1.tar.xz

bzip2-1.0.8.tar.gz

check-0.15.2.tar.gz

cmake-3.18.1.tar.gz

convmv-2.05.tar.gz

coreutils-8.32.tar.xz

cpio-2.13.tar.bz2

db-5.3.28.tar.gz

dbus-1.12.20.tar.gz

dejagnu-1.6.2.tar.gz

diffutils-3.7.tar.xz

dosfstools-4.1.tar.xz

dtc-1.7.0.tar.gz

e2fsprogs-1.45.6.tar.gz

elfutils-0.180.tar.bz2

expat-2.6.2.tar.xz

expect5.45.4.tar.gz

file-5.39.tar.gz

findutils-4.7.0.tar.xz

flex-2.6.4.tar.gz

gawk-5.1.0.tar.xz

gcc-10.2.0.tar.xz

gdbm-1.18.1.tar.gz

gettext-0.21.tar.xz

glibc-2.32.tar.xz

gmp-6.2.0.tar.xz

gperf-3.1.tar.gz

grep-3.4.tar.xz

groff-1.22.4.tar.gz
gzip-1.10.tar.xz
iana-etc-20200821.tar.gz
inetutils-1.9.4.tar.xz
intltool-0.51.0.tar.gz
iproute2-5.8.0.tar.xz
iptables-1.8.5.tar.bz2
isl-0.23.tar.xz
kbd-2.3.0.tar.xz
kmod-27.tar.xz
less-551.tar.gz
libarchive-3.4.3.tar.xz
libcap-2.42.tar.xz
libcbor-0.7.0.zip
libedit-20240517-3.1.tar.gz
libedit_bullsyey_3.1-20191231.orig.tar.gz
libffi-3.3.tar.gz
libidn2-2.3.0.tar.gz
libmd-1.0.3.tar.xz
libmnl-1.0.4.tar.bz2
libpipeline-1.5.3.tar.gz
libtasn1-4.16.0.tar.gz
libtool-2.4.6.tar.xz
libunistring-0.9.10.tar.xz
libusb-1.0.23.tar.bz2
libuv-v1.38.1.tar.gz
m4-1.4.18.tar.xz
make-4.3.tar.gz
make-ca-1.7.tar.xz
man-db-2.9.3.tar.xz
man-pages-5.08.tar.xz
meson-0.55.0.tar.gz
microcom-2023.09.0.tar.gz
mpc-1.1.0.tar.gz
mpfr-4.1.0.tar.xz
nano-5.2.tar.xz
ncurses-6.2.tar.gz
net-tools-CVS_20101030.tar.gz
nftables-1.0.9.tar.xz
ninja-1.10.0.tar.gz
nghttp2-1.41.0.tar.xz
openssl-1.1.1g.tar.gz
openldap-2.4.51.tgz
openssh-8.3p1.tar.gz
parted-3.3.tar.xz
patch-2.7.6.tar.xz
pcre-8.44.tar.gz
perl-5.32.0.tar.xz
pkg-config-0.29.2.tar.gz
popt-1.18.tar.gz
procps-ng-3.3.16.tar.xz
psmisc-23.4.tar.xz
pyelftools-0.30.zip
Python-3.8.5.tar.xz
python-3.8.5-docs-html.tar.bz2
Python-2.7.18.tar.xz
re2c-3.1.tar.gz
readline-8.0.tar.gz
rsync-3.2.3.tar.gz
cyrus-sasl-2.1.27.tar.gz
sed-4.8.tar.xz
shadow-4.8.1.tar.xz
sharutils-4.15.2.tar.xz
swig-4.0.2.tar.gz
systemd-246.tar.gz
tar-1.32.tar.xz
tcl8.6.10-src.tar.gz
tcl8.6.10-html.tar.gz
texinfo-6.7.tar.xz
tzdata2020a.tar.gz
unzip60.tar.gz
usbutils-012.tar.xz
util-linux-2.36.tar.xz
wget-1.20.3.tar.gz
which-2.21.tar.gz
XML-Parser-2.46.tar.gz
xz-5.2.5.tar.xz
zlib-1.3.1.tar.xz
zip30.tar.gz
zstd-1.4.5.tar.gz
config.guess
config.sub
orangepi5-rkbin-only_rk3588.cpio.zst
rockchip-rk35-atf.src.cpio.zst
uboot-v2024.04.src.cpio.zst
orangepi5-uboot.src.cpio.zst
rkdeveloptool.src.cpio.zst
orangepi5-linux510.src.cpio.zst
can-utils-v2020.12.0.src.cpio.zst
usb.ids.cpio.zst
</details>

## Build:

To build initial LFS (cross-compile tools)

    time make stage0

***TBD***
