# OrangePi5+ LFS

Here is of how to build your own linux-system from sources.

Clone example to "SomeDir":

    git clone https://github.com/metamot/opi5plus-lfs <mydir>

Here are two examples:

- 1st: Simple clone to home dir:

```
    $ cd ~
    $ git clone https://github.com/metamot/opi5plus-lfs
    $ cd opi5plus-lfs
```

- 2nd: The preffered way (agnostic to "/home/nakeduser") is to "/opt" dir:

```
    $ sudo chmod 777 /opt
    $ mkdir /opt/mysdk # if mysdk is busy, you can change another name
    $ git clone https://github.com/metamot/opi5plus-lfs /opt/mysdk
    $ cd /opt/mysdk
```

The second way is agnostic to home (i.e. "NakedUser") because cross-compiler will store it sysroot, and then the command "gcc -v" will show dir of sysroot as user-home-dir (NakedUser - for example). The "/opt" dir is more preferred.

## STAGE0: Hst-Build initial system using "other host"

We will use "native" compilation without foreign machines (i.e. x86 etc). So the RK3588-machine will build for the RK3588-machine.

### Initial build structure:

- cfg/       - Important catalog of distro configs
- Makefile   - the MAIN BUILD file
- README.md  - the Manual
- .gitignore - it's for repository (not important for you)

That's all. All other files or directories ***are result of build process*** !

### Initial Requirements:

Target is : **OrangePi5+ with installed eMMC-module**

***WARNING***: Opi5+ without eMMC is not supported!

Initial host is : OrangePi5/5b/5+ with Debian11 (possibly Ubuntu22.04 is also acceptable).

Original "Orange" Debian-11 (Bullseye) XFCE from Xunlong - is highly recomended.

For Debian host, we need to choose **bash** instead of dash (say "no" for dash):

    $ sudo dpkg-reconfigure dash

Install build-deps (only once is needed):

    $ make deps

Finally, pls check your host:

    $ make chdeps

Please see screen results or "host-check.txt" file. The common problem of check is "no bash" on Debian (see above).
    
### Download all packages:

Choose one type of download:

(A) Slowly "step-by-step" download with clean screen results:

    $ make pkg
    
Or (B) the "parallel" fast multijob download with huge garbage on screen:
    
    $ make -j pkg

***IMPORTANT!*** After this operation, Please double check that all packages are done at this point ("Repeat-command result"):

    $ make pkg
    make: Nothing to be done for 'pkg'.

**PLEASE, CHECK IT twice (!)**

The result is new 'pkg/' directory with initial packages (see collapsible block, i.e. "spoiler", pls click on black right-oriented triangle):

<details>
<summary>List of initially download packages is here...(spoiler)</summary>

