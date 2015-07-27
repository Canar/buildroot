################################################################################
#
# Common variables for the gcc-initial and gcc-final packages.
#
################################################################################
GCC_VERSION = $(call qstrip,$(BR2_GCC_VERSION))
GCC_SOURCE ?= gcc-$(GCC_VERSION).tar.bz2
GCC_LANGUAGES = c
GCC_COMMON_CONF_OPTS =

ifeq ($(BR2_arc),y)
GCC_SITE = $(call github,foss-for-synopsys-dwc-arc-processors,gcc,$(GCC_VERSION))
GCC_SOURCE = gcc-$(GCC_VERSION).tar.gz
else
GCC_SITE = $(BR2_GNU_MIRROR:/=)/gcc/gcc-$(GCC_VERSION)
endif

# Space-saving custom exclude dirs
GCC_EXCLUDE_DIR= --exclude='libjava/*' \
		--exclude='libgo/*' \
		--exclude='gcc/testsuite/*' \
		--exclude='libstdc++-v3/testsuite/*'

# Xtensa special hook
define HOST_GCC_XTENSA_OVERLAY_EXTRACT
	tar xf $(BR2_XTENSA_OVERLAY_DIR)/xtensa_$(call qstrip,\
		$(BR2_XTENSA_CORE_NAME)).tar -C $(@D) --strip-components=1 gcc
endef

ifeq ($(BR2_SOFT_FLOAT),y)
# only mips*-*-*, arm*-*-* and sparc*-*-* accept --with-float
# powerpc seems to be needing it as well
ifeq ($(BR2_arm)$(BR2_armeb)$(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el)$(BR2_powerpc)$(BR2_sparc),y)
GCC_COMMON_CONF_OPTS += --with-float=soft
endif
else
ifeq ($(ARCH),powerpc)
define GCC_APPLY_POWERPC_PATCH
	$(APPLY_PATCHES) $(@D) package/gcc/$(GCC_VERSION) 1000-powerpc-link-with-math-lib.patch.conditional
endef
endif
endif

define GCC_APPLY_PATCHES
	if test -d package/gcc/$(GCC_VERSION); then \
	  $(APPLY_PATCHES) $(@D) package/gcc/$(GCC_VERSION) \*.patch ; \
	fi;
	$(GCC_APPLY_POWERPC_PATCH)
endef

define GCC_EXTRACT_CMDS
	$(call suitable-extractor,$(GCC_SOURCE)) $(DL_DIR)/$(GCC_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D) \
		$(GCC_EXCLUDE_DIR) \
		$(TAR_OPTIONS) -
	mkdir -p $(@D)/libstdc++-v3/testsuite/
	echo "all:" > $(@D)/libstdc++-v3/testsuite/Makefile.in
	echo "install:" >> $(@D)/libstdc++-v3/testsuite/Makefile.in
endef

# Create 'build' directory and configure symlink
define GCC_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef

# Common configuration options
# GCC_COMMON: initial, final, target
# GCC_GOOD: final, target
HOST_GCC_COMMON_DEPENDENCIES = \
	host-binutils \
	host-gmp \
	host-mpfr \
	$(if $(BR2_BINFMT_FLAT),host-elf2flt)
GCC_TARG_DEPENDENCIES = $(subst host-,,$(HOST_GCC_COMMON_DEPENDENCIES))
GCC_COMMON_CONF_OPTS += \
	--target=$(GNU_TARGET_NAME) \
	--disable-__cxa_atexit \
	--with-gnu-ld \
	--disable-multilib \
	--with-pkgversion="Buildroot $(BR2_VERSION_FULL)" \
	--with-bugurl="http://bugs.buildroot.net/"
GCC_GOOD_CONF_OPTS += \
	--enable-languages=$(GCC_LANGUAGES) \
	--enable-poison-system-directories \
	$(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))

GCC_COMMON_TARGET_CFLAGS = $(TARGET_CFLAGS)
GCC_COMMON_TARGET_CXXFLAGS = $(TARGET_CXXFLAGS)

# Xtensa libgcc can't be built with -mtext-section-literals
# because of the trick used to generate .init/.fini sections.
ifeq ($(BR2_xtensa),y)
GCC_COMMON_TARGET_CFLAGS = $(filter-out -mtext-section-literals,$(TARGET_CFLAGS))
GCC_COMMON_TARGET_CXXFLAGS = $(filter-out -mtext-section-literals,$(TARGET_CXXFLAGS))
GCC_GOOD_CONF_OPTS += --enable-cxx-flags="$(TARGET_ABI)"
endif

# Propagate options used for target software building to GCC target libs
GCC_COMMON_CONF_ENV = MAKEINFO=missing
GCC_COMMON_CONF_ENV += CFLAGS_FOR_TARGET="$(GCC_COMMON_TARGET_CFLAGS)"
GCC_COMMON_CONF_ENV += CXXFLAGS_FOR_TARGET="$(GCC_COMMON_TARGET_CXXFLAGS)"

# libitm needs sparc V9+
ifeq ($(BR2_sparc_v8)$(BR2_sparc_leon3),y)
GCC_COMMON_CONF_OPTS += --disable-libitm
endif

# libsanitizer requires wordexp, not in default uClibc config. Also
# doesn't build properly with musl.
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_UCLIBC)$(BR2_TOOLCHAIN_BUILDROOT_MUSL),y)
GCC_COMMON_CONF_OPTS += --disable-libsanitizer
endif

