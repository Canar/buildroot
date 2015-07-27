################################################################################
#
# gcc-initial
#
################################################################################
GCC_INITIAL_VERSION = $(GCC_VERSION)
GCC_INITIAL_SITE = $(GCC_SITE)
GCC_INITIAL_SOURCE = $(GCC_SOURCE)
HOST_GCC_INITIAL_DEPENDENCIES = $(HOST_GCC_COMMON_DEPENDENCIES)
HOST_GCC_INITIAL_EXTRACT_CMDS = $(GCC_EXTRACT_CMDS)
HOST_GCC_INITIAL_POST_PATCH_HOOKS += GCC_APPLY_PATCHES
HOST_GCC_INITIAL_SUBDIR = build
HOST_GCC_INITIAL_PRE_CONFIGURE_HOOKS += GCC_CONFIGURE_SYMLINK
HOST_GCC_INITIAL_CONF_ENV = $(GCC_COMMON_CONF_ENV)
HOST_GCC_INITIAL_CONF_OPTS = \
	$(GCC_COMMON_CONF_OPTS) \
	--disable-largefile \
	--disable-nls \
	--disable-shared \
	--disable-threads \
	--enable-languages=c \
	--with-newlib \
	--without-headers \
	$(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))
# We need to tell gcc that the C library will be providing the ssp
# support, as it can't guess it since the C library hasn't been built
# yet (we're gcc-initial).
HOST_GCC_INITIAL_MAKE_OPTS = $(if $(BR2_TOOLCHAIN_HAS_SSP),gcc_cv_libc_provides_ssp=yes) all-gcc
HOST_GCC_INITIAL_INSTALL_OPTS = install-gcc
ifneq ($(call qstrip, $(BR2_XTENSA_CORE_NAME)),)
HOST_GCC_INITIAL_POST_EXTRACT_HOOKS += HOST_GCC_XTENSA_OVERLAY_EXTRACT
endif
ifeq ($(BR2_GCC_SUPPORTS_FINEGRAINEDMTUNE),y)
HOST_GCC_INITIAL_MAKE_OPTS += all-target-libgcc
HOST_GCC_INITIAL_INSTALL_OPTS += install-target-libgcc
endif
$(eval $(host-autotools-package))
