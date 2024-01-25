PWD=$(shell pwd)
# Add sync for ESD-touch when Opi5 imidiately shutdown from ESD-touch #SYNC=
SYNC=sync
# How many parrallel jobs? If anything is wrong, pls use only ONE, i.e. "make JOBS=-j1"
JOBS=-j12
#Verbose - default minimal (=0) , set VERB=1 to lots of verbose
VERB=1
# You can create logs if VERB=1 and redirect "1"(stdout) to file and "2"(stderr) to file, like this:
# $ make JOBS=-j1 VERB=1 1>1.txt 2>2.txt
# see 1.txt and 2.txt for more info

# BRD=opi5 # is not supported!
BRD=opi5plus

GIT_RM=y

ifeq ($(BRD),opi5)
UBOOT_DEFCONFIG=uboot_opi5_my_defconfig
else
ifeq ($(BRD),opi5plus)
UBOOT_DEFCONFIG=uboot_opi5plus_my_defconfig
else
$(error BRD is not set as BRD=opi5 or BRD=opi5plus)
endif
endif

UBOOT_VER=v2024.01-rc6

#BL31_FILE=rk3588_bl31_v1.28.elf
BL31_FILE=bl31.elf

#KERNEL_CONFIG=linux-rockchip-rk3588-legacy.config
KERNEL_CONFIG=kernel_my_config

BUSYBOX_CONFIG=busybox_my_config

RK3588_FLAGS = -mcpu=cortex-a76.cortex-a55+crypto
BASE_OPT_VALUE = -Os
BASE_OPT_FLAGS = $(RK3588_FLAGS) $(BASE_OPT_VALUE)
OPT_FLAGS = CFLAGS="$(BASE_OPT_FLAGS)" CPPFLAGS="$(BASE_OPT_FLAGS)" CXXFLAGS="$(BASE_OPT_FLAGS)"

#echo | gcc -mcpu=cortex-a76.cortex-a55+crypto+sve -xc - -o - -S | grep arch

LFS=$(PWD)/lfs
#LFS_HST=aarch64-rk3588-linux-gnu
LFS_TGT=aarch64-rk3588-linux-gnu

all: deps pkg mmc

clean: clean_uboot clean_linux
	rm -fr tmp
