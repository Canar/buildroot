################################################################################
#
# readline
#
################################################################################

READLINE_VERSION = 6.3
READLINE_SITE = $(BR2_GNU_MIRROR)/readline
READLINE_INSTALL_STAGING = YES
READLINE_DEPENDENCIES = ncurses
HOST_READLINE_DEPENDENCIES = host-ncurses
READLINE_CONF_ENV = bash_cv_func_sigsetjmp=yes \
	bash_cv_wcwidth_broken=no
READLINE_LICENSE = GPLv3+
READLINE_LICENSE_FILES = COPYING
#READLINE_CONF_OPTS = \
#	--enable-multibyte \
#	--with-curses

ifneq ($(BR2_PACKAGE_NCURSES_WCHAR),y)
define READLINE_WIDE_CURSES
cp $(@D)/configure $(@D)/configure.old
sed 's/curses/cursesw/g' $(@D)/configure.old >$(@D)/configure
#cp $(@D)/shlib/Makefile $(@D)/shlib/Makefile.old
#sed 's/curses/cursesw/g' $(@D)/shlib/Makefile.old >$(@D)/shlib/Makefile
cp $(@D)/support/shobj-conf $(@D)/support/shobj-conf.old
sed 's/-lcurses/-lcursesw/g' $(@D)/support/shobj-conf.old >$(@D)/support/shobj-conf
endef
READLINE_POST_EXTRACT_HOOKS += READLINE_WIDE_CURSES
endif

define READLINE_PURGE_EXAMPLES
	rm -rf $(TARGET_DIR)/usr/share/readline
endef

READLINE_POST_INSTALL_TARGET_HOOKS += READLINE_PURGE_EXAMPLES

$(eval $(autotools-package))
$(eval $(host-autotools-package))
