VERB=1
JOB=12
JOBS=-j$(JOB)
GIT_RM=y
BUILD_STRIP=y
STRIP_BUILD_ELF=--strip-all
STRIP_BUILD_BIN=--strip-all
STRIP_BUILD_LIB=--strip-all
STRIP_BUILD_AST=--strip-debug
RUN_TESTS=n
RK3588_AFLG = +crypto
RK3588_MCPU = cortex-a76.cortex-a55$(RK3588_AFLG)
RK3588_ARCH = armv8.2-a+lse+rdma+crc+fp16+rcpc+dotprod$(RK3588_AFLG)
RK3588_FLAGS = -mcpu=$(RK3588_MCPU)
# OPTIMIZATION FLAG: s 2 3
BASE_OPT_VAL=3
BASE_OPT_VALUE = -O$(BASE_OPT_VAL)
ifeq ($(BASE_OPT_VALUE),-O1)
 $(error BASE_OPT_VALUE = -O1 : is not supported)
endif
ifeq ($(BASE_OPT_VALUE),-O0)
 $(error BASE_OPT_VALUE = -O0 : is not supported)
endif
BASE_OPT_FLAGS = $(RK3588_FLAGS) $(BASE_OPT_VALUE)
OPT_FLAGS = CFLAGS="$(BASE_OPT_FLAGS)" CPPFLAGS="$(BASE_OPT_FLAGS)" CXXFLAGS="$(BASE_OPT_FLAGS)"
TODAY_CODE=$(shell date +"%Y%m%d")

src/.gitignore:
	mkdir -p src && touch $@
