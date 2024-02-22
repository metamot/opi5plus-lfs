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

    $ make pkg
    
***IMPORTANT!*** After this operation, Please double check that all packages are done at this point ("Repeat-command result"):

    $ make pkg
    make: Nothing to be done for 'pkg'.

**PLEASE, CHECK IT twice (!)**

NOW BUILD CHROOT-INITIAL STAGE:

    $ time make chroot0

**BUILD TIME: about 2h 8m !!!**

Here is we after point at '8.34. Bash-5.0'.


