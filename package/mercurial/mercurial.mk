################################################################################
#
# mercurial
#
################################################################################
MERCURIAL_VERSION = 3.4
MERCURIAL_SOURCE = mercurial-$(MERCURIAL_VERSION).tar.gz
MERCURIAL_SITE = http://mercurial.selenic.com/release
MERCURIAL_LICENSE = GPLv2
MERCURIAL_LICENSE_FILES = COPYING
MERCURIAL_DEPENDENCIES = host-python 
MERCURIAL_SETUP_TYPE = distutils
define MERCURIAL_BUILD_CMDS
	cd $(@D) &&\
	$(HOST_DIR)/usr/bin/python ./setup.py build 
endef
define MERCURIAL_INSTALL_TARGET_CMDS
	cd $(@D) &&\
	$(HOST_DIR)/usr/bin/python ./setup.py install --root="$(TARGET_DIR)" --prefix="/usr" --force
endef
#$(eval $(python-package))
$(eval $(generic-package))
