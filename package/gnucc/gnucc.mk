################################################################################
#
# gnucc
#
################################################################################
GNUCC_VERSION = $(call qstrip,$(BR2_GCC_VERSION))
GNUCC_SITE = $(BR2_GNU_MIRROR:/=)/gcc/gcc-$(GNUCC_VERSION)
GNUCC_SOURCE ?= gcc-$(GNUCC_VERSION).tar.bz2
define GNUCC_APPLY_PATCHES_NO
	if test -d package/gcc/$(GNUCC_VERSION); then \
	  $(APPLY_PATCHES) $(@D) package/gcc/$(GNUCC_VERSION) \*.patch ; \
	fi;
	$(GNUCC_APPLY_POWERPC_PATCH)
endef
#GNUCC_POST_PATCH_HOOKS += GNUCC_APPLY_PATCHES
define GNUCC_EXTRACT_CMDS
	$(call suitable-extractor,$(GNUCC_SOURCE)) $(DL_DIR)/$(GNUCC_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D) \
		--exclude='libjava/*' \
		--exclude='libgo/*' \
		--exclude='gcc/testsuite/*' \
		--exclude='libstdc++-v3/testsuite/*' \
		$(TAR_OPTIONS) -
	mkdir -p $(@D)/libstdc++-v3/testsuite/
	echo "all:" > $(@D)/libstdc++-v3/testsuite/Makefile.in
	echo "install:" >> $(@D)/libstdc++-v3/testsuite/Makefile.in
endef

# gcc doesn't support in-tree build, so we create a 'build'
# subdirectory in the gcc sources, and build from there.
GNUCC_SUBDIR = build
define GNUCC_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef
GNUCC_PRE_CONFIGURE_HOOKS += GNUCC_CONFIGURE_SYMLINK

GNUCC_DEPENDENCIES = binutils gmp mpfr $(BR_LIBC)
ifneq ($(BR2_BINFMT_FLAT),)
	GNUCC_DEPENDENCIES += elf2flt
endif

GNUCC_TCFLAGS = $(TARGET_CFLAGS)
GNUCC_CONF_ENV = MAKEINFO=missing
GNUCC_CONF_ENV += CFLAGS_FOR_TARGET="$(GNUCC_TCFLAGS)"
GNUCC_CONF_ENV += CXXFLAGS_FOR_TARGET="$(GNUCC_TCXXFLAGS)"

ifneq ($(call qstrip, $(BR2_XTENSA_CORE_NAME)),)
GNUCC_POST_EXTRACT_HOOKS += GNUCC_XTENSA_OVERLAY_EXTRACT
endif

# languages supported
GNUCC_CROSS_LANGUAGES = c
ifneq ($(BR2_INSTALL_LIBSTDCPP),)
GNUCC_CROSS_LANGUAGES += c++
endif
ifneq ($(BR2_TOOLCHAIN_BUILDROOT_FORTRAN),)
GNUCC_CROSS_LANGUAGES += fortran
endif

GNUCC_CONF_OPTS = \
	--target=$(GNU_TARGET_NAME) \
	--disable-__cxa_atexit \
	--with-gnu-ld \
	--disable-libssp \
	--disable-multilib \
	--with-gmp=$(TARGET_DIR)/usr \
	--with-mpfr=$(TARGET_DIR)/usr \

# libsanitizer requires wordexp, not in default uClibc config. Also
# doesn't build properly with musl.
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_UCLIBC)$(BR2_TOOLCHAIN_BUILDROOT_MUSL),y)
GNUCC_CONF_OPTS += --disable-libsanitizer
endif

# libsanitizer is broken for SPARC
# https://bugs.busybox.net/show_bug.cgi?id=7951
ifeq ($(BR2_sparc),y)
GNUCC_CONF_OPTS += --disable-libsanitizer
endif

ifeq ($(BR2_GCC_ENABLE_TLS),y)
GNUCC_CONF_OPTS += --enable-tls
else
GNUCC_CONF_OPTS += --disable-tls
endif