- acl-2.2.53.tar.gz
- attr-2.4.48.tar.gz
- autoconf-2.69.tar.xz
- automake-1.16.2.tar.xz
- bash-5.0.tar.gz
- bash-5.0-upstream_fixes-1.patch
- bc-3.1.5.tar.xz
- binutils-2.35.tar.xz
- bison-3.7.1.tar.xz
- busybox.cpio.zst
- bzip2-1.0.8-install_docs-1.patch
- bzip2-1.0.8.tar.gz
- check-0.15.2.tar.gz
- coreutils-8.32-i18n-1.patch
- coreutils-8.32.tar.xz
- cpio-2.13.tar.bz2
- dbus-1.12.20.tar.gz
- dejagnu-1.6.2.tar.gz
- diffutils-3.7.tar.xz
- e2fsprogs-1.45.6.tar.gz
- elfutils-0.180.tar.bz2
- expat-2.5.0.tar.xz
- expect5.45.4.tar.gz
- file-5.39.tar.gz
- findutils-4.7.0.tar.xz
- flex-2.6.4.tar.gz
- gawk-5.1.0.tar.xz
- gcc-10.2.0.tar.xz
- gdbm-1.18.1.tar.gz
- gdbm-.tar.gz
- gettext-0.21.tar.xz
- glibc-2.32-fhs-1.patch
- glibc-2.32.tar.xz
- gmp-6.2.0.tar.xz
- gperf-3.1.tar.gz
- grep-3.4.tar.xz
- groff-1.22.4.tar.gz
- gzip-1.10.tar.xz
- iana-etc-20200821.tar.gz
- inetutils-1.9.4.tar.xz
- intltool-0.51.0.tar.gz
- iproute2-5.8.0.tar.xz
- isl-0.23.tar.xz
- kbd-2.3.0-backspace-1.patch
- kbd-2.3.0.tar.xz
- kmod-27.tar.xz
- less-551.tar.gz
- libcap-2.42.tar.xz
- libffi-3.3.tar.gz
- libpipeline-1.5.3.tar.gz
- libtool-2.4.6.tar.xz
- m4-1.4.18.tar.xz
- make-4.3.tar.gz
- man-db-2.9.3.tar.xz
- man-pages-5.08.tar.xz
- meson-0.55.0.tar.gz
- mpc-1.1.0.tar.gz
- mpfr-4.1.0.tar.xz
- ncurses-6.2.tar.gz
- ninja-1.10.0.tar.gz
- openssl-1.1.1g.tar.gz
- orangepi5-atf.cpio.zst
- orangepi5-linux510-xunlong.cpio.zst
- orangepi5-rkbin-only_rk3588.cpio.zst
- orangepi5-uboot.cpio.zst
- patch-2.7.6.tar.xz
- perl-5.32.0.tar.xz
- pkg-config-0.29.2.tar.gz
- procps-ng-3.3.16.tar.xz
- psmisc-23.3.tar.xz
- pv-1.8.5.tar.gz
- python-3.8.5-docs-html.tar.bz2
- Python-3.8.5.tar.xz
- readline-8.0.tar.gz
- rkdeveloptool.cpio.zst
- sed-4.8.tar.xz
- shadow-4.8.1.tar.xz
- systemd-246.tar.gz
- tar-1.32.tar.xz
- tcl8.6.10-html.tar.gz
- tcl8.6.10-src.tar.gz
- texinfo-6.7.tar.xz
- tzdata2020a.tar.gz
- uboot-v2024.01-rc6.cpio.zst
- util-linux-2.36.tar.xz
- vim-8.2.1361.tar.gz
- XML-Parser-2.46.tar.gz
- xz-5.2.5.tar.xz
- zlib-1.3.1.tar.xz
- zstd-1.4.5.tar.gz
</details>

**So, we can do all jobs offline now.**

***NOTE***: Here is 'tmp/' dir for temporary unpacks & works. Normally this 'tmp/' dir can be exists but it must be empty outside bld process! If it has something inside, then something goes wrong via builds. You can erase this dir outside bld-process at stall stages.

### SDK dirs structure after "make pkg":

- cfg/       - Important catalog of distro configs
- Makefile   - the MAIN BUILD file
- README.md  - the Manual
- .gitignore - it's for repository (not important for you)
- pkg/       - Here are important downloaded files via "make pkg"

### STAGE0: Build all tools on host and initial lfs (45 minutes):

***WARNING***: You need ***VERY GOOD COOLING*** for RK3588 for builds. The chip is very hot due 100% core utilization for long time.

<details>
<summary>"btop" is simple monitor to control temperature...(spoiler)</summary>

    $ sudo apt install btop

Run btop on other window-console to control chip temperature and core-loads.

</details>

To do this stage (**45 minutes** of build) :

    $ time make hst

Repeat-command result:

    $ make hst
    make: Nothing to be done for 'hst'.

<details>
<summary>Allternatively(!) you can do "step-by-step" builds with theese list:</summary>

```
    $ make hst-headers    # produce 'pkg1/lfs-kernel-headers.cpio.zst', install to 'lfs/usr/include'
    $ make hst-binutils1  # 'pkg1/lfs-hst-binutils-2.35.pass1.cpio.zst', install to 'lfs/tools'
    $ make hst-gcc1       # 'pkg1/lfs-hst-gcc-10.2.0.pass1.cpio.zst', install to 'lfs/tools'
    $ make hst-glibc      # 'pkg1/lfs-hst-glibc-2.32.cpio.zst', install to 'lfs'
    $ make hst-libcpp1
    $ make hst-m4
    $ make hst-ncurses
    $ make hst-bash
    $ make hst-coreutils
    $ make hst-diffutils
    $ make hst-file
    $ make hst-findutils
    $ make hst-gawk
    $ make hst-grep
    $ make hst-gzip
    $ make hst-make
    $ make hst-patch
    $ make hst-sed
    $ make hst-tar
    $ make hst-xz
    $ make hst-zstd
    $ make hst-cpio
    $ make hst-pv
    $ make hst-binutils2
    $ make hst-gcc2

Note: There are incremental builds with dependency.

For example "make hst-grep" depends on "make hst-gawk" and its deps on "make hst-findutils" etc.

I.e. any try of theese make automatically builds all above. For more theese packages see to "pkg1".

```
</details>

