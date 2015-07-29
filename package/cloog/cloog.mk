################################################################################
#
# cloog
#
################################################################################

CLOOG_VERSION = 0.18.3
CLOOG_SITE = http://www.bastoul.net/cloog/pages/download
CLOOG_LICENSE = LGPLv2.1+
CLOOG_DEPENDENCIES = gmp isl
# Our libtool patch doesn't apply, and since this package is only
# built for the host, we don't really care about it.
CLOOG_LIBTOOL_PATCH = NO

CLOOG_CONF_OPTS = --with-isl=/usr --with-polylib=no
HOST_CLOOG_CONF_OPTS = --with-isl=system --with-polylib=no

$(eval $(autotools-package))
$(eval $(host-autotools-package))
