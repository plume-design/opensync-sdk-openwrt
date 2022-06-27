#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pyparsing
PKG_RELEASE:=2
PKG_VERSION:=2.4.7
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pyparsing/pyparsing.git
PKG_SOURCE_VERSION:=465c20f4b232979d07ad905596edcd8ed21b492e
PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
HOST_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-host.mk

define Package/python3-pyparsing
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Library for constructing grammar directly in python
  URL:=https://github.com/pyparsing/pyparsing/
  DEPENDS:=+python3-light
endef

define Package/python3-pyparsing/description
  The pyparsing module is an alternative approach to creating
  and executing simple grammars, vs. the traditional lex/yacc
  approach, or the use of regular expressions.
  The pyparsing module provides a library of classes that
  client code uses to construct the grammar directly in Python code.
endef

define Host/Compile
    $(call Build/Compile/HostPy3Mod,,\
        install --prefix="" --root="$(STAGING_DIR_HOSTPKG)" \
    )
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call Py3Package,python3-pyparsing))
$(eval $(call BuildPackage,python3-pyparsing))