### How to pack/unpack cpio.zst:

<details>
<summary>Here is some useful info of how to use cpio with zstd</summary>
    
CPIO is ***pipeline*** arc/dearc (unlike to tar), so we need to indicate input&output of pipeline. Here are some examples:

Create input data (example):

    $ mkdir -p ~/cpio-test/dir0/11
    $ echo "Hello0" > ~/cpio-test/dir0/file0.txt
    $ echo "Hello1" > ~/cpio-test/dir0/file1.txt
    $ echo "Hello11" > ~/cpio-test/dir0/11/file11.txt

Create two output dirs:

    $ mkdir -p ~/cpio-test/dir1 && mkdir -p ~/cpio-test/dir2

(A): Pack cpio with zstd-compression example (using "cd" on find and using print0 i.e. null as separator):

    $ cd ~/cpio-test/dir0/
    $ find . -print0 | cpio -0oH newc | zstd -z9T9 > ~/cpio-test/test.cpio.zst
    $ cd ~

Here is we change-dir to sources, then "find"-util find files (at current dir and recursive ".") and produces output-list with zero"0" delimiter (instead of text LF delimiters). Cpio consumes file-list and "-0"(minus zero) option say that file-list is zero delimited. Option "-o" say to cpio produce "output". Option "-H" say type of arc is "newc". Then "zstd" consume input and "-z9"(compression level) and "-T9"(how many threads use in multithread compression). Finally output was redirected to final-file using ">" operand.

(B): Another pack cpio with zstd-compression example (without real "cd" with find as normal lines, and you can stay now in original catalog of invocation):

    $ { cd ~/cpio-test/dir0 && find . | tail -n +2 | cpio -oH newc; } | zstd -z9T9 > ~/cpio-test/test.cpio.zst

Here is we really don't change dir and filenames from find produces as usual lines, but "tail -n +2" used.

(*) Unpack zst-compressed cpio examples (without pv) with preserved-timestamps(1st) or with unpack-time(2nd) :

    $ cat ~/cpio-test/test.cpio.zst | zstd -d | cpio -idumH newc -D ~/cpio-test/dir1/
    $ cat ~/cpio-test/test.cpio.zst | zstd -d | cpio -iduH newc -D ~/cpio-test/dir2/

Please look file-date-timestamps in "dir1" and "dir2".

Here is zstd option "-d" is decompress without indicate threads. It fine works on single thread (see "man zstd").

NOTE1: "cpio -idumH newc" produces files with ***original*** date-timestampes (as is time to packing) - "-m"(option).

NOTE2: "cpio -iduH newc" produces files with date-timestamps ***at extraction time*** (without m-option).

Other cpio options are: "-i"(input) = de-archivate input. Most important option "-d" (create directories if recursive)! Here is "-u" = overwrite output files (very useful if operation was be uncompleted or cancelled during process). Finally "-H newc" = format.

If unpack you can use "pv"(pipe-viewer) instead of "cat" this will show status of progress!

</details>

### Final STAGE0 dirs sctructure:

- cfg/       - Important catalog of distro configs
- Makefile   - the MAIN BUILD file
- README.md  - the Manual
- .gitignore - it's for repository (not important for you)
- pkg/       - Downloaded files via "make pkg"
- lfs/       - Initial LFS rootfs include "tools"-dir
- pkg1/      - Lfs-Host-stage builds cpio.zst-files (only for reference, there are not important)

Now the "tools" dir inside "lfs" - is not required for future steps.

## STAGE1: Chroot-Build initial system inside "other host"

    $ make chroot
    sh-5.0# cd /opt/mysdk
    sh-5.0# make tgt

Here is new "lfs2/"-dir with "/opt/mysdk"-subdir inside.

In any case of error, plese invoke "**make unchroot**" to unbind/unmount dev/proc trees.

**tbd**

