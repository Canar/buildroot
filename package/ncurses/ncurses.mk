################################################################################
#
# ncurses
#
################################################################################

NCURSES_VERSION = 5.9
NCURSES_SITE = $(BR2_GNU_MIRROR)/ncurses
NCURSES_INSTALL_STAGING = YES
NCURSES_DEPENDENCIES = host-ncurses
HOST_NCURSES_DEPENDENCIES =
NCURSES_PROGS = clear infocmp tabs tic toe tput tset
NCURSES_MAKE = $(MAKE1)
NCURSES_LICENSE = MIT with advertising clause
NCURSES_LICENSE_FILES = README
NCURSES_CONFIG_SCRIPTS = ncurses$(NCURSES_LIB_SUFFIX)$(NCURSES_ABI_VERSION)-config

NCURSES_CONF_OPTS = \
	$(if $(BR2_PACKAGE_NCURSES_TARGET_PROGS),,--without-progs) \
	--enable-echo \
	--enable-const \
	--enable-overwrite \
	--enable-pc-files \
	--enable-ext-colors \
	--disable-rpath \
	--disable-rpath-hack \
	--without-ada

ifeq ($(BR2_PACKAGE_NCURSES_WCHAR),y)
NCURSES_CONF_OPTS += \
	--enable-widec \
	--enable-ext-colors
endif

#         BR2_FERTILIZE=y
ifneq ($(BR2_FERTILIZE),y)
NCURSES_CONF_OPTS += \
	--without-tests \
	--disable-big-core \
	--without-profile \
	--without-manpages \
	--without-cxx \
	--without-cxx-binding
endif

# Install after busybox for the full-blown versions
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
NCURSES_DEPENDENCIES += busybox
endif

ifeq ($(BR2_STATIC_LIBS),y)
NCURSES_CONF_OPTS += --without-shared --with-normal
else ifeq ($(BR2_SHARED_LIBS),y)
NCURSES_CONF_OPTS += --with-shared --without-normal
else ifeq ($(BR2_SHARED_STATIC_LIBS),y)
NCURSES_CONF_OPTS += --with-shared --with-normal
endif

# configure can't find the soname for libgpm when cross compiling
ifeq ($(BR2_PACKAGE_GPM),y)
NCURSES_CONF_OPTS += --with-gpm=libgpm.so.2
NCURSES_DEPENDENCIES += gpm
else
NCURSES_CONF_OPTS += --without-gpm
endif

NCURSES_LIBS-y = ncurses
NCURSES_LIBS-$(BR2_PACKAGE_NCURSES_TARGET_MENU) += menu
NCURSES_LIBS-$(BR2_PACKAGE_NCURSES_TARGET_PANEL) += panel
NCURSES_LIBS-$(BR2_PACKAGE_NCURSES_TARGET_FORM) += form

ifneq ($(BR2_ENABLE_DEBUG),y)
NCURSES_CONF_OPTS += --without-debug
endif

HOST_NCURSES_CONF_OPTS = \
	--with-shared \
	--without-gpm \
	--without-manpages \
	--without-cxx \
	--without-cxx-binding \
	--without-ada \
	--without-normal

$(eval $(autotools-package))
$(eval $(host-autotools-package))
