# OrangePi5+ LFS

Clone:

    sudo chmod 777 /opt
    cd /opt
    git clone https://github.com/metamot/opi5plus-lfs

**NOTE:** Home-catalog is not suitable for builds. You need to clone directly inside "/opt". Sub-dirs (i.e. /opt/some-dirs/opi5plus-lfs) are not supported.

Show help:

    make

Change dash to bash:

    sudo dpkg-reconfigure dash

Configure-host:

     make host

Download all pkgs

    make pkg
(Do it twice to download all !!!)

Make main ptocess:

    time make stage1 

***TBD***
