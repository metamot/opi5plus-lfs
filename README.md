# OrangePi5+ LFS

## Initial Requirements:

Target is : **OrangePi5+** (only - others RK3588-devices are not supported)

Build host is: any RK3588-device with Debian/Ubuntu. I.e. OrangePi5/5b/5+ with Debian11 or Ubuntu22.04. Original "Orange" Debian-11 (Bullseye) XFCE from Xunlong - is highly recomended.

## Clone:

    sudo chmod 777 /opt
    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs

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

NOTE: You can clone repo with another name(!). Here is example for "mydsk".

    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs mysdk

## Setup host (need only once at first run):

For Debian host, we need to choose **bash** instead of dash (say "no" for dash):

    sudo dpkg-reconfigure dash

Show help:

    make

Configure-host (again say "no" for dash):

    make host

## Download packages

    make src

***IMPORTANT!*** After this operation, Please check again that all packages are done at this point ("Repeat-command result"):

    make src
    make: Nothing to be done for 'src'.

## Build:

To build initial LFS (cross-compile tools)

    time make stage0

***TBD***