ifeq ($(BR2_GCC_ENABLE_LTO),y)
GNUCC_CONF_OPTS += --enable-plugins --enable-lto
endif

ifeq ($(BR2_GCC_ENABLE_LIBMUDFLAP),y)
GNUCC_CONF_OPTS += --enable-libmudflap
else
GNUCC_CONF_OPTS += --disable-libmudflap
endif

ifeq ($(BR2_PTHREADS_NONE),y)
GNUCC_CONF_OPTS += \
	--disable-threads \
	--disable-libitm \
	--disable-libatomic
else
GNUCC_CONF_OPTS += --enable-threads
endif

ifeq ($(BR2_GCC_NEEDS_MPC),y)
GNUCC_DEPENDENCIES += mpc
GNUCC_CONF_OPTS += --with-mpc=$(TARGET_DIR)/usr
endif

ifeq ($(BR2_GCC_ENABLE_GRAPHITE),y)
GNUCC_DEPENDENCIES += isl cloog
GNUCC_CONF_OPTS += --with-isl=/usr --with-cloog=/usr
else
GNUCC_CONF_OPTS += --without-isl --without-cloog
endif

ifeq ($(BR2_SOFT_FLOAT),y)
# only mips*-*-*, arm*-*-* and sparc*-*-* accept --with-float
# powerpc seems to be needing it as well
ifeq ($(BR2_arm)$(BR2_armeb)$(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el)$(BR2_powerpc)$(BR2_sparc),y)
GNUCC_CONF_OPTS += --with-float=soft
endif
endif

ifeq ($(BR2_GCC_SUPPORTS_FINEGRAINEDMTUNE),y)
GNUCC_CONF_OPTS += --disable-decimal-float
endif

# Determine arch/tune/abi/cpu options
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ARCH)),)
GNUCC_CONF_OPTS += --with-arch=$(BR2_GCC_TARGET_ARCH)
endif
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ABI)),)
GNUCC_CONF_OPTS += --with-abi=$(BR2_GCC_TARGET_ABI)
endif
ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU)),)
ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU_REVISION)),)
GNUCC_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU)-$(BR2_GCC_TARGET_CPU_REVISION))
else
GNUCC_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU))
endif
endif

GNUCC_TARGET_FPU = $(call qstrip,$(BR2_GCC_TARGET_FPU))
ifneq ($(GNUCC_TARGET_FPU),)
GNUCC_CONF_OPTS += --with-fpu=$(GNUCC_TARGET_FPU)
endif

GNUCC_TARGET_FLOAT_ABI = $(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
ifneq ($(GNUCC_TARGET_FLOAT_ABI),)
GNUCC_CONF_OPTS += --with-float=$(GNUCC_TARGET_FLOAT_ABI)
endif

GNUCC_TARGET_MODE = $(call qstrip,$(BR2_GCC_TARGET_MODE))
ifneq ($(GNUCC_TARGET_MODE),)
GNUCC_CONF_OPTS += --with-mode=$(GNUCC_TARGET_MODE)
endif

# Enable proper double/long double for SPE ABI
ifeq ($(BR2_powerpc_SPE),y)
GNUCC_CONF_OPTS += \
	--enable-e500_double \
	--with-long-double-128
endif


GNUCC_CONF_OPTS += \
	--enable-languages=$(GNUCC_CROSS_LANGUAGES) \
	--enable-poison-system-directories

# Disable shared libs like libstdc++ if we do static since it confuses linking
ifeq ($(BR2_STATIC_LIBS),y)
GNUCC_CONF_OPTS += --disable-shared
else
GNUCC_CONF_OPTS += --enable-shared
endif

ifeq ($(BR2_GCC_ENABLE_OPENMP),y)
GNUCC_CONF_OPTS += --enable-libgomp
else
GNUCC_CONF_OPTS += --disable-libgomp
endif

# End with user-provided options, so that they can override previously
# defined options.
GNUCC_CONF_OPTS += \
	$(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))

#End of CONF_OPTS

$(eval $(autotools-package))
