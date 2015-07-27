################################################################################
#
# gcc-final
#
################################################################################
GCC_FINAL_VERSION = $(GCC_VERSION)
GCC_FINAL_SITE = $(GCC_SITE)
GCC_FINAL_SOURCE = $(GCC_SOURCE)
HOST_GCC_FINAL_POST_PATCH_HOOKS += GCC_APPLY_PATCHES
HOST_GCC_FINAL_EXTRACT_CMDS = $(GCC_EXTRACT_CMDS)
HOST_GCC_FINAL_DEPENDENCIES = $(HOST_GCC_COMMON_DEPENDENCIES) $(BR_LIBC)
# out-of-tree-build
HOST_GCC_FINAL_SUBDIR = build
HOST_GCC_FINAL_PRE_CONFIGURE_HOOKS += GCC_CONFIGURE_SYMLINK
HOST_GCC_FINAL_GCC_LIB_DIR = $(HOST_DIR)/usr/$(GNU_TARGET_NAME)/lib*
HOST_GCC_FINAL_CONF_OPTS = \
	$(HOST_GCC_COMMON_CONF_OPTS) $(GCC_GOOD_CONF_OPTS) \
	--with-build-time-tools=$(HOST_DIR)/usr/$(GNU_TARGET_NAME)/bin
# End with user-provided options to permit user overrides.
HOST_GCC_FINAL_CONF_OPTS += $(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))
HOST_GCC_FINAL_CONF_ENV = $(HOST_GCC_COMMON_CONF_ENV)
HOST_GCC_FINAL_USR_LIBS = $(GCC_GOOD_USR_LIBS)

$(eval $(host-autotools-package))
