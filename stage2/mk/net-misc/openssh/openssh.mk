SRC+=src/openssh-$(OPENSSH_VER).tar.gz
PKG+=pkg/openssh.cpio.zst
openssh: pkg/openssh.cpio.zst
	cat $< | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
OPENSSH_OPT+= --prefix=/usr
OPENSSH_OPT+= --sysconfdir=/etc/ssh
OPENSSH_OPT+= --with-md5-passwords
OPENSSH_OPT+= --with-privsep-path=/var/lib/sshd
OPENSSH_OPT+= $(OPT_FLAGS)
pkg/openssh.cpio.zst: src/openssh-$(OPENSSH_VER).tar.gz pkg/gzip.cpio.zst
	cat pkg/gzip.cpio.zst | zstd -d | cpio -idumH newc --quiet -D / > /dev/null 2>&1
	rm -fr tmp/openssh
	mkdir -p tmp/openssh/bld
	tar -xzf $< -C tmp/openssh
	cd tmp/openssh/bld && ../openssh-$(OPENSSH_VER)/configure $(OPENSSH_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/openssh/ins/usr/share
ifeq ($(BUILD_STRIP),y)
	strip $(STRIP_BUILD_BIN) tmp/openssh/ins/usr/bin/* || true
	strip $(STRIP_BUILD_BIN) tmp/openssh/ins/usr/sbin/* || true
	strip $(STRIP_BUILD_BIN) tmp/openssh/ins/usr/libexec/* || true
endif
	mkdir -p pkg && cd tmp/openssh/ins && find . -print0 | cpio -o0H newc --quiet | zstd -z9T9 > ../../../$@
	rm -fr tmp/openssh
src/openssh-$(OPENSSH_VER).tar.gz: src/.gitignore
	wget -P src http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz && touch $@
#--no-check-certificate

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

