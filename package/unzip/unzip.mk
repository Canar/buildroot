################################################################################
#
# infozip
#
################################################################################

UNZIP_VERSION = 6.0
UNZIP_SOURCE = unzip$(subst .,,$(UNZIP_VERSION)).tgz
UNZIP_SITE = ftp://ftp.info-zip.org/pub/infozip/src
UNZIP_LICENSE = Info-ZIP
UNZIP_LICENSE_FILES = LICENSE

ifeq ($(BR2_PACKAGE_BZIP2),y)
UNZIP_DEPENDENCIES += bzip2
endif

UNZIP_CFLAGS = -I. -DUNIX
UNZIP_CFLAGS += -DUIDGID_NOT_16BIT

# infozip already defines _LARGEFILE_SOURCE and _LARGEFILE64_SOURCE when
# necessary, redefining it on the command line causes some warnings.
UNZIP_TARGET_CFLAGS = \
	$(filter-out -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE,$(TARGET_CFLAGS))

define UNZIP_CONFIGURE_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		-f unix/Makefile flags
endef

define UNZIP_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		CFLAGS="$(UNZIP_TARGET_CFLAGS) $(UNZIP_CFLAGS)" \
		$(shell cat $(@D)/flags) \
		-f unix/Makefile gcc
endef

define UNZIP_INSTALL_TARGET_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) -f unix/Makefile install \
		prefix=$(TARGET_DIR)/usr
endef

$(eval $(generic-package))