# libsanitizer is broken for SPARC
# https://bugs.busybox.net/show_bug.cgi?id=7951
ifeq ($(BR2_sparc),y)
GCC_COMMON_CONF_OPTS += --disable-libsanitizer
endif

ifeq ($(BR2_GCC_ENABLE_TLS),y)
GCC_COMMON_CONF_OPTS += --enable-tls
else
GCC_COMMON_CONF_OPTS += --disable-tls
endif

ifeq ($(BR2_GCC_ENABLE_LTO),y)
GCC_LANGUAGES += lto
GCC_COMMON_CONF_OPTS += --enable-plugins --enable-lto
endif

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
GCC_LANGUAGES += c++
GCC_GOOD_USR_LIBS += libstdc++
endif

ifeq ($(BR2_TOOLCHAIN_BUILDROOT_FORTRAN),y)
GCC_LANGUAGES += fortran
GCC_GOOD_USR_LIBS += libgfortran
else
GCC_EXCLUDE_DIR += --exclude='libgfortran/*'
endif

# Disable shared libs like libstdc++ if we do static since it confuses linking
ifeq ($(BR2_STATIC_LIBS),y)
GCC_GOOD_CONF_OPTS += --disable-shared
else
GCC_GOOD_CONF_OPTS += --enable-shared
endif

ifeq ($(BR2_GCC_ENABLE_LIBMUDFLAP),y)
GCC_COMMON_CONF_OPTS += --enable-libmudflap
else
GCC_COMMON_CONF_OPTS += --disable-libmudflap
endif

ifeq ($(BR2_PTHREADS_NONE),y)
GCC_COMMON_CONF_OPTS += \
	--disable-threads \
	--disable-libitm \
	--disable-libatomic
else
GCC_COMMON_CONF_OPTS += --enable-threads
endif

ifeq ($(BR2_GCC_SUPPORTS_FINEGRAINEDMTUNE),y)
GCC_COMMON_CONF_OPTS += --disable-decimal-float
endif

# Determine arch/tune/abi/cpu options
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ARCH)),)
GCC_COMMON_CONF_OPTS += --with-arch=$(BR2_GCC_TARGET_ARCH)
endif

ifneq ($(call qstrip,$(BR2_GCC_TARGET_ABI)),)
GCC_COMMON_CONF_OPTS += --with-abi=$(BR2_GCC_TARGET_ABI)
endif

ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU)),)
ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU_REVISION)),)
GCC_COMMON_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU)-$(BR2_GCC_TARGET_CPU_REVISION))
else
GCC_COMMON_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU))
endif
endif

GCC_TARGET_FPU = $(call qstrip,$(BR2_GCC_TARGET_FPU))
ifneq ($(GCC_TARGET_FPU),)
GCC_COMMON_CONF_OPTS += --with-fpu=$(GCC_TARGET_FPU)
endif

GCC_TARGET_FLOAT_ABI = $(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
ifneq ($(GCC_TARGET_FLOAT_ABI),)
GCC_COMMON_CONF_OPTS += --with-float=$(GCC_TARGET_FLOAT_ABI)
endif

GCC_TARGET_MODE = $(call qstrip,$(BR2_GCC_TARGET_MODE))
ifneq ($(GCC_TARGET_MODE),)
GCC_COMMON_CONF_OPTS += --with-mode=$(GCC_TARGET_MODE)
endif

# Enable proper double/long double for SPE ABI
ifeq ($(BR2_powerpc_SPE),y)
GCC_COMMON_CONF_OPTS += \
	--enable-e500_double \
	--with-long-double-128
endif

GCC_GOOD_CONF_OPTS = \
	--disable-libssp

HOST_GCC_COMMON_CONF_OPTS = \
	$(GCC_COMMON_CONF_OPTS) \
	$(GCC_GOOD_CONF_OPTS) \
	--with-sysroot=$(STAGING_DIR) \
	--with-gmp=$(HOST_DIR)/usr \
	--with-mpfr=$(HOST_DIR)/usr \
	--with-mpc=$(HOST_DIR)/usr
GCC_TARG_CONF_OPTS = \
	$(GCC_COMMON_CONF_OPTS) \
	$(GCC_GOOD_CONF_OPTS) \
	--with-gmp=$(TARGET_DIR)/usr \
	--with-mpfr=$(TARGET_DIR)/usr \
	--with-mpc=$(TARGET_DIR)/usr 

HOST_GCC_COMMON_DEPENDENCIES += host-mpc
GCC_COMMON_DEPENDENCIES += mpc

ifeq ($(BR2_GCC_ENABLE_GRAPHITE),y)
HOST_GCC_COMMON_DEPENDENCIES += host-isl host-cloog
HOST_GCC_COMMON_CONF_OPTS += --with-isl=$(HOST_DIR)/usr --with-cloog=$(HOST_DIR)/usr
GCC_TARG_DEPENDENCIES += isl cloog
GCC_TARG_CONF_OPTS += --with-isl=$(TARGET_DIR)/usr --with-cloog=$(TARGET_DIR)/usr
else
HOST_GCC_COMMON_CONF_OPTS += --without-isl --without-cloog
GCC_TARG_CONF_OPTS += --without-isl --without-cloog
endif

include $(sort $(wildcard package/gcc/*/*.mk))