clean_uboot:
	rm -fr parts/u-boot/blobs/bl31.elf
	rm -fr parts/u-boot/boot
	rm -fr parts/u-boot/build
	rm -fr parts/u-boot/trusted/build
	rm -fr parts/u-boot/build*
	rm -fr parts/u-boot/*.bin
	rm -fr parts/u-boot/*.img
	rm -fr out/fat/boot.scr
	rm -fr out/fat/orangepiEnv.txt
clean_kernel:
	rm -fr parts/kernel/bld
	rm -fr out/fat/dtb
	rm -fr out/fat/Image
	rm -fr out/rd/kermod
easyclean:
	rm -fr tmp
	rm -fr parts
	rm -fr out
clean_pkg:
	rm -fr pkg
deepclean: easyclean clean_pkg

#help:
#	@echo ""
#	@echo "BRD=$(BRD), UbootCfg=$(UBOOT_DEFCONFIG), jobs=$(JOBS), verbose=$(VERB), cur_prj_dir=$(PWD), opt=$(BASE_OPT_FLAGS)"
#	@echo ""
#	@echo 'make deps                      - Install Hosts-Deps (sudo required)'
#	@echo 'make pkg                       - Download all packages before build'
#	@echo 'WARNING: You need use "make deps" and "make pkg" only once BEFORE start'
#	@echo ""
#	@echo 'make mmc                       - Build "mmc.img"'
#	@echo 'make flash                     - Flash "mmc.img" via USB'
#	@echo 'make write_tst                 - Check for microSD present in slot'
#	@echo 'make write_run                 - Write "mmc.img" microSD'
#	@echo ""
	

# #############################################################################
deps:
	sudo apt install -y zstd u-boot-tools dosfstools libudev-dev libusb-1.0-0-dev dh-autoreconf texinfo libisl23 libisl-dev libgmp-dev libmpc-dev libmpfr-dev gawk gettext swig python-dev-is-python3 python3 python3-pyelftools

chdeps: cfg/host-check.sh deps
	cp -f $< .
	chmod ugo+x host-check.sh
	@echo "=== Checking Host Deps ==="
	./host-check.sh
	./host-check.sh > host-check.txt
	
# #############################################################################







# #############################################################################
# NEW UBOOT
parts/u-boot/uboot-$(UBOOT_VER)/README: pkg/uboot-$(UBOOT_VER).cpio.zst
	mkdir -p parts/u-boot/uboot-$(UBOOT_VER)
	pv $< | zstd -d | cpio -iduH newc -D parts/u-boot/uboot-$(UBOOT_VER)
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" parts/u-boot/uboot-$(UBOOT_VER)/Makefile
	sed -i "s/-march=armv8-a+crc/$(RK3588_FLAGS)/" parts/u-boot/uboot-$(UBOOT_VER)/arch/arm/Makefile
parts/u-boot/bld_mkimage/.config: parts/u-boot/uboot-$(UBOOT_VER)/README
	cp -far cfg/orangepi-5-plus-rk3588_defconfig parts/u-boot/uboot-$(UBOOT_VER)/configs/
	mkdir -p parts/u-boot/bld_mkimage 
	cd parts/u-boot/uboot-$(UBOOT_VER) && make O=../bld_mkimage V=$(VERB) orangepi-5-plus-rk3588_defconfig
parts/u-boot/bld_mkimage/tools/mkimage: parts/u-boot/bld_mkimage/.config
	cd parts/u-boot/uboot-$(UBOOT_VER) && make O=../bld_mkimage V=$(VERB) $(JOBS) tools
parts/u-boot/bld/.config: parts/u-boot/bld_mkimage/tools/mkimage
	cp -far cfg/orangepi-5-plus-rk3588_defconfig parts/u-boot/uboot-$(UBOOT_VER)/configs/
	mkdir -p parts/u-boot/bld
	cd parts/u-boot/uboot-$(UBOOT_VER) && make O=../bld V=$(VERB) orangepi-5-plus-rk3588_defconfig
uboot0: parts/u-boot/bld/.config
#	cd parts/u-boot/uboot-$(UBOOT_VER) && make O=../bld V=$(VERB) spl/u-boot-spl.bin BL31=../blobs/$(BL31_FILE) u-boot.dtb u-boot.itb
	cd parts/u-boot/uboot-$(UBOOT_VER) && make O=../bld V=$(VERB) BL31=../blobs/$(BL31_FILE) ROCKCHIP_TPL=../blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin 1>1.txt 2>2.txt
	
uboot0-clean:
	rm -fr parts/u-boot/uboot-$(UBOOT_VER)
	rm -fr parts/u-boot/bld_mkimage

# #############################################################################
parts/u-boot/v2017.09-rk3588/Makefile: pkg/orangepi5-uboot.cpio.zst
	mkdir -p parts/u-boot/v2017.09-rk3588
	pv pkg/orangepi5-uboot.cpio.zst | zstd -d | cpio -iduH newc -D parts/u-boot/v2017.09-rk3588
	cp -far cfg/$(UBOOT_DEFCONFIG) parts/u-boot/v2017.09-rk3588/configs
	sed -i "s/-march=armv8-a+nosimd/$(RK3588_FLAGS)/" parts/u-boot/v2017.09-rk3588/arch/arm/Makefile
	sed -i "s/-O2/$(BASE_OPT_FLAGS)/" parts/u-boot/v2017.09-rk3588/Makefile
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" parts/u-boot/v2017.09-rk3588/configs/orangepi_5_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" parts/u-boot/v2017.09-rk3588/configs/orangepi_5b_defconfig
	sed -i "s/CONFIG_BOOTDELAY=3/CONFIG_BOOTDELAY=0/" parts/u-boot/v2017.09-rk3588/configs/orangepi_5_plus_defconfig
ifeq ($(UBOOT_DEFCONFIG),uboot_opi5plus_my_defconfig)
# If USB removed -- begin
	sed -i "s/obj-\$$(CONFIG_USB_OHCI_NEW)/# obj-\$$(CONFIG_USB_OHCI_NEW)/" parts/u-boot/v2017.09-rk3588/drivers/usb/host/Makefile
# If USB removed -- end
endif
	sed -i "s/U-Boot SPL board init/U-Boot SPL my board init/" parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/spl.c
parts/u-boot/build_mkimage/.config: parts/u-boot/v2017.09-rk3588/Makefile
	mkdir -p parts/u-boot/build_mkimage
	cd parts/u-boot/v2017.09-rk3588 && make O=../build_mkimage V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- $(UBOOT_DEFCONFIG)
parts/u-boot/build_mkimage/tools/mkimage: parts/u-boot/build_mkimage/.config
	mkdir -p parts/u-boot/build_mkimage
	cd parts/u-boot/v2017.09-rk3588 && make O=../build_mkimage V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- $(JOBS) tools
# #############################################################################
## Uboot BUILD
parts/u-boot/trusted/Makefile: pkg/orangepi5-atf.cpio.zst
	mkdir -p parts/u-boot/trusted
	pv pkg/orangepi5-atf.cpio.zst | zstd -d | cpio -iduH newc -D parts/u-boot/trusted
	sed -i "s/ASFLAGS		+=	\$$(march-directive)/ASFLAGS += $(RK3588_FLAGS)/" parts/u-boot/trusted/Makefile
	sed -i "s/TF_CFLAGS   +=	\$$(march-directive)/TF_CFLAGS += $(RK3588_FLAGS)/" parts/u-boot/trusted/Makefile
parts/u-boot/blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin: pkg/orangepi5-rkbin-only_rk3588.cpio.zst
	mkdir -p parts/u-boot/blobs
	pv pkg/orangepi5-rkbin-only_rk3588.cpio.zst | zstd -d | cpio -iduH newc -D parts/u-boot/blobs
parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/make_fit_atf.sh: parts/u-boot/v2017.09-rk3588/Makefile 
	@echo "... Patch ::: arch/arm/mach-rockchip/make_fit_atf.sh ..."
	sed -i '8s/source .\//source /' $@
parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/fit_nodes.sh: parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/make_fit_atf.sh
	@echo "... Patch ::: arch/arm/mach-rockchip/fit_nodes.sh ..."
	sed -i '9s/source .\//source /' $@
parts/u-boot/build/arch/arm/mach-rockchip/decode_bl31.py: parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/fit_nodes.sh
	@echo "... Patch ::: Copy PY-files ..."
	mkdir -p parts/u-boot/build/arch/arm/mach-rockchip
	cp -far --no-preserve=timestamps parts/u-boot/v2017.09-rk3588/arch/arm/mach-rockchip/*.py parts/u-boot/build/arch/arm/mach-rockchip
parts/u-boot/trusted/build/rk3588/release/bl31/bl31.elf: parts/u-boot/trusted/Makefile
	cd parts/u-boot/trusted && make V=$(VERB) $(JOBS) CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3588 bl31
parts/u-boot/blobs/bl31.elf: parts/u-boot/trusted/build/rk3588/release/bl31/bl31.elf
	ln -sf ../trusted/build/rk3588/release/bl31/bl31.elf $@
parts/u-boot/v2017.09-rk3588/configs/$(UBOOT_DEFCONFIG): parts/u-boot/v2017.09-rk3588/Makefile
	cp -far cfg/$(UBOOT_DEFCONFIG) parts/u-boot/v2017.09-rk3588/configs
	touch $@
parts/u-boot/build/.config: parts/u-boot/build/arch/arm/mach-rockchip/decode_bl31.py parts/u-boot/blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin parts/u-boot/blobs/bl31.elf parts/u-boot/v2017.09-rk3588/configs/$(UBOOT_DEFCONFIG)
	cd parts/u-boot/v2017.09-rk3588 && make O=../build V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- $(UBOOT_DEFCONFIG) && touch ../build/.config
uboot_config: parts/u-boot/build/.config
parts/u-boot/build/spl/u-boot-spl.bin: parts/u-boot/build/.config
	cd parts/u-boot/v2017.09-rk3588 && make O=../build V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- $(JOBS) spl/u-boot-spl.bin && touch ../build/spl/u-boot-spl.bin
parts/u-boot/build/u-boot.itb: parts/u-boot/build/.config parts/u-boot/build/spl/u-boot-spl.bin
	mkdir -p parts/u-boot/build
	cd parts/u-boot/v2017.09-rk3588 && make O=../build V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- $(JOBS) BL31=../blobs/$(BL31_FILE) u-boot.dtb u-boot.itb
parts/u-boot/uboot-head.bin: parts/u-boot/build_mkimage/tools/mkimage parts/u-boot/build/spl/u-boot-spl.bin parts/u-boot/blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin
	$< -n rk3588 -T rksd -d "parts/u-boot/blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin:parts/u-boot/build/spl/u-boot-spl.bin" $@
parts/u-boot/uboot-tail.bin: parts/u-boot/build/u-boot.itb
	ln -sf build/u-boot.itb $@
# Don't use qspi.img if mtd-devices disabled in u-boot !!!
parts/u-boot/qspi.img: parts/u-boot/uboot-head.bin parts/u-boot/uboot-tail.bin
	dd if=/dev/zero of=$@ bs=1M count=0 seek=4
	/sbin/parted -s $@ mklabel gpt
	/sbin/parted -s $@ unit s mkpart idbloader 64 1023
	/sbin/parted -s $@ unit s mkpart uboot 1024 7167
	dd if=parts/u-boot/uboot-head.bin of=$@ seek=64 conv=notrunc
	dd if=parts/u-boot/uboot-tail.bin of=$@ seek=1024 conv=notrunc
out/fat/boot.scr: cfg/uboot_boot.cmd
	mkdir -p out/fat
#	mkimage -C none -A arm -T script -d $< $@
	parts/u-boot/bld_mkimage/tools/mkimage -C none -A arm -T script -d $< $@
#	parts/u-boot/build_mkimage/tools/mkimage -C none -A arm -T script -d boot.cmd $@
#	echo "0x61 0xdf 0x72 0xd7" | xxd -r > parts/u-boot/scr_4bytes.dat
#	dd of=$@ if=parts/u-boot/scr_4bytes.dat bs=1 seek=24 count=4 conv=notrunc
#	dd of=$@ if=/dev/zero bs=1 seek=68 count=4 conv=notrunc
	touch $@
out/fat/orangepiEnv.txt: out/fat/boot.scr
#	cp -far orangepiEnv.txt out/fat/
	echo 'verbosity=1' > $@
	echo 'bootlogo=false' >> $@
	echo 'extraargs=cma=128M' >> $@
	echo 'overlay_prefix=rk3588' >> $@
	echo 'fdtfile=rockchip/rk3588-orangepi-5-plus.dtb' >> $@
	echo 'rootdev=UUID=0b9501f8-db3c-4b33-940a-7fce0931dc2c' >> $@
	touch $@
uboot: parts/u-boot/uboot-head.bin parts/u-boot/uboot-tail.bin out/fat/orangepiEnv.txt

### Linux Out-Of-Src-Tree-BUILD

parts/kernel/src/MAINTAINERS: pkg/orangepi5-linux510-xunlong.cpio.zst
	mkdir -p parts/kernel/src
	pv pkg/orangepi5-linux510-xunlong.cpio.zst | zstd -d | cpio -iduH newc -D parts/kernel/src
	sed -i "s/include \$$(TopDIR)\/drivers\/net\/wireless\/rtl88x2cs\/rtl8822c.mk/include \$$(src)\/rtl8822c.mk/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(BCMDHD_ROOT)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rkwifi\/bcmdhd\/include/" parts/kernel/src/drivers/net/wireless/rockchip_wlan/rkwifi/bcmdhd/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/include/" parts/kernel/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/platform/" parts/kernel/src/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be\/core\/crypto/" parts/kernel/src/drivers/net/wireless/rockchip_wlan/rtl8852be/common.mk
	sed -i "s/phl_path_d1 := \$$(src)/phl_path_d1 := \$$(src)\/..\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rockchip_wlan\/rtl8852be/" parts/kernel/src/drivers/net/wireless/rockchip_wlan/rtl8852be/phl/phl.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/include/" parts/kernel/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/platform/" parts/kernel/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8189es/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8189es/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189es\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8189es/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/include/" parts/kernel/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/platform/" parts/kernel/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8189fs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8189fs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8189fs\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8189fs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/include/" parts/kernel/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/platform/" parts/kernel/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8192eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8192eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8192eu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8192eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/include/" parts/kernel/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/platform/" parts/kernel/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8812au/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8812au/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8812au\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8812au/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/include/" parts/kernel/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/platform/" parts/kernel/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8811cu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8811cu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8811cu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/include/" parts/kernel/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/platform/" parts/kernel/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8188eu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8188eu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8188eu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8188eu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/include/" parts/kernel/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/platform/" parts/kernel/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl88x2bu/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl88x2bu/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2bu\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl88x2bu/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/include/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/platform/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/core\/crypto/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/core\/crypto/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl88x2cs\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl88x2cs/hal/phydm/sd4_phydm_2_kernel.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/include/" parts/kernel/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/platform/" parts/kernel/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723ds\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8723ds/Makefile
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/include/" parts/kernel/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/platform/" parts/kernel/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal/" parts/kernel/src/drivers/net/wireless/rtl8723du/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8723du\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8723du/hal/phydm/phydm.mk
	sed -i "s/-I\$$(src)\/include/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/include/" parts/kernel/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/platform/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/platform/" parts/kernel/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/btc/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/btc/" parts/kernel/src/drivers/net/wireless/rtl8822bs/Makefile
	sed -i "s/-I\$$(src)\/hal\/phydm/-I\$$(src)\/..\/..\/..\/..\/..\/src\/drivers\/net\/wireless\/rtl8822bs\/hal\/phydm/" parts/kernel/src/drivers/net/wireless/rtl8822bs/hal/phydm/phydm.mk
pkg/linux_src4bld_rtl8852be.cpio.zst: parts/kernel/src/MAINTAINERS
	mkdir -p tmp
	cp -far parts/kernel/src/drivers/net/wireless/rockchip_wlan/rtl8852be tmp/
	cd tmp/rtl8852be && find . -name "*.c" -type f -delete
	cd tmp/rtl8852be && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../$@
	rm -fr tmp/rtl8852be
parts/kernel/bld/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile: pkg/linux_src4bld_rtl8852be.cpio.zst
	mkdir -p parts/kernel/bld/drivers/net/wireless/rockchip_wlan/rtl8852be
	pv pkg/linux_src4bld_rtl8852be.cpio.zst | zstd -d | cpio -iduH newc -D parts/kernel/bld/drivers/net/wireless/rockchip_wlan/rtl8852be
parts/kernel/bld/.config: cfg/$(KERNEL_CONFIG) parts/kernel/bld/drivers/net/wireless/rockchip_wlan/rtl8852be/Makefile
	mkdir -p parts/kernel/bld	
	cp -far $< $@ && touch $@
	
	
parts/kernel/bld/Makefile: parts/kernel/bld/.config
#	cd parts/kernel/src && make O=../bld V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 EXTRAVERSION=$(KERNAM) olddefconfig && cd ../../ && touch $@
	cd parts/kernel/src && make O=../bld V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 olddefconfig
kernel_config: parts/kernel/bld/Makefile
out/fat/Image: parts/kernel/bld/Makefile
	mkdir -p out/fat/dtb
	mkdir -p out/rd/kermod
	cd parts/kernel/src && make O=../bld $(JOBS) V=$(VERB) KCFLAGS="$(RK3588_FLAGS)" CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 dtbs && make O=../bld $(JOBS) V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 INSTALL_DTBS_PATH=../../../out/fat/dtb dtbs_install && make O=../bld $(JOBS) V=$(VERB) KCFLAGS="$(RK3588_FLAGS)" CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 Image && make O=../bld $(JOBS) V=$(VERB) KCFLAGS="$(RK3588_FLAGS)" CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 modules && make O=../bld $(JOBS) V=$(VERB) CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 INSTALL_MOD_PATH=../../../out/rd/kermod modules_install 
	cp -far parts/kernel/bld/arch/arm64/boot/Image out/fat/
	touch $@
	
	
kernel: out/fat/Image


# === KERNEL HEADERS
$(LFS)/usr/include/asm/ioctl.h: parts/kernel/src/MAINTAINERS
	mkdir -pv $(LFS)/usr/include
	mkdir -pv $(LFS)/usr/lib
	cd $(LFS)/usr && ln -fsv lib lib64
	cd $(LFS) && ln -fsv usr/lib lib
	cd $(LFS) && ln -fsv usr/lib lib64
	mkdir -pv $(LFS)/usr/bin
	cd $(LFS) && ln -fsv usr/bin bin
	mkdir -pv $(LFS)/usr/sbin
	cd $(LFS) && ln -fsv usr/sbin sbin
	mkdir -pv $(LFS)/usr/etc/opt
	mkdir -pv $(LFS)/usr/etc/sysconfig
	cd $(LFS) && ln -fsv usr/etc etc
	mkdir -pv $(LFS)/usr/var/cache
	mkdir -pv $(LFS)/usr/var/local
	mkdir -pv $(LFS)/usr/var/log
	mkdir -pv $(LFS)/usr/var/mail
	mkdir -pv $(LFS)/usr/var/opt
	mkdir -pv $(LFS)/usr/var/spool
	mkdir -pv $(LFS)/usr/var/lib/color
	mkdir -pv $(LFS)/usr/var/lib/misc
	mkdir -pv $(LFS)/usr/var/lib/locate
	cd $(LFS) && ln -fsv usr/var var
	mkdir -pv $(LFS)/usr/src
	mkdir -pv $(LFS)/usr/lib/firmware
	mkdir -pv $(LFS)/usr/local/bin
	mkdir -pv $(LFS)/usr/local/include
	mkdir -pv $(LFS)/usr/local/lib
	mkdir -pv $(LFS)/usr/local/sbin
	mkdir -pv $(LFS)/usr/local/src
	mkdir -pv $(LFS)/usr/share/color
	mkdir -pv $(LFS)/usr/share/dict
	mkdir -pv $(LFS)/usr/share/doc
	mkdir -pv $(LFS)/usr/share/info
	mkdir -pv $(LFS)/usr/share/locale
	mkdir -pv $(LFS)/usr/share/man/man1
	mkdir -pv $(LFS)/usr/share/man/man2
	mkdir -pv $(LFS)/usr/share/man/man3
	mkdir -pv $(LFS)/usr/share/man/man4
	mkdir -pv $(LFS)/usr/share/man/man5
	mkdir -pv $(LFS)/usr/share/man/man6
	mkdir -pv $(LFS)/usr/share/man/man7
	mkdir -pv $(LFS)/usr/share/man/man8
	mkdir -pv $(LFS)/usr/share/misc
	mkdir -pv $(LFS)/usr/share/terminfo
	mkdir -pv $(LFS)/usr/share/zoneinfo
	mkdir -pv $(LFS)/usr/local/share/color
	mkdir -pv $(LFS)/usr/local/share/dict
	mkdir -pv $(LFS)/usr/local/share/doc
	mkdir -pv $(LFS)/usr/local/share/info
	mkdir -pv $(LFS)/usr/local/share/locale
	mkdir -pv $(LFS)/usr/local/share/man/man1
	mkdir -pv $(LFS)/usr/local/share/man/man2
	mkdir -pv $(LFS)/usr/local/share/man/man3
	mkdir -pv $(LFS)/usr/local/share/man/man4
	mkdir -pv $(LFS)/usr/local/share/man/man5
	mkdir -pv $(LFS)/usr/local/share/man/man6
	mkdir -pv $(LFS)/usr/local/share/man/man7
	mkdir -pv $(LFS)/usr/local/share/man/man8
	mkdir -pv $(LFS)/usr/local/share/misc
	mkdir -pv $(LFS)/usr/local/share/terminfo
	mkdir -pv $(LFS)/usr/local/share/zoneinfo
	mkdir -pv $(LFS)/usr/boot
	cd $(LFS) && ln -fsv usr/boot boot
	mkdir -pv $(LFS)/usr/home
	cd $(LFS) && ln -fsv usr/home home
	mkdir -pv $(LFS)/usr/mnt
	cd $(LFS) && ln -fsv usr/mnt mnt
	mkdir -pv $(LFS)/usr/opt
	cd $(LFS) && ln -fsv usr/opt opt
	mkdir -pv $(LFS)/usr/srv
	cd $(LFS) && ln -fsv usr/srv srv
	mkdir -pv $(LFS)/usr/media/floppy
	mkdir -pv $(LFS)/usr/media/cdrom
	cd $(LFS) && ln -fsv usr/media media
	mkdir -pv $(LFS)/dev
	mkdir -pv $(LFS)/proc
	mkdir -pv $(LFS)/sys
	mkdir -pv $(LFS)/run
	cd parts/kernel/src && make O=../bld $(JOBS) V=$(VERB) ARCH=arm64 INSTALL_HDR_PATH=$(LFS)/usr headers_install && touch ../../../lfs/usr/include/asm/ioctl.h
#kernel_hdrs: $(LFS)/usr/include/asm/ioctl.h


parts/busybox/src/Makefile:
	mkdir -p parts/busybox/src
	pv pkg/busybox.cpio.zst | zstd -d | cpio -iduH newc -D parts/busybox/src
	@echo ""
	@echo "=== Patching BUSYBOX ==="
	find parts/busybox/src -name "*.h" -exec sed -i "s/\/etc\//\/aetc\//g" {} +
	find parts/busybox/src -name "*.c" -exec sed -i "s/\/etc\//\/aetc\//g" {} +
	find parts/busybox/src -name "*.h" -exec sed -i "s/\/bin\//\/abin\//g" {} +
	find parts/busybox/src -name "*.c" -exec sed -i "s/\/bin\//\/abin\//g" {} +
#	sed -i "s/\/etc\/inittab/\/inittab/" parts/busybox/src/init/init.c
#	sed -i "s/\/bin\/login/\/login/" parts/busybox/src/loginutils/getty.c
#	sed -i "s/\/etc\/issue/\/issue/" parts/busybox/src/loginutils/getty.c
#	sed -i "s/\/bin\/login/\/login/" parts/busybox/src/networking/telnetd.c
#	sed -i "s/\/etc\/issue/\/issue/" parts/busybox/src/networking/telnetd.c

parts/busybox/bld/.config: cfg/$(BUSYBOX_CONFIG) parts/busybox/src/Makefile
	mkdir -p parts/busybox/bld
	cp -far $< parts/busybox/bld/.config && touch $@

parts/busybox/bld/busybox: parts/busybox/bld/.config
	cd parts/busybox/bld && make $(JOBS) V=$(VERB) CFLAGS="$(BASE_OPT_FLAGS)" KBUILD_SRC=../src -f ../src/Makefile

# echo 0 > /sys/class/graphics/fb0/blank

out/rd/abin/busybox: parts/busybox/bld/busybox
	mkdir -p out/rd/abin
	cp -far $< $@ && touch $@
	cd out/rd && ln -sf /abin/busybox init
	mkdir -p out/rd/aetc/init.d
	cd out/rd && mkdir -p usr
	cd out/rd && ln -sf /usr/bin bin
	cd out/rd && ln -sf /usr/sbin sbin
	cd out/rd && ln -sf /usr/lib lib
	cd out/rd && ln -sf /usr/etc etc
	cd out/rd && ln -sf /usr/var var
	cd out/rd && ln -sf /usr/opt opt
	cd out/rd && mkdir -p boot
	cd out/rd && mkdir -p tmp
	cd out/rd && mkdir -p run
#	cd out/rd && mkdir -p opt
#	cd out/rd && mkdir -p mnt
#	cd out/rd && mkdir -p media
#	cd out/rd && mkdir -p home
#	cd out/rd && ln -sf /usr/var var
#	cd out/rd && ln -sf /usr/root root
#	cd out/rd && ln -sf /usr/etc etc
#	cd out/rd && ln -sf /usr/lib64 lib64
	cd out/rd/abin && ln -sf busybox login && ln -sf busybox getty && ln -sf busybox sh && ln -sf busybox ash && ln -sf busybox sync && ln -sf busybox false && ln -sf busybox [ && ln -sf busybox [[
	
#	&& ln -sf busybox poweroff && ln -sf busybox reboot && ln -sf busybox cat && ln -sf busybox mount && ln -sf busybox echo && ln -sf busybox mkdir && ln -sf busybox passwd && ln -sf busybox ls && ln -sf busybox who && ln -sf busybox whoami && ln -sf busybox dd && ln -sf busybox vi  && ln -sf busybox df && ln -sf busybox du && ln -sf busybox modprobe && ln -sf busybox fdisk && ln -sf busybox ps && ln -sf busybox pstree && ln -sf busybox less && ln -sf busybox hexdump

out/rd/aetc/issue: out/rd/abin/busybox
	cp -far cfg/issue out/rd/aetc/ && touch $@

out/rd/aetc/inittab: out/rd/aetc/issue
#
	echo "::sysinit:/abin/busybox mkdir /sys" > $@
	echo "::sysinit:/abin/busybox mount -t sysfs -o nodev,noexec,nosuid sysfs /sys" >> $@
	echo "::sysinit:/abin/busybox mkdir /proc" >> $@
	echo "::sysinit:/abin/busybox mount -t proc -o nodev,noexec,nosuid proc /proc" >> $@
	echo "::sysinit:/abin/busybox mount -t devtmpfs -o nosuid,mode=0755 udev /dev" >> $@
	echo "::sysinit:/abin/busybox mkdir /dev/pts" >> $@
	echo "::sysinit:/abin/busybox mount -t devpts -o noexec,nosuid,gid=5,mode=0620 devpts /dev/pts" >> $@
	echo "::sysinit:/aetc/init.d/rcS" >> $@
	echo "::respawn:-/abin/sh" >> $@
	echo "ttyFIQ0::respawn:/abin/getty -L -f 0 1500000 ttyFIQ0 vt100" >> $@
	echo "::ctrlaltdel:/abin/busybox poweroff" >> $@
#
	echo '#!/abin/sh' > out/rd/aetc/init.d/rcS
	echo 'for x in $$(/abin/busybox cat /proc/cmdline); do' >> out/rd/aetc/init.d/rcS
	echo '  case $$x in' >> out/rd/aetc/init.d/rcS
	echo '  myboot=*)' >> out/rd/aetc/init.d/rcS
	echo '    BOOT_DEV=$${x#myboot=}' >> out/rd/aetc/init.d/rcS
	echo '    BOOT_DEV_NAME=/dev/mmcblk$${BOOT_DEV}' >> out/rd/aetc/init.d/rcS
	echo '    /abin/busybox echo "BOOT_DEV_NAME = $${BOOT_DEV_NAME}"' >> out/rd/aetc/init.d/rcS
	echo '    ;;' >> out/rd/aetc/init.d/rcS
	echo '  esac' >> out/rd/aetc/init.d/rcS
	echo 'done' >> out/rd/aetc/init.d/rcS
	echo 'if [ $${BOOT_DEV} = "0" ]' >> out/rd/aetc/init.d/rcS
	echo 'then' >> out/rd/aetc/init.d/rcS
	echo '   BOOT_DEV_TYPE=microSD' >> out/rd/aetc/init.d/rcS
	echo 'else' >> out/rd/aetc/init.d/rcS
	echo '   BOOT_DEV_TYPE=eMMC' >> out/rd/aetc/init.d/rcS
	echo '   /abin/busybox mount /dev/mmcblk$${BOOT_DEV}p1 /boot' >> out/rd/aetc/init.d/rcS
	echo '   /abin/busybox mount /dev/mmcblk$${BOOT_DEV}p2 /usr' >> out/rd/aetc/init.d/rcS
	echo 'fi' >> out/rd/aetc/init.d/rcS
	echo '/abin/busybox echo "BOOT_DEV_TYPE = $${BOOT_DEV_TYPE}"' >> out/rd/aetc/init.d/rcS
#	echo '/busybox echo emmc=/dev/mmcblk`/busybox ls /dev/mmcblk*boot0 | /busybox cut -c12-12`' >> out/rd/aetc/init.d/rcS
#	echo '/busybox echo microsd=/dev/mmcblk`/busybox ls /dev/mmcblk*boot0 | /busybox cut -c12-12 | /busybox tr 01 10`' >> out/rd/aetc/init.d/rcS
#	echo '/busybox mkdir -p /mnt/emmc' >> out/rd/aetc/init.d/rcS
#	echo '/busybox mkdir -p /mnt/microsd' >> out/rd/aetc/init.d/rcS
#	echo '/busybox mount -a -T /fstab' >> out/rd/aetc/init.d/rcS
#	echo '/busybox ls /sys/bus/mmc/devices' >> out/rd/aetc/init.d/rcS
#	echo '/busybox ln -sf /proc/self/fd /dev/fd' >> out/rd/aetc/init.d/rcS
#	echo '/busybox ln -sf /proc/self/fd/0 /dev/stdin' >> out/rd/aetc/init.d/rcS
#	echo '/busybox ln -sf /proc/self/fd/1 /dev/stdout' >> out/rd/aetc/init.d/rcS
#	echo '/busybox ln -sf /proc/self/fd/2 /dev/stderr' >> out/rd/aetc/init.d/rcS
	chmod ugo+x out/rd/aetc/init.d/rcS
#
	echo 'export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"' > out/rd/aetc/profile
	echo '/abin/busybox cat /aetc/issue' >> out/rd/aetc/profile
#
	echo "/abin/ash" > out/rd/aetc/shells
	echo "/abin/sh" >> out/rd/aetc/shells
#
	echo "root:x:0:" > out/rd/aetc/group
	echo "daemon:x:1:" >> out/rd/aetc/group
	echo "bin:x:2:" >> out/rd/aetc/group
	echo "sys:x:3:" >> out/rd/aetc/group
	echo "adm:x:4:" >> out/rd/aetc/group
	echo "tty:x:5:" >> out/rd/aetc/group
	echo "disk:x:6:" >> out/rd/aetc/group
	echo "lp:x:7:" >> out/rd/aetc/group
	echo "mail:x:8:" >> out/rd/aetc/group
	echo "kmem:x:9:" >> out/rd/aetc/group
	echo "wheel:x:10:root" >> out/rd/aetc/group
	echo "cdrom:x:11:" >> out/rd/aetc/group
	echo "dialout:x:18:" >> out/rd/aetc/group
	echo "floppy:x:19:" >> out/rd/aetc/group
	echo "video:x:28:" >> out/rd/aetc/group
	echo "audio:x:29:" >> out/rd/aetc/group
	echo "tape:x:32:" >> out/rd/aetc/group
	echo "www-data:x:33:" >> out/rd/aetc/group
	echo "operator:x:37:" >> out/rd/aetc/group
	echo "utmp:x:43:" >> out/rd/aetc/group
	echo "plugdev:x:46:" >> out/rd/aetc/group
	echo "staff:x:50:" >> out/rd/aetc/group
	echo "lock:x:54:" >> out/rd/aetc/group
	echo "netdev:x:82:" >> out/rd/aetc/group
	echo "users:x:100:" >> out/rd/aetc/group
	echo "nobody:x:65534:" >> out/rd/aetc/group
#
	echo "root::0:0:root:/root:/abin/sh" > out/rd/aetc/passwd
#	echo "daemon:x:1:1:daemon:/usr/sbin:/bin/false" >> out/rd/aetc/passwd
	echo "bin:x:2:2:bin:/abin:/abin/false" >> out/rd/aetc/passwd
	echo "sys:x:3:3:sys:/dev:/abin/false" >> out/rd/aetc/passwd
	echo "sync:x:4:100:sync:/abin:/abin/sync" >> out/rd/aetc/passwd
#	echo "mail:x:8:8:mail:/var/spool/mail:/bin/false" >> out/rd/aetc/passwd
#	echo "www-data:x:33:33:www-data:/var/www:/bin/false" >> out/rd/aetc/passwd
#	echo "operator:x:37:37:Operator:/var:/bin/false" >> out/rd/aetc/passwd
	echo "nobody:x:65534:65534:nobody:/home:/abin/false" >> out/rd/aetc/passwd
#
	echo "root::19701::::::" > out/rd/aetc/shadow
	echo "daemon:*:::::::" >> out/rd/aetc/shadow
	echo "bin:*:::::::" >> out/rd/aetc/shadow
	echo "sys:*:::::::" >> out/rd/aetc/shadow
	echo "sync:*:::::::" >> out/rd/aetc/shadow
	echo "mail:*:::::::" >> out/rd/aetc/shadow
	echo "www-data:*:::::::" >> out/rd/aetc/shadow
	echo "operator:*:::::::" >> out/rd/aetc/shadow
	echo "nobody:*:::::::" >> out/rd/aetc/shadow

out/fat/uInitrd: out/rd/aetc/inittab
	mkdir -p out/fat
	cd out/rd && find . -print | cpio -oH newc | gzip > ../Initrd
	mkimage -A arm64 -O linux -T ramdisk -C gzip -n uInitrd -d out/Initrd out/fat/uInitrd
	rm -fr out/Initrd
	
# mmc-fat = 190MiB = 389120 blks
out/mmc-fat.bin: out/fat/boot.scr out/fat/orangepiEnv.txt out/fat/Image out/fat/uInitrd
	mkdir -p tmp/mnt
	dd of=$@ if=/dev/zero bs=1M count=0 seek=190
	/sbin/mkfs.fat -F 32 -n "opi_boot" -i A77ACF93 $@
	sudo mount $@ tmp/mnt/
	sudo cp --force --no-preserve=all --recursive out/fat/* tmp/mnt/
	sudo umount $@
	rm -fr tmp/mnt/

out/mmc-ext4.bin: $(LFS)/usr/opt/mysdk/Makefile
	mkdir -p tmp/mnt
	dd of=$@ if=/dev/zero bs=1G count=0 seek=5
	/sbin/mke2fs -t ext4 -L lfs $@
	sudo mount $@ tmp/mnt/
	sudo cp -far lfs/usr/* tmp/mnt/
	sudo umount $@
	rm -fr tmp/mnt/
	
out/mmc.img: parts/u-boot/uboot-head.bin parts/u-boot/uboot-tail.bin out/mmc-fat.bin
	dd of=$@ if=/dev/zero bs=1M count=0 seek=201
#	dd of=$@ if=/dev/zero bs=1G count=0 seek=6
	dd of=$@ if=parts/u-boot/uboot-head.bin seek=64 conv=notrunc
	dd of=$@ if=parts/u-boot/uboot-tail.bin seek=16384 conv=notrunc
	dd of=$@ if=out/mmc-fat.bin seek=20480 conv=notrunc
#	dd of=$@ if=out/mmc-ext4.bin seek=409600 conv=notrunc status=progress
#	dd of=$@ if=out/mmc-ext4.bin bs=1M seek=200 conv=notrunc status=progress
	/sbin/parted -s $@ mklabel gpt
	/sbin/parted -s $@ unit s mkpart bootfs 20480 409599
#	/sbin/parted -s $@ unit s mkpart bootfs 409600 10895359

mmc: out/mmc.img

parts/rkdeveloptool/src/main.cpp: pkg/rkdeveloptool.cpio.zst
	mkdir -p parts/rkdeveloptool/src
	pv pkg/rkdeveloptool.cpio.zst | zstd -d | cpio -iduH newc -D parts/rkdeveloptool/src

parts/rkdeveloptool/src/cfg/compile:parts/rkdeveloptool/src/main.cpp
	cd parts/rkdeveloptool/src && autoreconf -i

parts/rkdeveloptool/bld/Makefile: parts/rkdeveloptool/src/cfg/compile
	mkdir -p parts/rkdeveloptool/bld
	cd parts/rkdeveloptool/bld && ../src/configure CXXFLAGS="$(BASE_OPT_FLAGS)"

parts/rkdeveloptool/bld/rkdeveloptool: parts/rkdeveloptool/bld/Makefile
	cd parts/rkdeveloptool/bld && make $(JOBS) V=$(VERB)

out/rkdeveloptool: parts/rkdeveloptool/bld/rkdeveloptool
	mkdir -p out
	cp -far $< $@
	strip --strip-all $@

parts/u-boot/blobs/rk3588_spl_loader_v1.08.111.bin: parts/u-boot/blobs/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin

out/usb_loader.bin: parts/u-boot/blobs/rk3588_spl_loader_v1.08.111.bin
	mkdir -p out
	cd out && ln -sf ../parts/u-boot/blobs/rk3588_spl_loader_v1.08.111.bin usb_loader.bin

rkdeveloptool: out/rkdeveloptool out/usb_loader.bin

flash: out/mmc.img out/rkdeveloptool out/usb_loader.bin
	@echo "Connect usb-target, enter in maskrom, and press ENTER to continue"
	@read line
	cd out && sudo ./rkdeveloptool db usb_loader.bin && sudo ./rkdeveloptool wl 0 mmc.img && sudo ./rkdeveloptool rd 0


write_tst: out/mmc.img
#	@echo `ls /dev/mmcblk*boot0 | cut -c-12 | tr 01 10`
	@echo "Insert microSD to slot, and press ENTER to continue"
	@read line
	sudo dd if=`ls /dev/mmcblk*boot0 | cut -c-12 | tr 01 10` count=1 | hexdump -C


write_run: out/mmc.img
	@echo "Here is dev eMMC"
	ls /dev/mmcblk*boot0
	ls /dev/mmcblk*boot0 | cut -c-12
	@echo 'INFO: /dev/mmcblk*boot0 - is emmc, but "cut&tr" invert number for microSD'
	@echo "Here is dev microSD"
	ls /dev/mmcblk*boot0 | cut -c-12 | tr 01 10
	@echo ""
	@echo "Insert microSD (`ls /dev/mmcblk*boot0 | cut -c-12 | tr 01 10`) to slot, and press ENTER to continue."
	@echo 'If unsure, press Ctrl+C now !'
	@echo 'Check "lsblk" or use "make write_tst" for read only card test !'
	@echo 'If really sure, press ENTER...'
	@read line
	sudo dd if=out/mmc.img of=`ls /dev/mmcblk*boot0 | cut -c-12 | tr 01 10` bs=1M status=progress && sudo sync





# ============================= LFS

LFS_VER=10.0
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd

# Packages versions:
ACL_VER=2.2.53
ATTR_VER=2.4.48
AUTOCONF_VER=2.69
AUTOMAKE_VER=1.16.2
BASH_VER=5.0
BC_VER=3.1.5
BINUTILS_VER=2.35
BISON_VER=3.7.1
BZIP2_VER=1.0.8
CHECK_VER=0.15.2
CORE_UTILS_VER=8.32
CPIO_VER=2.13
DBUS_VER=1.12.20
DEJAGNU_VER=1.6.2
DIFF_UTILS_VER=3.7
E2FSPROGS_VER=1.45.6
ELF_UTILS_VER=0.180
# EXPAT_VER=2.2.9
# ^^^ is unaviable now(01.01.24) for download. Original expat-site say to replace it with 2.5.0.
EXPAT_VER=2.5.0
EXPECT_VER=5.45.4
FILE_VER=5.39
FIND_UTILS_VER=4.7.0
FLEX_VER=2.6.4
GAWK_VER=5.1.0
GCC_VER=10.2.0
GDBM_VER=1.18.1
GETTEXT_VER=0.21
GLIBC_VER=2.32
GMP_VER=6.2.0
GPERF_VER=3.1
GREP_VER=3.4
GROFF_VER=1.22.4
GZIP_VER=1.10
IANA_ETC_VER=20200821
INET_UTILS_VER=1.9.4
INTL_TOOL_VER=0.51.0
IP_ROUTE2_VER=5.8.0
ISL_VER=0.23
KBD_VER=2.3.0
KMOD_VER=27
LESS_VER=551
LIBCAP_VER=2.42
LIBFFI_VER=3.3
LIBPIPILINE_VER=1.5.3
LIBTOOL_VER=2.4.6
M4_VER=1.4.18
MAKE_VER=4.3
MAN_DB_VER=2.9.3
MAN_PAGES_VER=5.08
MESON_VER=0.55.0
MPC_VER=1.1.0
MPFR_VER=4.1.0
NCURSES_VER=6.2
NINJA_VER=1.10.0
OPEN_SSL_VER=1.1.1g
PATCH_VER=2.7.6
PERL_VER=5.32.0
PERL_VER0=5.32
PKG_CONFIG_VER=0.29.2
PROCPS_VER=3.3.16
PSMISC_VER=23.3
PV_VER=1.8.5
PYTHON_VER=3.8.5
PYTHON_DOC_VER=$(PYTHON_VER)
READLINE_VER=8.0
SED_VER=4.8
SHADOW_VER=4.8.1
SYSTEMD_VER=246
TAR_VER=1.32
TCL_VER=8.6.10
TCL_VER_BRIEF=8.6
TCL_DOC_VER=$(TCL_VER)
TEXINFO_VER=6.7
TIME_ZONE_DATA_VER=2020a
UTIL_LINUX_VER=2.36
VIM_VER=8.2.1361
XML_PARSER_VER=2.46
XZ_VER=5.2.5
#ZLIB_VER=1.2.11
#ZLIB_VER=1.3
ZLIB_VER=1.3.1
ZSTD_VER=1.4.5

# Incremental rule for download:

PKG+=pkg/glibc-$(GLIBC_VER)-fhs-1.patch
PKG+=pkg/bash-$(BASH_VER)-upstream_fixes-1.patch
PKG+=pkg/bzip2-$(BZIP2_VER)-install_docs-1.patch
PKG+=pkg/coreutils-$(CORE_UTILS_VER)-i18n-1.patch
PKG+=pkg/kbd-$(KBD_VER)-backspace-1.patch
PKG+=pkg/acl-$(ACL_VER).tar.gz
PKG+=pkg/attr-$(ATTR_VER).tar.gz
PKG+=pkg/autoconf-$(AUTOCONF_VER).tar.xz
PKG+=pkg/automake-$(AUTOMAKE_VER).tar.xz
PKG+=pkg/bash-$(BASH_VER).tar.gz
PKG+=pkg/bc-$(BC_VER).tar.xz
PKG+=pkg/binutils-$(BINUTILS_VER).tar.xz
PKG+=pkg/bison-$(BISON_VER).tar.xz	
PKG+=pkg/bzip2-$(BZIP2_VER).tar.gz
PKG+=pkg/check-$(CHECK_VER).tar.gz
PKG+=pkg/coreutils-$(CORE_UTILS_VER).tar.xz
PKG+=pkg/cpio-$(CPIO_VER).tar.bz2
PKG+=pkg/dbus-$(DBUS_VER).tar.gz
PKG+=pkg/dejagnu-$(DEJAGNU_VER).tar.gz
PKG+=pkg/diffutils-$(DIFF_UTILS_VER).tar.xz
PKG+=pkg/e2fsprogs-$(E2FSPROGS_VER).tar.gz
PKG+=pkg/elfutils-$(ELF_UTILS_VER).tar.bz2
PKG+=pkg/expat-$(EXPAT_VER).tar.xz
PKG+=pkg/expect$(EXPECT_VER).tar.gz
PKG+=pkg/file-$(FILE_VER).tar.gz
PKG+=pkg/findutils-$(FIND_UTILS_VER).tar.xz
PKG+=pkg/flex-$(FLEX_VER).tar.gz
PKG+=pkg/gawk-$(GAWK_VER).tar.xz
PKG+=pkg/gcc-$(GCC_VER).tar.xz
PKG+=pkg/gdbm-$(DBM_VER).tar.gz
PKG+=pkg/gettext-$(GETTEXT_VER).tar.xz
PKG+=pkg/glibc-$(GLIBC_VER).tar.xz
PKG+=pkg/gmp-$(GMP_VER).tar.xz
PKG+=pkg/gperf-$(GPERF_VER).tar.gz
PKG+=pkg/grep-$(GREP_VER).tar.xz
PKG+=pkg/groff-$(GROFF_VER).tar.gz
PKG+=pkg/gzip-$(GZIP_VER).tar.xz
PKG+=pkg/iana-etc-$(IANA_ETC_VER).tar.gz
PKG+=pkg/inetutils-$(INET_UTILS_VER).tar.xz
PKG+=pkg/intltool-$(INTL_TOOL_VER).tar.gz
PKG+=pkg/iproute2-$(IP_ROUTE2_VER).tar.xz
PKG+=pkg/isl-$(ISL_VER).tar.xz
PKG+=pkg/kbd-$(KBD_VER).tar.xz
PKG+=pkg/kmod-$(KMOD_VER).tar.xz
PKG+=pkg/less-$(LESS_VER).tar.gz
PKG+=pkg/libcap-$(LIBCAP_VER).tar.xz
PKG+=pkg/libffi-$(LIBFFI_VER).tar.gz
PKG+=pkg/libpipeline-$(LIBPIPILINE_VER).tar.gz
PKG+=pkg/libtool-$(LIBTOOL_VER).tar.xz
PKG+=pkg/m4-$(M4_VER).tar.xz
PKG+=pkg/make-$(MAKE_VER).tar.gz
PKG+=pkg/man-db-$(MAN_DB_VER).tar.xz
PKG+=pkg/man-pages-$(MAN_PAGES_VER).tar.xz
PKG+=pkg/meson-$(MESON_VER).tar.gz
PKG+=pkg/mpc-$(MPC_VER).tar.gz
PKG+=pkg/mpfr-$(MPFR_VER).tar.xz
PKG+=pkg/ncurses-$(NCURSES_VER).tar.gz
PKG+=pkg/ninja-$(NINJA_VER).tar.gz
PKG+=pkg/openssl-$(OPEN_SSL_VER).tar.gz
PKG+=pkg/patch-$(PATCH_VER).tar.xz
PKG+=pkg/perl-$(PERL_VER).tar.xz
PKG+=pkg/pkg-config-$(PKG_CONFIG_VER).tar.gz
PKG+=pkg/procps-ng-$(PROCPS_VER).tar.xz
PKG+=pkg/psmisc-$(PSMISC_VER).tar.xz
PKG+=pkg/pv-$(PV_VER).tar.gz
PKG+=pkg/Python-$(PYTHON_VER).tar.xz
PKG+=pkg/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2
PKG+=pkg/readline-$(READLINE_VER).tar.gz
PKG+=pkg/sed-$(SED_VER).tar.xz
PKG+=pkg/shadow-$(SHADOW_VER).tar.xz
PKG+=pkg/systemd-$(SYSTEMD_VER).tar.gz
PKG+=pkg/tar-$(TAR_VER).tar.xz
PKG+=pkg/tcl$(TCL_VER)-src.tar.gz
PKG+=pkg/tcl$(TCL_DOC_VER)-html.tar.gz
PKG+=pkg/texinfo-$(TEXINFO_VER).tar.xz
PKG+=pkg/tzdata$(TIME_ZONE_DATA_VER).tar.gz
PKG+=pkg/util-linux-$(UTIL_LINUX_VER).tar.xz
PKG+=pkg/vim-$(VIM_VER).tar.gz
PKG+=pkg/XML-Parser-$(XML_PARSER_VER).tar.gz
PKG+=pkg/xz-$(XZ_VER).tar.xz
PKG+=pkg/zlib-$(ZLIB_VER).tar.xz
PKG+=pkg/zstd-$(ZSTD_VER).tar.gz

# Opi5 additional downloads:

PKG+=pkg/orangepi5-rkbin-only_rk3588.cpio.zst
PKG+=pkg/orangepi5-atf.cpio.zst
PKG+=pkg/orangepi5-uboot.cpio.zst
PKG+=pkg/uboot-$(UBOOT_VER).cpio.zst
PKG+=pkg/orangepi5-linux510-xunlong.cpio.zst
PKG+=pkg/busybox.cpio.zst
PKG+=pkg/rkdeveloptool.cpio.zst

pkg: $(PKG)

pkg/.gitignore:
	mkdir -p pkg &&	touch $@
pkg/glibc-$(GLIBC_VER)-fhs-1.patch: pkg/.gitignore
	wget -P pkg http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/glibc-$(GLIBC_VER)-fhs-1.patch && touch $@
pkg/bash-$(BASH_VER)-upstream_fixes-1.patch: pkg/.gitignore
	wget -P pkg http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bash-$(BASH_VER)-upstream_fixes-1.patch && touch $@
pkg/bzip2-$(BZIP2_VER)-install_docs-1.patch: pkg/.gitignore
	wget -P pkg http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/bzip2-$(BZIP2_VER)-install_docs-1.patch && touch $@
pkg/coreutils-$(CORE_UTILS_VER)-i18n-1.patch: pkg/.gitignore
	wget -P pkg http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/coreutils-$(CORE_UTILS_VER)-i18n-1.patch && touch $@
pkg/kbd-$(KBD_VER)-backspace-1.patch: pkg/.gitignore
	wget -P pkg http://www.linuxfromscratch.org/patches/lfs/$(LFS_VER)/kbd-$(KBD_VER)-backspace-1.patch && touch $@
pkg/acl-$(ACL_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://download.savannah.gnu.org/releases/acl/acl-$(ACL_VER).tar.gz && touch $@
pkg/attr-$(ATTR_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://download.savannah.gnu.org/releases/attr/attr-$(ATTR_VER).tar.gz && touch $@
pkg/autoconf-$(AUTOCONF_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/autoconf/autoconf-$(AUTOCONF_VER).tar.xz && touch $@
pkg/automake-$(AUTOMAKE_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/automake/automake-$(AUTOMAKE_VER).tar.xz && touch $@
pkg/bash-$(BASH_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz && touch $@
pkg/bc-$(BC_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://github.com/gavinhoward/bc/releases/download/$(BC_VER)/bc-$(BC_VER).tar.xz && touch $@
pkg/binutils-$(BINUTILS_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.xz && touch $@
pkg/bison-$(BISON_VER).tar.xz: pkg/.gitignore	
	wget -P pkg http://ftp.gnu.org/gnu/bison/bison-$(BISON_VER).tar.xz && touch $@
pkg/bzip2-$(BZIP2_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://www.sourceware.org/pub/bzip2/bzip2-$(BZIP2_VER).tar.gz && touch $@
pkg/check-$(CHECK_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/libcheck/check/releases/download/$(CHECK_VER)/check-$(CHECK_VER).tar.gz && touch $@
pkg/coreutils-$(CORE_UTILS_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/coreutils/coreutils-$(CORE_UTILS_VER).tar.xz && touch $@
pkg/cpio-$(CPIO_VER).tar.bz2: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/cpio/cpio-$(CPIO_VER).tar.bz2 && touch $@
pkg/dbus-$(DBUS_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS_VER).tar.gz && touch $@
pkg/dejagnu-$(DEJAGNU_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/dejagnu/dejagnu-$(DEJAGNU_VER).tar.gz && touch $@
pkg/diffutils-$(DIFF_UTILS_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/diffutils/diffutils-$(DIFF_UTILS_VER).tar.xz && touch $@
pkg/e2fsprogs-$(E2FSPROGS_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz && touch $@
pkg/elfutils-$(ELF_UTILS_VER).tar.bz2: pkg/.gitignore
	wget -P pkg https://sourceware.org/ftp/elfutils/$(ELF_UTILS_VER)/elfutils-$(ELF_UTILS_VER).tar.bz2 && touch $@
pkg/expat-$(EXPAT_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://prdownloads.sourceforge.net/expat/expat-$(EXPAT_VER).tar.xz && touch $@
pkg/expect$(EXPECT_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://prdownloads.sourceforge.net/expect/expect$(EXPECT_VER).tar.gz && touch $@
pkg/file-$(FILE_VER).tar.gz: pkg/.gitignore
	wget -P pkg ftp://ftp.astron.com/pub/file/file-$(FILE_VER).tar.gz && touch $@
pkg/findutils-$(FIND_UTILS_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/findutils/findutils-$(FIND_UTILS_VER).tar.xz && touch $@
pkg/flex-$(FLEX_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/westes/flex/releases/download/v$(FLEX_VER)/flex-$(FLEX_VER).tar.gz && touch $@
pkg/gawk-$(GAWK_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/gawk/gawk-$(GAWK_VER).tar.xz && touch $@
pkg/gcc-$(GCC_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VER)/gcc-$(GCC_VER).tar.xz && touch $@
pkg/gdbm-$(DBM_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/gdbm/gdbm-$(GDBM_VER).tar.gz && touch $@
pkg/gettext-$(GETTEXT_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/gettext/gettext-$(GETTEXT_VER).tar.xz && touch $@
pkg/glibc-$(GLIBC_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/glibc/glibc-$(GLIBC_VER).tar.xz && touch $@
pkg/gmp-$(GMP_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/gmp/gmp-$(GMP_VER).tar.xz && touch $@
pkg/gperf-$(GPERF_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/gperf/gperf-$(GPERF_VER).tar.gz && touch $@
pkg/grep-$(GREP_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/grep/grep-$(GREP_VER).tar.xz && touch $@
pkg/groff-$(GROFF_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/groff/groff-$(GROFF_VER).tar.gz && touch $@
pkg/gzip-$(GZIP_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VER).tar.xz && touch $@
pkg/iana-etc-$(IANA_ETC_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/Mic92/iana-etc/releases/download/$(IANA_ETC_VER)/iana-etc-$(IANA_ETC_VER).tar.gz && touch $@
pkg/inetutils-$(INET_UTILS_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/inetutils/inetutils-$(INET_UTILS_VER).tar.xz && touch $@
pkg/intltool-$(INTL_TOOL_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://launchpad.net/intltool/trunk/$(INTL_TOOL_VER)/+download/intltool-$(INTL_TOOL_VER).tar.gz && touch $@
pkg/iproute2-$(IP_ROUTE2_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$(IP_ROUTE2_VER).tar.xz && touch $@
pkg/isl-$(ISL_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://libisl.sourceforge.io/isl-$(ISL_VER).tar.xz && touch $@
pkg/kbd-$(KBD_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/utils/kbd/kbd-$(KBD_VER).tar.xz && touch $@
pkg/kmod-$(KMOD_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$(KMOD_VER).tar.xz && touch $@
pkg/less-$(LESS_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz && touch $@
pkg/libcap-$(LIBCAP_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(LIBCAP_VER).tar.xz && touch $@
pkg/libffi-$(LIBFFI_VER).tar.gz: pkg/.gitignore
	wget -P pkg ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz && touch $@
pkg/libpipeline-$(LIBPIPILINE_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://download.savannah.gnu.org/releases/libpipeline/libpipeline-$(LIBPIPILINE_VER).tar.gz && touch $@
pkg/libtool-$(LIBTOOL_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/libtool/libtool-$(LIBTOOL_VER).tar.xz && touch $@
pkg/m4-$(M4_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/m4/m4-$(M4_VER).tar.xz && touch $@
pkg/make-$(MAKE_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/make/make-$(MAKE_VER).tar.gz && touch $@
pkg/man-db-$(MAN_DB_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://download.savannah.gnu.org/releases/man-db/man-db-$(MAN_DB_VER).tar.xz && touch $@
pkg/man-pages-$(MAN_PAGES_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/docs/man-pages/man-pages-$(MAN_PAGES_VER).tar.xz && touch $@
pkg/meson-$(MESON_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/mesonbuild/meson/releases/download/$(MESON_VER)/meson-$(MESON_VER).tar.gz && touch $@
pkg/mpc-$(MPC_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://ftp.gnu.org/gnu/mpc/mpc-$(MPC_VER).tar.gz && touch $@
pkg/mpfr-$(MPFR_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.mpfr.org/mpfr-4.1.0/mpfr-$(MPFR_VER).tar.xz && touch $@
pkg/ncurses-$(NCURSES_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz && touch $@
pkg/ninja-$(NINJA_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/ninja-build/ninja/archive/v$(NINJA_VER)/ninja-$(NINJA_VER).tar.gz && touch $@
pkg/openssl-$(OPEN_SSL_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://www.openssl.org/source/openssl-$(OPEN_SSL_VER).tar.gz && touch $@
pkg/patch-$(PATCH_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/patch/patch-$(PATCH_VER).tar.xz && touch $@
pkg/perl-$(PERL_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.cpan.org/src/5.0/perl-$(PERL_VER).tar.xz && touch $@
pkg/pkg-config-$(PKG_CONFIG_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://pkg-config.freedesktop.org/releases/pkg-config-$(PKG_CONFIG_VER).tar.gz && touch $@
pkg/procps-ng-$(PROCPS_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-$(PROCPS_VER).tar.xz && touch $@
pkg/psmisc-$(PSMISC_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-$(PSMISC_VER).tar.xz && touch $@
pkg/pv-$(PV_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://www.ivarch.com/programs/sources/pv-$(PV_VER).tar.gz && touch $@
pkg/Python-$(PYTHON_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tar.xz && touch $@
pkg/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2: pkg/.gitignore
	wget -P pkg https://www.python.org/ftp/python/doc/$(PYTHON_DOC_VER)/python-$(PYTHON_DOC_VER)-docs-html.tar.bz2 && touch $@
pkg/readline-$(READLINE_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/readline/readline-$(READLINE_VER).tar.gz && touch $@
pkg/sed-$(SED_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/sed/sed-$(SED_VER).tar.xz && touch $@
pkg/shadow-$(SHADOW_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://github.com/shadow-maint/shadow/releases/download/$(SHADOW_VER)/shadow-$(SHADOW_VER).tar.xz && touch $@
pkg/systemd-$(SYSTEMD_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/systemd/systemd/archive/v$(SYSTEMD_VER)/systemd-$(SYSTEMD_VER).tar.gz && touch $@
pkg/tar-$(TAR_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/tar/tar-$(TAR_VER).tar.xz && touch $@
pkg/tcl$(TCL_VER)-src.tar.gz: pkg/.gitignore
	wget -P pkg https://downloads.sourceforge.net/tcl/tcl$(TCL_VER)-src.tar.gz && touch $@
pkg/tcl$(TCL_DOC_VER)-html.tar.gz: pkg/.gitignore
	wget -P pkg https://downloads.sourceforge.net/tcl/tcl$(TCL_DOC_VER)-html.tar.gz && touch $@
pkg/texinfo-$(TEXINFO_VER).tar.xz: pkg/.gitignore
	wget -P pkg http://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.xz && touch $@
pkg/tzdata$(TIME_ZONE_DATA_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://www.iana.org/time-zones/repository/releases/tzdata$(TIME_ZONE_DATA_VER).tar.gz && touch $@
pkg/util-linux-$(UTIL_LINUX_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_VER)/util-linux-$(UTIL_LINUX_VER).tar.xz && touch $@
pkg/vim-$(VIM_VER).tar.gz: pkg/.gitignore
	wget -P pkg http://anduin.linuxfromscratch.org/LFS/vim-$(VIM_VER).tar.gz && touch $@
pkg/XML-Parser-$(XML_PARSER_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-$(XML_PARSER_VER).tar.gz && touch $@
pkg/xz-$(XZ_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://tukaani.org/xz/xz-$(XZ_VER).tar.xz && touch $@
pkg/zlib-$(ZLIB_VER).tar.xz: pkg/.gitignore
	wget -P pkg https://zlib.net/zlib-$(ZLIB_VER).tar.xz && touch $@
pkg/zstd-$(ZSTD_VER).tar.gz: pkg/.gitignore
	wget -P pkg https://github.com/facebook/zstd/releases/download/v$(ZSTD_VER)/zstd-$(ZSTD_VER).tar.gz && touch $@

pkg/orangepi5-rkbin-only_rk3588.cpio.zst:
	mkdir -p pkg
	rm -fr tmp/orangepi5-rkbin
	mkdir -p tmp/orangepi5-rkbin
	git clone https://github.com/armbian/rkbin tmp/orangepi5-rkbin
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-rkbin/.git
endif
	cd tmp/orangepi5-rkbin/rk35 && find rk3588* -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg/orangepi5-rkbin-only_rk3588.cpio.zst
	rm -fr tmp/orangepi5-rkbin

pkg/orangepi5-atf.cpio.zst:
	mkdir -p pkg
	rm -fr tmp/orangepi5-atf
	mkdir -p tmp/orangepi5-atf
	git clone https://review.trustedfirmware.org/TF-A/trusted-firmware-a tmp/orangepi5-atf
	cd tmp/orangepi5-atf && git fetch https://review.trustedfirmware.org/TF-A/trusted-firmware-a refs/changes/40/21840/5 && git checkout -b change-21840 FETCH_HEAD
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-atf/.git
endif
	cd tmp/orangepi5-atf && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg/orangepi5-atf.cpio.zst
	rm -fr tmp/orangepi5-atf

pkg/orangepi5-uboot.cpio.zst:
	mkdir -p pkg
	rm -fr tmp/orangepi5-uboot
	mkdir -p tmp/orangepi5-uboot
	git clone https://github.com/orangepi-xunlong/u-boot-orangepi.git -b v2017.09-rk3588 tmp/orangepi5-uboot
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-uboot/.git
endif
	cd tmp/orangepi5-uboot && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg/orangepi5-uboot.cpio.zst
	rm -fr tmp/orangepi5-uboot

# https://docs.u-boot.org/en/latest/build/source.html
# https://source.denx.de/u-boot/u-boot
# https://github.com/u-boot/u-boot
# note1: github is a full-mirror of source.denx.de (gitlab based)
# note2: Opi5 is supported at "2024" version, so release "2023.10" has no configs for orange-pi-5.
pkg/uboot-$(UBOOT_VER).cpio.zst:
	mkdir -p pkg
	rm -fr tmp/uboot
	mkdir -p tmp/uboot
	git clone https://github.com/u-boot/u-boot tmp/uboot
	cd tmp/uboot && git checkout $(UBOOT_VER) && ls -1 configs/orangepi-5-*
ifeq ($(GIT_RM),y)
	rm -fr tmp/uboot/.git
endif
	cd tmp/uboot && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg/uboot-$(UBOOT_VER).cpio.zst
	rm -fr tmp/uboot

pkg/orangepi5-linux510-xunlong.cpio.zst:
	mkdir -p pkg
	mkdir -p tmp/orangepi5-linux510-xunlong
	git clone https://github.com/orangepi-xunlong/linux-orangepi.git -b orange-pi-5.10-rk3588 tmp/orangepi5-linux510-xunlong
ifeq ($(GIT_RM),y)
	rm -fr tmp/orangepi5-linux510-xunlong/.git
endif
	cd tmp/orangepi5-linux510-xunlong && find . -print0 | cpio -o0H newc | zstd -z4T9 > ../../pkg/orangepi5-linux510-xunlong.cpio.zst
	rm -fr tmp/orangepi5-linux510-xunlong

pkg/busybox.cpio.zst:
	mkdir -p pkg
	mkdir -p tmp/busybox
	git clone https://git.busybox.net/busybox -b 1_36_stable tmp/busybox
ifeq ($(GIT_RM),y)
	rm -fr tmp/busybox/.git
endif
	cd tmp/busybox && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg/busybox.cpio.zst
	rm -fr tmp/busybox

pkg/rkdeveloptool.cpio.zst:
	mkdir -p pkg
	mkdir -p tmp/rkdeveloptool
	git clone https://github.com/rockchip-linux/rkdeveloptool tmp/rkdeveloptool
	sed -i "1491s/buffer\[5\]/buffer\[558\]/" tmp/rkdeveloptool/main.cpp
ifeq ($(GIT_RM),y)
	rm -fr tmp/rkdeveloptool/.git
endif
	cd tmp/rkdeveloptool && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg/rkdeveloptool.cpio.zst
	rm -fr tmp/rkdeveloptool

# --- END OF DOWNLOAD SECTION -------------------------------------------------

# MOST IMPORTANT(!) ENVIROMENT SETTINGS FOR HOST BUILD(!)
PRE_CMD=set +h && export PATH=$(LFS)/tools/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin && export LC_ALL=POSIX

# Here is full stage0 clean
hst-deepclean: hst-clean
	rm -fr lfs
	rm -fr pkg1
	rm -fr tmp

# =============================================================================
# BEGIN OF HOST BUILD(!)
# =============================================================================

# === LFS-10.0-systemd :: 5.4. Linux API Headers :: "make hst-headers" (deps : cfg/kernel_config)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/linux-headers.html
# BUILD_TIME :: 0.5 min
pkg1/lfs-kernel-headers.cpio.zst: cfg/$(KERNEL_CONFIG) pkg/orangepi5-linux510-xunlong.cpio.zst
	mkdir -p tmp/kernel/src
	pv pkg/orangepi5-linux510-xunlong.cpio.zst | zstd -d | cpio -iduH newc -D tmp/kernel/src
	mkdir -p tmp/kernel/bld
	cp -far cfg/$(KERNEL_CONFIG) tmp/kernel/bld
	mkdir -p tmp/kernel/hdr
	cd tmp/kernel/src && make O=../bld $(JOBS) V=$(VERB) ARCH=arm64 INSTALL_HDR_PATH=../hdr headers_install
	mkdir -p pkg1
	cd tmp/kernel/hdr/include && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../../pkg1/lfs-kernel-headers.cpio.zst
	rm -fr tmp/kernel
lfs/usr/include/asm/ioctl.h: pkg1/lfs-kernel-headers.cpio.zst
	mkdir -p lfs/usr/include
	pv pkg1/lfs-kernel-headers.cpio.zst | zstd -d | cpio -iduH newc -D lfs/usr/include
hst-headers: lfs/usr/include/asm/ioctl.h

# === LFS-10.0-systemd :: 5.2. Binutils - Pass 1 :: "make hst-binutils1" (deps : Linux Kernel Headers)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/binutils-pass1.html
# BUILD_TIME :: 1.5 min (incremenal total 2 min)
BINUTILS1_OPT1+= --with-sysroot=$(LFS)
BINUTILS1_OPT1+= --prefix=$(LFS)/tools
BINUTILS1_OPT1+= --target=$(LFS_TGT)
BINUTILS1_OPT1+= --disable-nls
BINUTILS1_OPT1+= --disable-werror
BINUTILS1_OPT1+= $(OPT_FLAGS)
BINUTILS1_OPT1+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst: pkg/binutils-$(BINUTILS_VER).tar.xz lfs/usr/include/asm/ioctl.h
	mkdir -p tmp/lfs-hst-binutils1 && tar -xJf $< -C tmp/lfs-hst-binutils1 && mkdir -pv tmp/lfs-hst-binutils1/bld && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils1/bld && ../binutils-$(BINUTILS_VER)/configure $(BINUTILS1_OPT1)' && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils1/bld && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-binutils1/ins$(LFS)/tools/share
	strip --strip-unneeded tmp/lfs-hst-binutils1/ins$(LFS)/tools/$(LFS_TGT)/bin/* || true
	strip --strip-unneeded tmp/lfs-hst-binutils1/ins$(LFS)/tools/bin/* || true
	mkdir -p pkg1
	cd tmp/lfs-hst-binutils1/ins$(LFS)/tools && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../../../../../pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst
	rm -fr tmp/lfs-hst-binutils1
lfs/tools/$(LFS_TGT)/lib/ldscripts/armelf.x: pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass1.cpio.zst
	mkdir -p lfs/tools && pv $< | zstd -d | cpio -iduH newc -D lfs/tools
hst-binutils1: lfs/tools/$(LFS_TGT)/lib/ldscripts/armelf.x

# === LFS-10.0-systemd :: 5.3. GCC - Pass 1 :: "make hst-gcc1" (deps : hst-binutils1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/gcc-pass1.html
# BUILD_TIME :: 7 min 45 sec (incremental total 9 min 45 sec)
GCC1_OPT1+= --with-sysroot=$(LFS)
GCC1_OPT1+= --prefix=$(LFS)/tools
GCC1_OPT1+= --target=$(LFS_TGT)
GCC1_OPT1+= --with-glibc-version=2.11
GCC1_OPT1+= --with-newlib
GCC1_OPT1+= --without-headers
GCC1_OPT1+= --enable-initfini-array
GCC1_OPT1+= --disable-nls
GCC1_OPT1+= --disable-shared
GCC1_OPT1+= --disable-multilib
GCC1_OPT1+= --disable-decimal-float
GCC1_OPT1+= --disable-threads
GCC1_OPT1+= --disable-libatomic
GCC1_OPT1+= --disable-libgomp
GCC1_OPT1+= --disable-libquadmath
GCC1_OPT1+= --disable-libssp
GCC1_OPT1+= --disable-libvtv
GCC1_OPT1+= --disable-libstdcxx
GCC1_OPT1+= --enable-languages=c,c++
GCC1_OPT1+= $(OPT_FLAGS)
GCC1_OPT1+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC1_OPT1+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg1/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst: pkg/gcc-$(GCC_VER).tar.xz pkg/gmp-$(GMP_VER).tar.xz pkg/mpfr-$(MPFR_VER).tar.xz pkg/mpc-$(MPC_VER).tar.gz lfs/tools/$(LFS_TGT)/lib/ldscripts/armelf.x
	mkdir -p tmp/lfs-hst-gcc1
	tar -xJf pkg/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-gcc1
	tar -xJf pkg/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf pkg/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf pkg/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc1/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	mkdir -p tmp/lfs-hst-gcc1/bld && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gcc1/bld && ../gcc-$(GCC_VER)/configure $(GCC1_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	cat tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/limitx.h tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/glimits.h tmp/lfs-hst-gcc1/gcc-$(GCC_VER)/gcc/limity.h > tmp/lfs-hst-gcc1/ins$(LFS)/tools/lib/gcc/$(LFS_TGT)/$(GCC_VER)/install-tools/include/limits.h
	rm -fr tmp/lfs-hst-gcc1/ins$(LFS)/tools/share
	rm -fr tmp/lfs-hst-gcc1/ins$(LFS)/tools/include
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools -name "README" -delete
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools -name \*.la -delete
	find tmp/lfs-hst-gcc1/ins$(LFS)/tools/lib -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-gcc1/ins$(LFS)/tools && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-gcc1/ins$(LFS)/tools && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../../../../../pkg1/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst
	rm -fr tmp/lfs-hst-gcc1
lfs/tools/lib/gcc/aarch64-rk3588-linux-gnu/10.2.0/include/arm_acle.h: pkg1/lfs-hst-gcc-$(GCC_VER).pass1.cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs/tools
hst-gcc1: lfs/tools/lib/gcc/aarch64-rk3588-linux-gnu/10.2.0/include/arm_acle.h

# === LFS-10.0-systemd :: 5.5. Glibc-2.32 :: "make hst-glibc" (deps : hst-gcc1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/glibc.html
# BUILD_TIME :: 5m 20s (incremental 15m)
GLIBC_OPT1+= --prefix=/usr
GLIBC_OPT1+= --host=$(LFS_TGT)
GLIBC_OPT1+= --enable-kernel=3.2
GLIBC_OPT1+= --with-headers=$(LFS)/usr/include
GLIBC_OPT1+= libc_cv_slibdir=/lib
GLIBC_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-glibc-$(GLIBC_VER).cpio.zst: pkg/glibc-$(GLIBC_VER).tar.xz pkg/glibc-$(GLIBC_VER)-fhs-1.patch lfs/tools/lib/gcc/aarch64-rk3588-linux-gnu/10.2.0/include/arm_acle.h
	mkdir -p tmp/lfs-hst-glibc
	cp -far pkg/glibc-$(GLIBC_VER)-fhs-1.patch tmp/lfs-hst-glibc
	tar -xJf pkg/glibc-$(GLIBC_VER).tar.xz -C tmp/lfs-hst-glibc
	cd tmp/lfs-hst-glibc/glibc-$(GLIBC_VER) && patch -Np1 -i ../glibc-$(GLIBC_VER)-fhs-1.patch
	sed -i '30 a DIAG_PUSH_NEEDS_COMMENT;' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	sed -i '31 a DIAG_IGNORE_Os_NEEDS_COMMENT (8, "-Wmaybe-uninitialized");' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	sed -i '33 a DIAG_POP_NEEDS_COMMENT;' tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/locale/weight.h
	tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/scripts/config.guess > lfs/tools/build-host.txt
	mkdir -p tmp/lfs-hst-glibc/bld && sh -c '$(PRE_CMD) && cd tmp/lfs-hst-glibc/bld && ../glibc-$(GLIBC_VER)/configure $(GLIBC_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	find tmp/lfs-hst-glibc/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-glibc/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
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
	cd tmp/lfs-hst-glibc/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-glibc-$(GLIBC_VER).cpio.zst
	rm -fr tmp/lfs-hst-glibc
lfs/usr/include/arpa/ftp.h: pkg1/lfs-hst-glibc-$(GLIBC_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-glibc: lfs/usr/include/arpa/ftp.h

# === my extra
#
# BUILD_TIME :: 0 min
lfs/tools/build-host.txt: pkg/glibc-$(GLIBC_VER).tar.xz lfs/usr/include/arpa/ftp.h
	mkdir -p lfs/tools
	mkdir -p tmp/lfs-hst-glibc
	tar -xJf $< -C tmp/lfs-hst-glibc
	tmp/lfs-hst-glibc/glibc-$(GLIBC_VER)/scripts/config.guess > lfs/tools/build-host.txt
	rm -fr tmp/lfs-hst-glibc

# === LFS-10.0-systemd :: 5.6. Libstdc++ from GCC-10.2.0, Pass 1 :: "make hst-libcpp1" (deps : hst-glibc)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter05/gcc-libstdc++-pass1.html
# BUILD_TIME :: 1m 42s
LIBCPP1_OPT1+= --host=$(LFS_TGT)
LIBCPP1_OPT1+= --prefix=/usr
LIBCPP1_OPT1+= --disable-multilib
LIBCPP1_OPT1+= --disable-nls
LIBCPP1_OPT1+= --disable-libstdcxx-pch
LIBCPP1_OPT1+= --with-gxx-include-dir=/tools/$(LFS_TGT)/include/c++/$(GCC_VER)
LIBCPP1_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-libcpp.pass1.cpio.zst: pkg/gcc-$(GCC_VER).tar.xz pkg/gmp-$(GMP_VER).tar.xz pkg/mpfr-$(MPFR_VER).tar.xz pkg/mpc-$(MPC_VER).tar.gz lfs/tools/build-host.txt
	lfs/tools/libexec/gcc/$(LFS_TGT)/$(GCC_VER)/install-tools/mkheaders
	mkdir -p tmp/lfs-hst-libcpp1
	tar -xJf pkg/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-libcpp1
	tar -xJf pkg/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf pkg/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf pkg/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && cd tmp/lfs-hst-libcpp1/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	mkdir -p tmp/lfs-hst-libcpp1/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-libcpp1/bld && ../gcc-$(GCC_VER)/libstdc++-v3/configure --build=`cat $(LFS)/tools/build-host.txt` $(LIBCPP1_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	find tmp/lfs-hst-libcpp1/ins -name \*.la -delete
	find tmp/lfs-hst-libcpp1/ins -type f -name "*.a" -exec strip --strip-debug {} +
	cd tmp/lfs-hst-libcpp1/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	mkdir -p tmp/lfs-hst-libcpp1/ins/usr/lib
	mv tmp/lfs-hst-libcpp1/ins/usr/lib64/* tmp/lfs-hst-libcpp1/ins/usr/lib/
	rm -fr tmp/lfs-hst-libcpp1/ins/usr/lib64
	cd tmp/lfs-hst-libcpp1/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-libcpp.pass1.cpio.zst
	rm -fr tmp/lfs-hst-libcpp1
lfs/tools/aarch64-rk3588-linux-gnu/include/c++/10.2.0/any: pkg1/lfs-hst-libcpp.pass1.cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-libcpp1: lfs/tools/aarch64-rk3588-linux-gnu/include/c++/10.2.0/any

# === LFS-10.0-systemd :: 6.2. M4-1.4.18 :: "make hst-m4" (deps : hst-libcpp1)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/m4.html
# BUILD_TIME :: 0m 40s
M4_OPT1+= --prefix=/usr
M4_OPT1+= --host=$(LFS_TGT)
M4_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-m4-$(M4_VER).cpio.zst: pkg/m4-$(M4_VER).tar.xz lfs/tools/aarch64-rk3588-linux-gnu/include/c++/10.2.0/any
	mkdir -p tmp/lfs-hst-m4
	tar -xJf $< -C tmp/lfs-hst-m4
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' tmp/lfs-hst-m4/m4-$(M4_VER)/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> tmp/lfs-hst-m4/m4-$(M4_VER)/lib/stdio-impl.h
	mkdir -p tmp/lfs-hst-m4/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-m4/bld && ../m4-$(M4_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(M4_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-m4/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-m4/ins/usr/bin/m4
	cd tmp/lfs-hst-m4/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-m4-$(M4_VER).cpio.zst
	rm -fr tmp/lfs-hst-m4
lfs/usr/bin/m4: pkg1/lfs-hst-m4-$(M4_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-m4: lfs/usr/bin/m4

# === LFS-10.0-systemd :: 6.3. Ncurses-6.2 :: "make hst-ncurses" (deps : hst-m4)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/ncurses.html
# BUILD_TIME :: 2m 10s
NCURSES_OPT1+= --prefix=/usr
NCURSES_OPT1+= --host=$(LFS_TGT)
NCURSES_OPT1+= --mandir=/usr/share/man
NCURSES_OPT1+= --with-manpage-format=normal
NCURSES_OPT1+= --without-manpages
NCURSES_OPT1+= --with-default-terminfo-dir=/usr/share/terminfo
NCURSES_OPT1+= --with-shared
NCURSES_OPT1+= --without-debug
NCURSES_OPT1+= --without-ada
NCURSES_OPT1+= --without-normal
NCURSES_OPT1+= --with-termlib
NCURSES_OPT1+= --with-ticlib
NCURSES_OPT1+= --enable-widec
NCURSES_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst: pkg/ncurses-$(NCURSES_VER).tar.gz lfs/usr/bin/m4
	mkdir -p tmp/lfs-hst-ncurses
	tar -xzf $< -C tmp/lfs-hst-ncurses
	sed -i s/mawk// tmp/lfs-hst-ncurses/ncurses-$(NCURSES_VER)/configure
	mkdir -p tmp/lfs-hst-ncurses/bld-tic
	cd tmp/lfs-hst-ncurses/bld-tic && ../ncurses-$(NCURSES_VER)/configure && make -C include && make -C progs tic
	mkdir -p tmp/lfs-hst-ncurses/bld
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-ncurses/bld && ../ncurses-$(NCURSES_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(NCURSES_OPT1) && make $(JOBS) V=$(VERB) && make TIC_PATH=`pwd`/../bld-tic/progs/tic LD_LIBRARY_PATH=`pwd`/../bld-tic/lib DESTDIR=`pwd`/../ins install'
	cd tmp/lfs-hst-ncurses/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	echo "INPUT(-lncursesw)" > tmp/lfs-hst-ncurses/ins/usr/lib/libncurses.so
	cd tmp/lfs-hst-ncurses/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst
	rm -fr tmp/lfs-hst-ncurses
lfs/usr/include/curses.h: pkg1/lfs-hst-ncurses-$(NCURSES_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-ncurses: lfs/usr/include/curses.h

# === LFS-10.0-systemd :: 6.4. Bash-5.0 :: "make hst-bash" (deps : hst-ncurses)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/bash.html
# BUILD_TIME :: 1m 7s
BASH_OPT1+= --prefix=/usr
BASH_OPT1+= --host=$(LFS_TGT)
BASH_OPT1+= --without-bash-malloc
BASH_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-bash-$(BASH_VER).cpio.zst: pkg/bash-$(BASH_VER).tar.gz lfs/usr/include/curses.h
	mkdir -p tmp/lfs-hst-bash/bld
	tar -xzf $< -C tmp/lfs-hst-bash
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-bash/bld && ../bash-$(BASH_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(BASH_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-bash/ins/usr/share
	cd tmp/lfs-hst-bash/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-bash/ins/usr/bin && ln -sf bash sh
	cd tmp/lfs-hst-bash/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-bash-$(BASH_VER).cpio.zst
	rm -fr tmp/lfs-hst-bash
lfs/usr/include/bash/alias.h: pkg1/lfs-hst-bash-$(BASH_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-bash: lfs/usr/include/bash/alias.h

# === LFS-10.0-systemd :: 6.5. Coreutils-8.32 :: "make hst-coreutils" (deps : hst-bash)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/coreutils.html
# BUILD_TIME :: 1m 57s
COREUTILS_OPT1+= --prefix=/usr
COREUTILS_OPT1+= --host=$(LFS_TGT)
COREUTILS_OPT1+= --enable-install-program=hostname
COREUTILS_OPT1+= --enable-no-install-program=kill,uptime
COREUTILS_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst: pkg/coreutils-$(CORE_UTILS_VER).tar.xz lfs/usr/include/bash/alias.h
	mkdir -p tmp/lfs-hst-coreutils/bld
	tar -xJf $< -C tmp/lfs-hst-coreutils
	sed -i "s/SYS_getdents/SYS_getdents64/" tmp/lfs-hst-coreutils/coreutils-$(CORE_UTILS_VER)/src/ls.c
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-coreutils/bld && ../coreutils-$(CORE_UTILS_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(COREUTILS_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-coreutils/ins/usr/share
	cd tmp/lfs-hst-coreutils/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-coreutils/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-coreutils
lfs/usr/libexec/coreutils/libstdbuf.so: pkg1/lfs-hst-coreutils-$(CORE_UTILS_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-coreutils: lfs/usr/libexec/coreutils/libstdbuf.so

# === LFS-10.0-systemd :: 6.6. Diffutils-3.7 :: "make hst-diffutils" (deps : hst-coreutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/diffutils.html
# BUILD_TIME :: 0m 41s
DIFFUTILS_OPT1+= --prefix=/usr
DIFFUTILS_OPT1+= --host=$(LFS_TGT)
DIFFUTILS_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst: pkg/diffutils-$(DIFF_UTILS_VER).tar.xz lfs/usr/libexec/coreutils/libstdbuf.so
	mkdir -p tmp/lfs-hst-diffutils/bld
	tar -xJf $< -C tmp/lfs-hst-diffutils
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-diffutils/bld && ../diffutils-$(DIFF_UTILS_VER)/configure $(DIFFUTILS_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-diffutils/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-diffutils/ins/usr/bin/*
	cd tmp/lfs-hst-diffutils/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-diffutils
lfs/usr/bin/diff: pkg1/lfs-hst-diffutils-$(DIFF_UTILS_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-diffutils: lfs/usr/bin/diff

# === LFS-10.0-systemd :: 6.7. File-5.39 :: "make hst-file" (deps : hst-diffutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/file.html
# BUILD_TIME :: 0m 20s
FILE_OPT1+= --prefix=/usr
FILE_OPT1+= --host=$(LFS_TGT)
FILE_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-file-$(FILE_VER).cpio.zst: pkg/file-$(FILE_VER).tar.gz lfs/usr/bin/diff
	mkdir -p tmp/lfs-hst-file/bld
	tar -xzf $< -C tmp/lfs-hst-file
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-file/bld && ../file-$(FILE_VER)/configure $(FILE_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-file/ins/usr/share/man
	find tmp/lfs-hst-file/ins -name \*.la -delete
	cd tmp/lfs-hst-file/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-file/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-file-$(FILE_VER).cpio.zst
	rm -fr tmp/lfs-hst-file
lfs/usr/include/magic.h: pkg1/lfs-hst-file-$(FILE_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-file: lfs/usr/include/magic.h

# === LFS-10.0-systemd :: 6.8. Findutils-4.7.0 :: "make hst-findutils" (deps : hst-file)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/findutils.html
# BUILD_TIME :: 1m 6s
FINDUTILS_OPT1+= --prefix=/usr
FINDUTILS_OPT1+= --host=$(LFS_TGT)
FINDUTILS_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst: pkg/findutils-$(FIND_UTILS_VER).tar.xz lfs/usr/include/magic.h
	mkdir -p tmp/lfs-hst-findutils/bld
	tar -xJf $< -C tmp/lfs-hst-findutils
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-findutils/bld && ../findutils-$(FIND_UTILS_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(FINDUTILS_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-findutils/ins/usr/var
	rm -fr tmp/lfs-hst-findutils/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-findutils/ins/usr/bin/* || true
	strip --strip-unneeded tmp/lfs-hst-findutils/ins/usr/libexec/*
	cd tmp/lfs-hst-findutils/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst
	rm -fr tmp/lfs-hst-findutils
lfs/usr/libexec/frcode:	pkg1/lfs-hst-findutils-$(FIND_UTILS_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-findutils: lfs/usr/libexec/frcode

# === LFS-10.0-systemd :: 6.9. Gawk-5.1.0 :: "make hst-gawk" (deps : hst-findutils)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gawk.html
# BUILD_TIME :: 0m 44s
GAWK_OPT1+= --prefix=/usr
GAWK_OPT1+= --host=$(LFS_TGT)
GAWK_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-gawk-$(GAWK_VER).cpio.zst: pkg/gawk-$(GAWK_VER).tar.xz lfs/usr/libexec/frcode
	mkdir -p tmp/lfs-hst-gawk/bld
	tar -xJf $< -C tmp/lfs-hst-gawk
	sed -i 's/extras//' tmp/lfs-hst-gawk/gawk-$(GAWK_VER)/Makefile.in
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gawk/bld && ../gawk-$(GAWK_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(GAWK_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/info
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/locale
	rm -fr tmp/lfs-hst-gawk/ins/usr/share/man
	cd tmp/lfs-hst-gawk/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-gawk/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-gawk-$(GAWK_VER).cpio.zst
	rm -fr tmp/lfs-hst-gawk
lfs/usr/include/gawkapi.h: pkg1/lfs-hst-gawk-$(GAWK_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-gawk: lfs/usr/include/gawkapi.h

# === LFS-10.0-systemd :: 6.10. Grep-3.4 :: "make hst-grep" (deps : hst-gawk)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/grep.html
# BUILD_TIME :: 0m 44s
GREP_OPT1+= --prefix=/usr
GREP_OPT1+= --host=$(LFS_TGT)
GREP_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-grep-$(GREP_VER).cpio.zst: pkg/grep-$(GREP_VER).tar.xz lfs/usr/include/gawkapi.h
	mkdir -p tmp/lfs-hst-grep/bld
	tar -xJf $< -C tmp/lfs-hst-grep
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-grep/bld && ../grep-$(GREP_VER)/configure $(GREP_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-grep/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-grep/ins/usr/bin/grep
	cd tmp/lfs-hst-grep/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-grep-$(GREP_VER).cpio.zst
	rm -fr tmp/lfs-hst-grep
lfs/usr/bin/egrep: pkg1/lfs-hst-grep-$(GREP_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-grep: lfs/usr/bin/egrep

# === LFS-10.0-systemd :: 6.11. Gzip-1.10 :: "make hst-gzip" (deps : hst-grep)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gzip.html
# BUILD_TIME :: 0m 27s
GZIP_OPT1+= --prefix=/usr
GZIP_OPT1+= --host=$(LFS_TGT)
GZIP_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-gzip-$(GZIP_VER).cpio.zst: pkg/gzip-$(GZIP_VER).tar.xz lfs/usr/bin/egrep
	mkdir -p tmp/lfs-hst-gzip/bld
	tar -xJf $< -C tmp/lfs-hst-gzip
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gzip/bld && ../gzip-$(GZIP_VER)/configure $(GZIP_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gzip/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-gzip/ins/usr/bin/* || true
	cd tmp/lfs-hst-gzip/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-gzip-$(GZIP_VER).cpio.zst
	rm -fr tmp/lfs-hst-gzip
lfs/usr/bin/zegrep: pkg1/lfs-hst-gzip-$(GZIP_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-gzip: lfs/usr/bin/zegrep

# === LFS-10.0-systemd :: 6.12. Make-4.3 :: "make hst-make" (deps : hst-gzip)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/make.html
# BUILD_TIME :: 0m 24s
MAKE_OPT1+= --prefix=/usr
MAKE_OPT1+= --without-guile
MAKE_OPT1+= --host=$(LFS_TGT)
MAKE_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-make-$(MAKE_VER).cpio.zst: pkg/make-$(MAKE_VER).tar.gz lfs/usr/bin/zegrep
	mkdir -p tmp/lfs-hst-make/bld
	tar -xzf $< -C tmp/lfs-hst-make
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-make/bld && ../make-$(MAKE_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(MAKE_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-make/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-make/ins/usr/bin/make
	cd tmp/lfs-hst-make/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-make-$(MAKE_VER).cpio.zst
	rm -fr tmp/lfs-hst-make
lfs/usr/include/gnumake.h: pkg1/lfs-hst-make-$(MAKE_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-make: lfs/usr/include/gnumake.h

# === LFS-10.0-systemd :: 6.13. Patch-2.7.6 :: "make hst-patch" (deps : hst-make)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/patch.html
# BUILD_TIME :: 0m 49s
PATCH_OPT1+= --prefix=/usr
PATCH_OPT1+= --host=$(LFS_TGT)
PATCH_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-patch-$(PATCH_VER).cpio.zst: pkg/patch-$(PATCH_VER).tar.xz lfs/usr/include/gnumake.h
	mkdir -p tmp/lfs-hst-patch/bld
	tar -xJf $< -C tmp/lfs-hst-patch
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-patch/bld && ../patch-$(PATCH_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(PATCH_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-patch/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-patch/ins/usr/bin/*
	cd tmp/lfs-hst-patch/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-patch-$(PATCH_VER).cpio.zst
	rm -fr tmp/lfs-hst-patch
lfs/usr/bin/patch: pkg1/lfs-hst-patch-$(PATCH_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-patch: lfs/usr/bin/patch

# === LFS-10.0-systemd :: 6.14. Sed-4.8 :: "make hst-sed" (deps : hst-patch)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/sed.html
# BUILD_TIME :: 0m 40s
SED_OPT1+= --prefix=/usr
SED_OPT1+= --host=$(LFS_TGT)
SED_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-sed-$(SED_VER).cpio.zst: pkg/sed-$(SED_VER).tar.xz lfs/usr/bin/patch
	mkdir -p tmp/lfs-hst-sed/bld
	tar -xJf $< -C tmp/lfs-hst-sed
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-sed/bld && ../sed-$(SED_VER)/configure $(SED_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-sed/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-sed/ins/usr/bin/*
	cd tmp/lfs-hst-sed/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-sed-$(SED_VER).cpio.zst
	rm -fr tmp/lfs-hst-sed
lfs/usr/bin/sed: pkg1/lfs-hst-sed-$(SED_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-sed: lfs/usr/bin/sed

# === LFS-10.0-systemd :: 6.15. Tar-1.32 :: "make hst-tar" (deps : hst-sed)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/tar.html
# BUILD_TIME :: 0m 56s
TAR_OPT1+= --prefix=/usr
TAR_OPT1+= --host=$(LFS_TGT)
TAR_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-tar-$(TAR_VER).cpio.zst: pkg/tar-$(TAR_VER).tar.xz lfs/usr/bin/sed
	mkdir -p tmp/lfs-hst-tar/bld
	tar -xJf $< -C tmp/lfs-hst-tar
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-tar/bld && ../tar-$(TAR_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(TAR_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-tar/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-tar/ins/usr/bin/*
	strip --strip-unneeded tmp/lfs-hst-tar/ins/usr/libexec/*
	cd tmp/lfs-hst-tar/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-tar-$(TAR_VER).cpio.zst
	rm -fr tmp/lfs-hst-tar
lfs/usr/libexec/rmt: pkg1/lfs-hst-tar-$(TAR_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-tar: lfs/usr/libexec/rmt

# === LFS-10.0-systemd :: 6.16. Xz-5.2.5 :: "make hst-xz" (deps : hst-tar)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/xz.html
# BUILD_TIME :: 0m 26s
XZ_OPT1+= --prefix=/usr
XZ_OPT1+= --host=$(LFS_TGT)
XZ_OPT1+= --disable-static
XZ_OPT1+= --docdir=/usr/share/doc/xz-$(XZ_VER)
XZ_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-xz-$(XZ_VER).cpio.zst: pkg/xz-$(XZ_VER).tar.xz lfs/usr/libexec/rmt
	mkdir -p tmp/lfs-hst-xz/bld
	tar -xJf $< -C tmp/lfs-hst-xz
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-xz/bld && ../xz-$(XZ_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(XZ_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-xz/ins/usr/share
	find tmp/lfs-hst-xz/ins -name \*.la -delete
	cd tmp/lfs-hst-xz/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-xz/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-xz-$(XZ_VER).cpio.zst
	rm -fr tmp/lfs-hst-xz
lfs/usr/include/lzma.h: pkg1/lfs-hst-xz-$(XZ_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-xz: lfs/usr/include/lzma.h

# === my extra :: zstd :: "make hst-zstd" (deps : hst-xz)
#
# BUILD_TIME :: 1m 12s
ZSTD1_L_OPT = CC=$(LFS_TGT)-gcc ZSTD_LIB_MINIFY=1 ZSTD_LIB_DICTBUILDER=0 MOREFLAGS=$(RK3588_FLAGS) prefix=/usr DESTDIR=../../ins
ZSTD1_P_OPT = CC=$(LFS_TGT)-gcc HAVE_PTHREAD=0 HAVE_THREAD=0 MOREFLAGS=$(RK3588_FLAGS) prefix=/usr DESTDIR=../../ins
pkg1/lfs-hst-zstd-$(ZSTD_VER).cpio.zst: pkg/zstd-$(ZSTD_VER).tar.gz lfs/usr/include/lzma.h
	mkdir -p tmp/lfs-hst-zstd/bld
	tar -xzf $< -C tmp/lfs-hst-zstd
	sed -i "s/-O3/$(BASE_OPT_FLAGS)/" tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/programs/Makefile
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/lib && make $(JOBS) $(ZSTD1_L_OPT) lib-all && make $(ZSTD1_L_OPT) install'
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-zstd/zstd-$(ZSTD_VER)/programs && make $(JOBS) $(ZSTD1_P_OPT) zstd-small && make $(ZSTD1_P_OPT) zstd-small install'
	rm -fr tmp/lfs-hst-zstd/ins/usr/share
	rm -fr tmp/lfs-hst-zstd/ins/usr/lib/*.a
	strip --strip-unneeded tmp/lfs-hst-zstd/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/lfs-hst-zstd/ins/usr/bin/zstd
	cd tmp/lfs-hst-zstd/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-zstd-$(ZSTD_VER).cpio.zst
	rm -fr tmp/lfs-hst-zstd
lfs/usr/include/zstd.h: pkg1/lfs-hst-zstd-$(ZSTD_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-zstd: lfs/usr/include/zstd.h

# === my extra (BLFS-10) :: cpio :: "make hst-cpio" (deps : hst-zstd)
# https://www.linuxfromscratch.org/blfs/view/10.0-systemd/
# BUILD_TIME :: 0m 59s
CPIO_OPT1+= --prefix=/usr
CPIO_OPT1+= --host=$(LFS_TGT)
CPIO_OPT1+= --disable-nls
CPIO_OPT1+= --disable-static
CPIO_OPT1+= --with-rmt=/usr/libexec/rmt
CPIO_OPT1+= CFLAGS="$(RK3588_FLAGS) -Os -fcommon"
pkg1/lfs-hst-cpio-$(CPIO_VER).cpio.zst: pkg/cpio-$(CPIO_VER).tar.bz2 lfs/usr/include/zstd.h
	mkdir -p tmp/lfs-hst-cpio/bld
	tar -xjf $< -C tmp/lfs-hst-cpio
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-cpio/bld && ../cpio-$(CPIO_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(CPIO_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-cpio/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-cpio/ins/usr/bin/cpio
	cd tmp/lfs-hst-cpio/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-cpio-$(CPIO_VER).cpio.zst
	rm -fr tmp/lfs-hst-cpio
lfs/usr/bin/cpio: pkg1/lfs-hst-cpio-$(CPIO_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-cpio: lfs/usr/bin/cpio

# === my extra :: pv :: "make hst-pv" (deps: hst-cpio)
# http://www.ivarch.com/programs/pv.shtml
# https://github.com/icetee/pv
# BUILD_TIME :: 0m 9s
PV_OPT1+= --prefix=/usr
PV_OPT1+= --host=$(LFS_TGT)
PV_OPT1+= --disable-nls
PV_OPT1+= --disable-splice
PV_OPT1+= --disable-ipc
PV_OPT1+= $(OPT_FLAGS)
pkg1/lfs-hst-pv-$(PV_VER).cpio.zst: pkg/pv-$(PV_VER).tar.gz lfs/usr/bin/cpio
	mkdir -p tmp/lfs-hst-pv/bld
	tar -xzf $< -C tmp/lfs-hst-pv
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-pv/bld && ../pv-$(PV_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(PV_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-pv/ins/usr/share
	strip --strip-unneeded tmp/lfs-hst-pv/ins/usr/bin/pv
	cd tmp/lfs-hst-pv/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-pv-$(PV_VER).cpio.zst
	rm -fr tmp/lfs-hst-pv
lfs/usr/bin/pv: pkg1/lfs-hst-pv-$(PV_VER).cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-pv: lfs/usr/bin/pv

# === LFS-10.0-systemd :: 6.17. Binutils-2.35 - Pass 2 :: "make hst-binutils2" (deps : hst-pv)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/binutils-pass2.html
# BUILD_TIME :: 1m 58s
BINUTILS2_OPT1+= --prefix=/usr
BINUTILS2_OPT1+= --host=$(LFS_TGT)
BINUTILS2_OPT1+= --disable-nls
BINUTILS2_OPT1+= --enable-shared
BINUTILS2_OPT1+= --disable-werror
BINUTILS2_OPT1+= --enable-64-bit-bfd
BINUTILS2_OPT1+= $(OPT_FLAGS)
BINUTILS2_OPT1+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
BINUTILS2_OPT1+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst: pkg/binutils-$(BINUTILS_VER).tar.xz lfs/usr/bin/pv
	mkdir -p tmp/lfs-hst-binutils2/bld
	tar -xJf $< -C tmp/lfs-hst-binutils2
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-binutils2/bld && ../binutils-$(BINUTILS_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(BINUTILS2_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-binutils2/ins/usr/share
	find tmp/lfs-hst-binutils2/ins/usr/lib -name \*.la -delete
	strip --strip-debug tmp/lfs-hst-binutils2/ins/usr/lib/*.a
	cd tmp/lfs-hst-binutils2/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-binutils2/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst
	rm -fr tmp/lfs-hst-binutils2
lfs/usr/include/bfd.h: pkg1/lfs-hst-binutils-$(BINUTILS_VER).pass2.cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-binutils2: lfs/usr/include/bfd.h

# === LFS-10.0-systemd :: 6.18. GCC-10.2.0 - Pass 2 :: "make hst-gcc2" (deps : hst-binutils2)
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter06/gcc-pass2.html
# BUILD_TIME :: 11m (total incremental build time 45m 12s (V0), 44m 51s (V1) )
GCC2_OPT1+= --host=$(LFS_TGT)
GCC2_OPT1+= --prefix=/usr
GCC2_OPT1+= CC_FOR_TARGET=$(LFS_TGT)-gcc
GCC2_OPT1+= --with-build-sysroot=$(LFS)
GCC2_OPT1+= --enable-initfini-array
GCC2_OPT1+= --disable-nls
GCC2_OPT1+= --disable-multilib
GCC2_OPT1+= --disable-decimal-float
GCC2_OPT1+= --disable-libatomic
GCC2_OPT1+= --disable-libgomp
GCC2_OPT1+= --disable-libquadmath
GCC2_OPT1+= --disable-libssp
GCC2_OPT1+= --disable-libvtv
GCC2_OPT1+= --disable-libstdcxx
GCC2_OPT1+= --enable-languages=c,c++
GCC2_OPT1+= $(OPT_FLAGS)
GCC2_OPT1+= CFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_BUILD="$(BASE_OPT_FLAGS)"
GCC2_OPT1+= CFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)" CXXFLAGS_FOR_TARGET="$(BASE_OPT_FLAGS)"
pkg1/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst: pkg/gcc-$(GCC_VER).tar.xz lfs/usr/include/bfd.h
	mkdir -p tmp/lfs-hst-gcc2/bld
	tar -xJf pkg/gcc-$(GCC_VER).tar.xz -C tmp/lfs-hst-gcc2
	tar -xJf pkg/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf pkg/mpfr-$(MPFR_VER).tar.xz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf pkg/mpc-$(MPC_VER).tar.gz -C tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && cd tmp/lfs-hst-gcc2/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	cd tmp/lfs-hst-gcc2/bld && mkdir -pv $(LFS_TGT)/libgcc && cd $(LFS_TGT)/libgcc && ln -sfv ../../../gcc-$(GCC_VER)/libgcc/gthr-posix.h gthr-default.h
	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-gcc2/bld && ../gcc-$(GCC_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(GCC2_OPT1) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
	rm -fr tmp/lfs-hst-gcc2/ins/usr/share
	find tmp/lfs-hst-gcc2/ins -name \*.la -delete
	mv tmp/lfs-hst-gcc2/ins/usr/lib64/* tmp/lfs-hst-gcc2/ins/usr/lib/
	rm -fr tmp/lfs-hst-gcc2/ins/usr/lib64
	cd tmp/lfs-hst-gcc2/ins && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/lfs-hst-gcc2/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../pkg1/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst
	rm -fr tmp/lfs-hst-gcc2
lfs/usr/libexec/gcc/aarch64-rk3588-linux-gnu/$(GCC_VER)/install-tools/fixinc.sh: pkg1/lfs-hst-gcc-$(GCC_VER).pass2.cpio.zst
	pv $< | zstd -d | cpio -iduH newc -D lfs
hst-gcc2: lfs/usr/libexec/gcc/aarch64-rk3588-linux-gnu/$(GCC_VER)/install-tools/fixinc.sh

# === LFS-10.0-systemd :: 7.2. Changing Ownership :: (deps : hst-gcc2)
# === LFS-10.0-systemd :: 7.3. Preparing Virtual Kernel File Systems 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/changingowner.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/kernfs.html
# BUILD TIME :: 13s
pkg1/lfs-hst-full.cpio.zst: lfs/usr/libexec/gcc/aarch64-rk3588-linux-gnu/$(GCC_VER)/install-tools/fixinc.sh
	mkdir -p tmp
	cp -far lfs tmp/
	rm -fr tmp/lfs/tools
	mkdir -p tmp/lfs/dev/pts
	mkdir tmp/lfs/proc
	mkdir tmp/lfs/sys
	mkdir tmp/lfs/run
	sudo chown -R root:root tmp/lfs/*
	mkdir -p tmp/lfs/opt/mysdk
	cp -far cfg tmp/lfs/opt/mysdk
	cp -far .git tmp/lfs/opt/mysdk
	cp -far .gitignore tmp/lfs/opt/mysdk
	cp -far README.md tmp/lfs/opt/mysdk
	cp -far pkg tmp/lfs/opt/mysdk
	cp -far Makefile tmp/lfs/opt/mysdk
	mkdir -p tmp/lfs/opt/mysdk/pkg2
	cp -far pkg1/lfs-hst-glibc-2.32.cpio.zst tmp/lfs/opt/mysdk/pkg2/
	cd tmp/lfs && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../pkg1/lfs-hst-full.cpio.zst
	sudo rm -fr tmp/lfs

# === TOTAL: STAGE0 = HOST BUILD
# BUILD_TIME :: about 45 minutes
#
hst: pkg1/lfs-hst-full.cpio.zst

hst-clean:
	sudo rm -fr /tmp/*
	sudo rm -fr lfs2

# chroot "$LFS" /usr/bin/env -i   \
#    HOME=/root                  \
#    TERM="$TERM"                \
#    PS1='(lfs chroot) \u:\w\$ ' \
#    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
#    /bin/bash --login +h

# === my extra :: Unpack New LFS-ROOTFS (lfs2)
#
lfs2/opt/mysdk/Makefile: pkg1/lfs-hst-full.cpio.zst
	mkdir -p lfs2
	pv $< | zstd -d | cpio -iduH newc -D lfs2
lfs2/opt/mysdk/chroot.sh: lfs2/opt/mysdk/Makefile
	mkdir -p lfs2/opt/mysdk
	echo '#!/bin/bash' > $@
	echo 'make -C /opt/mysdk tgt' >> $@
	chmod ugo+x $@

# === LFS-10.0-systemd :: 7.3. Preparing Virtual Kernel File Systems 
# === LFS-10.0-systemd :: 7.4. Entering the Chroot Environment 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/kernfs.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/chroot.html
chroot: lfs2/opt/mysdk/chroot.sh
	sudo mount -v --bind /dev lfs2/dev
	sudo mount -v --bind /dev/pts lfs2/dev/pts
	sudo mount -vt proc proc lfs2/proc
	sudo mount -vt sysfs sysfs lfs2/sys
	sudo mount -vt tmpfs tmpfs lfs2/run
#	sudo chroot lfs2 /usr/bin/env -i HOME=/root TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin /opt/mysdk/chroot.sh --login +h
	sudo chroot lfs2 /usr/bin/env -i HOME=/root TERM=$$TERM PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh --login +h
	sudo umount lfs2/run
	sudo umount lfs2/sys
	sudo umount lfs2/proc
	sudo umount lfs2/dev/pts
	sudo umount lfs2/dev

unchroot:
	sudo umount lfs2/run || true
	sudo umount lfs2/sys || true
	sudo umount lfs2/proc || true
	sudo umount lfs2/dev/pts || true
	sudo umount lfs2/dev || true

# === CHROOT HERE

tgt-clean-tmp:
	rm -fr tmp

# === LFS-10.0-systemd :: INSIDE CHROOT :: 7.5. Creating Directories 	
# === LFS-10.0-systemd :: INSIDE CHROOT :: 7.6. Creating Essential Files and Symlinks
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/creatingdirs.html
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/createfiles.html
/etc/group:
	echo 'root:x:0:' > $@
	echo 'bin:x:1:daemon' >> $@
	echo 'sys:x:2:' >> $@
	echo 'kmem:x:3:' >> $@
	echo 'tape:x:4:' >> $@
	echo 'tty:x:5:' >> $@
	echo 'daemon:x:6:' >> $@
	echo 'floppy:x:7:' >> $@
	echo 'disk:x:8:' >> $@
	echo 'lp:x:9:' >> $@
	echo 'dialout:x:10:' >> $@
	echo 'audio:x:11:' >> $@
	echo 'video:x:12:' >> $@
	echo 'utmp:x:13:' >> $@
	echo 'usb:x:14:' >> $@
	echo 'cdrom:x:15:' >> $@
	echo 'adm:x:16:' >> $@
	echo 'messagebus:x:18:' >> $@
	echo 'systemd-journal:x:23:' >> $@
	echo 'input:x:24:' >> $@
	echo 'mail:x:34:' >> $@
	echo 'kvm:x:61:' >> $@
	echo 'systemd-bus-proxy:x:72:' >> $@
	echo 'systemd-journal-gateway:x:73:' >> $@
	echo 'systemd-journal-remote:x:74:' >> $@
	echo 'systemd-journal-upload:x:75:' >> $@
	echo 'systemd-network:x:76:' >> $@
	echo 'systemd-resolve:x:77:' >> $@
	echo 'systemd-timesync:x:78:' >> $@
	echo 'systemd-coredump:x:79:' >> $@
	echo 'wheel:x:97:' >> $@
	echo 'nogroup:x:99:' >> $@
	echo 'users:x:999:' >> $@
	touch $@
/etc/passwd: /etc/group
	echo 'root::0:0:root:/root:/bin/bash' > $@
	echo 'bin:x:1:1:bin:/dev/null:/bin/false' >> $@
	echo 'daemon:x:6:6:Daemon User:/dev/null:/bin/false' >> $@
	echo 'messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false' >> $@
	echo 'systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false' >> $@
	echo 'systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false' >> $@
	echo 'systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false' >> $@
	echo 'systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false' >> $@
	echo 'systemd-network:x:76:76:systemd Network Management:/:/bin/false' >> $@
	echo 'systemd-resolve:x:77:77:systemd Resolver:/:/bin/false' >> $@
	echo 'systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false' >> $@
	echo 'systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false' >> $@
	echo 'nobody:x:99:99:Unprivileged User:/dev/null:/bin/false' >> $@
	mknod -m 600 /dev/console c 5 1
	mknod -m 666 /dev/null c 1 3
	mkdir -pv /boot
	mkdir -pv /home
	mkdir -pv /media
	mkdir -pv /mnt
	mkdir -pv /srv
	mkdir -pv /etc/opt
	mkdir -pv /etc/sysconfig
# mkdir -pv /lib/firmware
# mkdir -pv /media/{floppy,cdrom}
# mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
# mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
# mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
# mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/cache
	mkdir -pv /var/local
	mkdir -pv /var/log
	mkdir -pv /var/mail
	mkdir -pv /var/opt
	mkdir -pv /var/spool
	mkdir -pv /var/lib/color
	mkdir -pv /var/lib/misc
	mkdir -pv /var/lib/locate
	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	ln -sfv /proc/self/mounts /etc/mtab
	sh -c 'echo "127.0.0.1 localhost `hostname`" > /etc/hosts'
	sh -c 'echo "tester:x:`ls -n $$(tty) | cut -d" " -f3`:101::/home/tester:/bin/bash" >> /etc/passwd'
	sh -c 'echo "tester:x:101:" >> /etc/group'
	sh -c 'cd / && install -o tester -d /home/tester'
	touch /var/log/btmp
	touch /var/log/lastlog
	touch /var/log/faillog
	touch /var/log/wtmp
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
	touch $@

# LFS-10.0-systemd :: CHROOT :: 7.7. Libstdc++ from GCC-10.2.0, Pass 2 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/gcc-libstdc++-pass2.html
# BUILD_TIME :: 1m 35s
LIBCPP2_OPT2+= --prefix=/usr
LIBCPP2_OPT2+= --disable-multilib
LIBCPP2_OPT2+= --disable-nls
LIBCPP2_OPT2+= --disable-libstdcxx-pch
LIBCPP2_OPT2+= CFLAGS="$(BASE_OPT_FLAGS)" CPPFLAGS="$(BASE_OPT_FLAGS)" CXXFLAGS="$(BASE_OPT_FLAGS) -D_GNU_SOURCE"
LIBCPP2_OPT2+= --host=$(LFS_TGT)
pkg2/lfs-tgt-libcpp.pass2.cpio.zst: /etc/passwd
	mkdir -p tmp/tgt-gcc-libcpp/bld
	mkdir -p tmp/tgt-gcc-libcpp/ins
	tar -xJf pkg/gcc-$(GCC_VER).tar.xz -C tmp/tgt-gcc-libcpp
	tar -xJf pkg/gmp-$(GMP_VER).tar.xz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v gmp-$(GMP_VER) gmp
	tar -xJf pkg/mpfr-$(MPFR_VER).tar.xz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v mpfr-$(MPFR_VER) mpfr
	tar -xzf pkg/mpc-$(MPC_VER).tar.gz -C tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && cd tmp/tgt-gcc-libcpp/gcc-$(GCC_VER) && mv -v mpc-$(MPC_VER) mpc
	cd tmp/tgt-gcc-libcpp/bld && ../gcc-$(GCC_VER)/libstdc++-v3/configure $(LIBCPP2_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	mv -v tmp/tgt-gcc-libcpp/ins/usr/lib64/* tmp/tgt-gcc-libcpp/ins/usr/lib/
	rm -fr tmp/tgt-gcc-libcpp/ins/usr/lib64
	rm -fr tmp/tgt-gcc-libcpp/ins/usr/lib/*.la
	strip --strip-debug tmp/tgt-gcc-libcpp/ins/usr/lib/*.a
	strip --strip-unneeded tmp/tgt-gcc-libcpp/ins/usr/lib/libstdc++.so.6.0.28
	mkdir -p pkg2
	cd tmp/tgt-gcc-libcpp/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-gcc-libcpp
	pv $@ | zstd -d | cpio -iduH newc -D /
 
# LFS-10.0-systemd :: CHROOT :: 7.8. Gettext-0.21
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/gettext.html
# BUILD_TIME :: 6m 30s
GETTEXT_OPT2+= --prefix=/usr
GETTEXT_OPT2+= --disable-shared
GETTEXT_OPT2+= --disable-nls
GETTEXT_OPT2+= $(OPT_FLAGS)
pkg2/lfs-tgt-gettext-$(GETTEXT_VER).cpio.zst: pkg2/lfs-tgt-libcpp.pass2.cpio.zst
	mkdir -p tmp/tgt-gettext
	tar -xJf pkg/gettext-$(GETTEXT_VER).tar.xz -C tmp/tgt-gettext
	mkdir -p tmp/tgt-gettext/bld
	cd tmp/tgt-gettext/bld && ../gettext-$(GETTEXT_VER)/configure $(GETTEXT_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-gettext/ins/usr/share/doc
	rm -fr tmp/tgt-gettext/ins/usr/share/gettext/projects
	rm -fr tmp/tgt-gettext/ins/usr/share/info
	rm -fr tmp/tgt-gettext/ins/usr/share/man
	strip --strip-unneeded tmp/tgt-gettext/ins/usr/bin/* || true
	strip --strip-unneeded tmp/tgt-gettext/ins/usr/lib/gettext/* || true
	rm -fr tmp/tgt-gettext/ins/usr/lib/*.la
	strip --strip-debug tmp/tgt-gettext/ins/usr/lib/*.a
	cd tmp/tgt-gettext/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-gettext
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: CHROOT :: 7.9. Bison-3.7.1
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/bison.html
# BUILD_TIME :: 1m 4s
BISON_OPT2+= --prefix=/usr
BISON_OPT2+= --docdir=/usr/share/doc/bison-$(BISON_VER)
BISON_OPT2+= --disable-nls
BISON_OPT2+= $(OPT_FLAGS)
pkg2/lfs-tgt-bison-$(BISON_VER).cpio.zst: pkg2/lfs-tgt-gettext-$(GETTEXT_VER).cpio.zst
	mkdir -p tmp/tgt-bison
	tar -xJf pkg/bison-$(BISON_VER).tar.xz -C tmp/tgt-bison
	mkdir -p tmp/tgt-bison/bld
	cd tmp/tgt-bison/bld && ../bison-$(BISON_VER)/configure $(BISON_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-bison/ins/usr/share/bison/README.md
	rm -fr tmp/tgt-bison/ins/usr/share/doc
	rm -fr tmp/tgt-bison/ins/usr/share/info
	rm -fr tmp/tgt-bison/ins/usr/share/man
	strip --strip-debug tmp/tgt-bison/ins/usr/lib/*.a
	strip --strip-unneeded tmp/tgt-bison/ins/usr/bin/bison
	cd tmp/tgt-bison/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-bison
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: CHROOT :: 7.10. Perl-5.32.0 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/perl.html
# BUILD_TIME :: 3m 50s
PERL_POPT2+= -des
PERL_POPT2+= -Dcc=gcc
PERL_POPT2+= -Dprefix=/usr
PERL_POPT2+= -Dvendorprefix=/usr
PERL_POPT2+= -Dprivlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT2+= -Darchlib=/usr/lib/perl5/$(PERL_VER0)/core_perl
PERL_POPT2+= -Dsitelib=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT2+= -Dsitearch=/usr/lib/perl5/$(PERL_VER0)/site_perl
PERL_POPT2+= -Dvendorlib=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT2+= -Dvendorarch=/usr/lib/perl5/$(PERL_VER0)/vendor_perl
PERL_POPT2+= -Doptimize="$(BASE_OPT_FLAGS)"	
pkg2/lfs-tgt-perl-$(PERL_VER).cpio.zst: pkg2/lfs-tgt-bison-$(BISON_VER).cpio.zst
	mkdir -p tmp/tgt-perl
	tar -xJf pkg/perl-$(PERL_VER).tar.xz -C tmp/tgt-perl
	cd tmp/tgt-perl/perl-$(PERL_VER) && sh Configure $(PERL_POPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins2 install
	mkdir -p tmp/tgt-perl/ins
	cp -far tmp/tgt-perl/ins2/usr tmp/tgt-perl/ins/
	cd tmp/tgt-perl/ins/ && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	strip --strip-debug tmp/tgt-perl/ins/usr/lib/perl5/$(PERL_VER0)/core_perl/CORE/*.a
	cd tmp/tgt-perl/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-perl
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: CHROOT :: 7.11. Python-3.8.5 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/Python.html
# BUILD_TIME :: 2m 20s
PYTHON_OPT2+= --prefix=/usr
PYTHON_OPT2+= --enable-shared
PYTHON_OPT2+= --without-ensurepip
PYTHON_OPT2+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg2/lfs-tgt-Python-$(PYTHON_VER).cpio.zst: pkg2/lfs-tgt-perl-$(PERL_VER).cpio.zst
	mkdir -p tmp/tgt-python
	tar -xJf pkg/Python-$(PYTHON_VER).tar.xz -C tmp/tgt-python
	sed -i "s/-O3/$(BASE_OPT_VALUE)/" tmp/tgt-python/Python-$(PYTHON_VER)/configure
	mkdir -p tmp/tgt-python/bld
	cd tmp/tgt-python/bld && ../Python-$(PYTHON_VER)/configure $(PYTHON_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-python/ins/usr/share
	find tmp/tgt-python/ins/usr/lib -type f -name "*.a" -exec strip --strip-debug {} +
	strip --strip-unneeded tmp/tgt-python/ins/usr/bin/python3
	cd  tmp/tgt-python/ins/usr/lib/ && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/tgt-python/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-python
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: CHROOT :: 7.12. Texinfo-6.7 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/texinfo.html
# BUILD_TIME :: 58s
TEXINFO_OPT2+= --prefix=/usr
TEXINFO_OPT2+= --disable-nls
TEXINFO_OPT2+= $(OPT_FLAGS)
pkg2/lfs-tgt-texinfo-$(TEXINFO_VER).cpio.zst: pkg2/lfs-tgt-Python-$(PYTHON_VER).cpio.zst
	mkdir -p tmp/tgt-texinfo
	tar -xJf pkg/texinfo-$(TEXINFO_VER).tar.xz -C tmp/tgt-texinfo
	mkdir -p tmp/tgt-texinfo/bld
	cd tmp/tgt-texinfo/bld && ../texinfo-$(TEXINFO_VER)/configure $(TEXINFO_OPT2) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install
	rm -fr tmp/tgt-texinfo/ins/usr/share/info
	rm -fr tmp/tgt-texinfo/ins/usr/share/man
	strip --strip-unneeded tmp/tgt-texinfo/ins/usr/bin/install-info
	rm -fr tmp/tgt-texinfo/ins/usr/lib/texinfo/*.la
	strip --strip-unneeded tmp/tgt-texinfo/ins/usr/lib/texinfo/*.so
	cd tmp/tgt-texinfo/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-texinfo
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: CHROOT :: 7.13. Util-linux-2.36
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter07/util-linux.html
# BUILD_TIME :: 1m 22s
UTIL_LINUX_OPT2+= ADJTIME_PATH=/var/lib/hwclock/adjtime
UTIL_LINUX_OPT2+= --docdir=/usr/share/doc/util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_OPT2+= --disable-chfn-chsh
UTIL_LINUX_OPT2+= --disable-login
UTIL_LINUX_OPT2+= --disable-nologin
UTIL_LINUX_OPT2+= --disable-su
UTIL_LINUX_OPT2+= --disable-setpriv
UTIL_LINUX_OPT2+= --disable-runuser
UTIL_LINUX_OPT2+= --disable-pylibmount
UTIL_LINUX_OPT2+= --disable-static
UTIL_LINUX_OPT2+= --without-python
UTIL_LINUX_OPT2+= --disable-nls
UTIL_LINUX_OPT2+= --enable-usrdir-path
UTIL_LINUX_OPT2+= $(OPT_FLAGS)
pkg2/lfs-tgt-util-linux-$(UTIL_LINUX_VER).cpio.zst: pkg2/lfs-tgt-texinfo-$(TEXINFO_VER).cpio.zst
	mkdir -pv /var/lib/hwclock
	mkdir -p tmp/tgt-util-linux
	tar -xJf pkg/util-linux-$(UTIL_LINUX_VER).tar.xz -C tmp/tgt-util-linux
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
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/lib/*.so*
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/bin/*
	strip --strip-unneeded tmp/tgt-util-linux/ins/usr/sbin/*
	cd tmp/tgt-util-linux/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tgt-util-linux
	pv $@ | zstd -d | cpio -iduH newc -D /

# LFS-10.0-systemd :: 8.3. Man-pages-5.08 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/man-pages.html
# SKIP THIS
# You can install it using "pkg/man-pages-5.08.tar.xz"

# LFS-10.0-systemd :: 8.4. Tcl-8.6.10 
# https://www.linuxfromscratch.org/lfs/view/10.0-systemd/chapter08/tcl.html
# BUILD_TIME :: 3m 3s
# BUILD_TIME_WITH_TEST :: 8m 1s
# NOTE: Skip unpack documentation. You can do it from "pkg/tcl8.6.10-html.tar.gz"
TCL_OPT3+= --prefix=/usr
TCL_OPT3+= --mandir=/usr/share/man
TCL_OPT3+= --enable-64bit
TCL_OPT3+= CFLAGS="$(RK3588_FLAGS)" CPPFLAGS="$(RK3588_FLAGS)" CXXFLAGS="$(RK3588_FLAGS)"
pkg3/tcl$(TCL_VER).cpio.zst: pkg2/lfs-tgt-util-linux-$(UTIL_LINUX_VER).cpio.zst
	mkdir -p pkg3
	mkdir -p tmp/tcl/bld
	tar -xzf pkg/tcl$(TCL_VER)-src.tar.gz -C tmp/tcl
	sed -i "s/-O2/$(BASE_OPT_VALUE)/" tmp/tcl/tcl$(TCL_VER)/unix/configure
	cd tmp/tcl/bld && ../tcl$(TCL_VER)/unix/configure $(TCL_OPT3) && make $(JOBS) V=$(VERB)
	sed -i "s|`pwd`/tmp/tcl/bld|/usr/lib|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)|/usr/include|" tmp/tcl/bld/tclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/generic|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1|/usr/include|" tmp/tcl/bld/pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -i "s|`pwd`/tmp/tcl/bld/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0/generic|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0|/usr/include|" tmp/tcl/bld/pkgs/itcl4.2.0/itclConfig.sh
	cd tmp/tcl/bld && make test
# TESTS ARE PASSED, except some with clock. See LFS-note in book "In the test results there are several places associated with clock.test that indicate a failure, but the summary at the end indicates no failures. clock.test passes on a complete LFS system.". We can comment "make test" for future to speed-up build.
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install
	cd tmp/tcl/bld && make DESTDIR=`pwd`/../ins install-private-headers
	rm -fr tmp/tcl/ins/usr/share/man
	strip --strip-unneeded tmp/tcl/ins/usr/bin/tclsh$(TCL_VER_BRIEF)
	cd tmp/tcl/ins/usr/bin && ln -sf tclsh$(TCL_VER_BRIEF) tclsh
	find tmp/tcl/ins/usr/lib -type f -name "*.a" -exec strip --strip-debug {} +
	chmod -v u+w tmp/tcl/ins/usr/lib/libtcl$(TCL_VER_BRIEF).so
	cd tmp/tcl/ins/usr/lib && strip --strip-unneeded $$(find . -type f -exec file {} + | grep ELF | cut -d: -f1)
	cd tmp/tcl/ins && find . -print0 | cpio -o0H newc | zstd -z9T9 > ../../../$@
	rm -fr tmp/tcl
	pv $@ | zstd -d | cpio -iduH newc -D /

#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/unix|/usr/lib|" tmp/tcl/tcl$(TCL_VER)/unix/tclConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)|/usr/include|" tmp/tcl/tcl$(TCL_VER)/unix/tclConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/unix/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/tdbc1.1.1/tdbcConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/generic|/usr/include|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/tdbc1.1.1/tdbcConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/tdbc1.1.1/tdbcConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/tdbc1.1.1|/usr/include|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/tdbc1.1.1/tdbcConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/unix/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/itcl4.2.0/itclConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0/generic|/usr/include|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/itcl4.2.0/itclConfig.sh
#	sed -i "s|`pwd`/tmp/tcl/tcl$(TCL_VER)/pkgs/itcl4.2.0|/usr/include|" tmp/tcl/tcl$(TCL_VER)/unix/pkgs/itcl4.2.0/itclConfig.sh


#unix/tclConfig.sh
#TCL_BUILD_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix -ltcl8.6'
#TCL_BUILD_STUB_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix -ltclstub8.6'
#TCL_BUILD_STUB_LIB_PATH='/opt/mysdk/tmp/tcl/tcl8.6.10/unix/libtclstub8.6.a'
#TCL_SRC_DIR='/opt/mysdk/tmp/tcl/tcl8.6.10'

#unix/pkgs/tdbc1.1.1/tdbcConfig.sh
#tdbc_BUILD_LIB_SPEC="-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1 -ltdbc1.1.1"
#TDBC_BUILD_LIB_SPEC="-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1 -ltdbc1.1.1"
#tdbc_BUILD_STUB_LIB_SPEC="-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1 -ltdbcstub1.1.1"
#TDBC_BUILD_STUB_LIB_SPEC="-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1 -ltdbcstub1.1.1"
#tdbc_BUILD_STUB_LIB_PATH="/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1/libtdbcstub1.1.1.a"
#TDBC_BUILD_STUB_LIB_PATH="/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/tdbc1.1.1/libtdbcstub1.1.1.a"
#tdbc_SRC_DIR="/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1"
#TDBC_SRC_DIR="/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1"
#tdbc_BUILD_INCLUDE_SPEC="-I/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1/generic"
#TDBC_BUILD_INCLUDE_SPEC="-I/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1/generic"
#tdbc_BUILD_LIBRARY_PATH="/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1/library"
#TDBC_BUILD_LIBRARY_PATH="/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/tdbc1.1.1/library"

#unix/pkgs/itcl4.2.0/itclConfig.sh
#itcl_BUILD_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0 -litcl4.2.0'
#ITCL_BUILD_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0 -litcl4.2.0'
#itcl_BUILD_STUB_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0 -litclstub4.2.0'
#ITCL_BUILD_STUB_LIB_SPEC='-L/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0 -litclstub4.2.0'
#itcl_BUILD_STUB_LIB_PATH='/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0/libitclstub4.2.0.a'
#ITCL_BUILD_STUB_LIB_PATH='/opt/mysdk/tmp/tcl/tcl8.6.10/unix/pkgs/itcl4.2.0/libitclstub4.2.0.a'
#itcl_SRC_DIR='/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/itcl4.2.0'
#ITCL_SRC_DIR='/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/itcl4.2.0'
#itcl_INCLUDE_SPEC='-I/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/itcl4.2.0/generic'
#ITCL_INCLUDE_SPEC='-I/opt/mysdk/tmp/tcl/tcl8.6.10/pkgs/itcl4.2.0/generic'


tgt: pkg3/tcl$(TCL_VER).cpio.zst









#ZLIB_OPT1+= --prefix=/usr
#ZLIB_OPT1+= --host=$(LFS_TGT)
#ZLIB_OPT1+= $(OPT_FLAGS)


# === ZLIB cross
#parts/cross-zlib/zlib-$(ZLIB_VER)/README: pkg/zlib-$(ZLIB_VER).tar.xz $(LFS)/usr/bin/xz
#	mkdir -p parts/cross-zlib
#	tar -xJf $< -C parts/cross-zlib && touch $@
#	sed -i "s/-O3/$(BASE_OPT_FLAGS)/" parts/cross-zlib/zlib-$(ZLIB_VER)/configure
#parts/cross-zlib/bld/Makefile: parts/cross-zlib/zlib-$(ZLIB_VER)/README
#	mkdir -p parts/cross-zlib/bld
#	sh -c '$(PRE_CMD) && cd parts/cross-zlib/bld && ../zlib-$(ZLIB_VER)/configure $(ZLIB_OPT1)'
#$(LFS)/usr/lib/libz.so: parts/cross-zlib/bld/Makefile
#	sh -c '$(PRE_CMD) && cd parts/cross-zlib/bld && make $(JOBS) V=$(VERB) && make DESTDIR=$(LFS) install'
#cross-zlib: $(LFS)/usr/lib/libz.so


# === my extra :: gcc ISL build support
# USES: GMP -- fall to future
# BUILD_TIME ::
#ISL1_OPT+= --prefix=/usr
#ISL1_OPT+= --host=$(LFS_TGT)
#ISL1_OPT+= --with-gcc-arch=aarch64
#ISL1_OPT+= --with-gmp=build
#ISL1_OPT+= --with-sysroot=$(LFS)
#ISL1_OPT+= $(OPT_FLAGS)
#pkg/lfs-hst-isl-$(ISL_VER).cpio.zst: pkg/isl-$(ISL_VER).tar.xz lfs/usr/bin/pv
#	mkdir -p tmp/lfs-hst-isl/bld
#	tar -xJf $< -C tmp/lfs-hst-isl
#	tar -xJf pkg/gmp-$(GMP_VER).tar.xz -C tmp/lfs-hst-isl/isl-$(ISL_VER)
#	mv tmp/lfs-hst-isl/isl-$(ISL_VER)/gmp-$(GMP_VER) tmp/lfs-hst-isl/isl-$(ISL_VER)/gmp
#	sh -c '$(PRE_CMD) && cd tmp/lfs-hst-isl/bld && ../isl-$(ISL_VER)/configure --build=`cat $(LFS)/tools/build-host.txt` $(ISL1_OPT) && make $(JOBS) V=$(VERB) && make DESTDIR=`pwd`/../ins install'
#hst-isl: pkg/lfs-hst-isl-$(ISL_VER).cpio.zst



# DEBIAN11 HOST mounts
#
# cat /proc/mounts
#
# sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
# proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
# udev /dev devtmpfs rw,nosuid,relatime,size=7906324k,nr_inodes=1976581,mode=755 0 0
# devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
# tmpfs /run tmpfs rw,nosuid,nodev,noexec,relatime,size=1609548k,mode=755 0 0
# /dev/mmcblk0p2 / ext4 rw,noatime,errors=remount-ro,commit=600 0 0
# securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
# tmpfs /dev/shm tmpfs rw,nosuid,nodev 0 0
# tmpfs /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
# cgroup2 /sys/fs/cgroup cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot 0 0
# pstore /sys/fs/pstore pstore rw,nosuid,nodev,noexec,relatime 0 0
# none /sys/fs/bpf bpf rw,nosuid,nodev,noexec,relatime,mode=700 0 0
# systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=29,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=19213 0 0
# tracefs /sys/kernel/tracing tracefs rw,nosuid,nodev,noexec,relatime 0 0
# hugetlbfs /dev/hugepages hugetlbfs rw,relatime,pagesize=2M 0 0
# mqueue /dev/mqueue mqueue rw,nosuid,nodev,noexec,relatime 0 0
# sunrpc /run/rpc_pipefs rpc_pipefs rw,relatime 0 0
# debugfs /sys/kernel/debug debugfs rw,nosuid,nodev,noexec,relatime 0 0
# configfs /sys/kernel/config configfs rw,nosuid,nodev,noexec,relatime 0 0
# fusectl /sys/fs/fuse/connections fusectl rw,nosuid,nodev,noexec,relatime 0 0
# tmpfs /tmp tmpfs rw,nosuid,relatime 0 0
# /dev/mmcblk0p1 /boot ext4 rw,relatime,errors=remount-ro,commit=600 0 0
# /dev/mmcblk0p2 /var/log.hdd ext4 rw,noatime,errors=remount-ro,commit=600 0 0
# /dev/zram1 /var/log ext4 rw,relatime,discard 0 0
# tracefs /sys/kernel/debug/tracing tracefs rw,nosuid,nodev,noexec,relatime 0 0
# tmpfs /run/user/1000 tmpfs rw,nosuid,nodev,relatime,size=1609544k,nr_inodes=402386,mode=700,uid=1000,gid=1000 0 0
#
# findmnt
#
# TARGET                          SOURCE                   FSTYPE     OPTIONS
# /                               /dev/mmcblk0p2           ext4       rw,noatime,errors=remount-ro,commit=600
# ├─/sys                          sysfs                    sysfs      rw,nosuid,nodev,noexec,relatime
# │ ├─/sys/kernel/security        securityfs               securityfs rw,nosuid,nodev,noexec,relatime
# │ ├─/sys/fs/cgroup              cgroup2                  cgroup2    rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot
# │ ├─/sys/fs/pstore              pstore                   pstore     rw,nosuid,nodev,noexec,relatime
# │ ├─/sys/fs/bpf                 none                     bpf        rw,nosuid,nodev,noexec,relatime,mode=700
# │ ├─/sys/kernel/tracing         tracefs                  tracefs    rw,nosuid,nodev,noexec,relatime
# │ ├─/sys/kernel/debug           debugfs                  debugfs    rw,nosuid,nodev,noexec,relatime
# │ │ └─/sys/kernel/debug/tracing tracefs                  tracefs    rw,nosuid,nodev,noexec,relatime
# │ ├─/sys/kernel/config          configfs                 configfs   rw,nosuid,nodev,noexec,relatime
# │ └─/sys/fs/fuse/connections    fusectl                  fusectl    rw,nosuid,nodev,noexec,relatime
# ├─/proc                         proc                     proc       rw,nosuid,nodev,noexec,relatime
# │ └─/proc/sys/fs/binfmt_misc    systemd-1                autofs     rw,relatime,fd=29,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=20608
# ├─/dev                          udev                     devtmpfs   rw,nosuid,relatime,size=8035092k,nr_inodes=2008773,mode=755
# │ ├─/dev/pts                    devpts                   devpts     rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000
# │ ├─/dev/shm                    tmpfs                    tmpfs      rw,nosuid,nodev
# │ ├─/dev/hugepages              hugetlbfs                hugetlbfs  rw,relatime,pagesize=2M
# │ └─/dev/mqueue                 mqueue                   mqueue     rw,nosuid,nodev,noexec,relatime
# ├─/run                          tmpfs                    tmpfs      rw,nosuid,nodev,noexec,relatime,size=1635300k,mode=755
# │ ├─/run/lock                   tmpfs                    tmpfs      rw,nosuid,nodev,noexec,relatime,size=5120k
# │ ├─/run/rpc_pipefs             sunrpc                   rpc_pipefs rw,relatime
# │ └─/run/user/1000              tmpfs                    tmpfs      rw,nosuid,nodev,relatime,size=1635296k,nr_inodes=408824,mode=700,uid=1000,gid=1000
# ├─/tmp                          tmpfs                    tmpfs      rw,nosuid,relatime
# ├─/boot                         /dev/mmcblk0p1           ext4       rw,relatime,errors=remount-ro,commit=600
# ├─/var/log.hdd                  /dev/mmcblk0p2[/var/log] ext4       rw,noatime,errors=remount-ro,commit=600
# └─/var/log                      /dev/zram1               ext4       rw,relatime,discard

