# OrangePi5+ LFS

## Initial Requirements:

Target is : **OrangePi5+ with installed eMMC-module**
    
**WARNING**: Opi5+ without eMMC is not supported!

Initial host is : OrangePi5/5b/5+ with Debian11 or Ubuntu22.04.

Original "Orange" Debian-11 (Bullseye) XFCE from Xunlong - is highly recomended.

## Clone:

    sudo chmod 777 /opt
    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs

**NOTE:** Home-catalog is not suitable for builds. You need do clone directly inside to "/opt". Sub-dirs (i.e. /opt/some-dirs/opi5plus-lfs) are not supported.

<details>
  <summary>Why not HOME</summary>
    You can remame "/opt/opiplus-lfs" for example, as "/opt/mysdk" or somthihg else. You can clone to different dir in opt,  as "git clone https://github.com/metamot/opi5plus-lfs my-new-sdk" or somethimg else. You can use different name.
    But you cant create something in "deep" below this.
</details>

## Setup host (need only once at first run):

For Debian host, we need to choose **bash** instead of dash (say "no" for dash):

    sudo dpkg-reconfigure dash

Show help:

    make

Configure-host (again say "no" for dash):

    make host

## Download packages

    make pkg

***IMPORTANT!*** After this operation, Please check again that all packages are done at this point ("Repeat-command result"):

    make pkg
    make: Nothing to be done for 'pkg'.

## Build mmc.img:

    time make stage1 

***TBD***
