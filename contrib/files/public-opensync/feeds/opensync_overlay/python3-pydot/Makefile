include $(TOPDIR)/rules.mk

PKG_NAME:=pydot
PKG_VERSION:=1.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/13/6e/916cdf94f9b38ae0777b254c75c3bdddee49a54cc4014aac1460a7a172b3
PKG_HASH:=248081a39bcb56784deb018977e428605c1c758f10897a339fce1dd728ff007d

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-host.mk

define Package/python3-pydot
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python3-pydot
	URL:=https://files.pythonhosted.org/packages/13/6e/916cdf94f9b38ae0777b254c75c3bdddee49a54cc4014aac1460a7a172b3/
endef

define Host/Compile
	$(call Build/Compile/HostPy3Mod,,\
		install --prefix="" --root="$(STAGING_DIR_HOSTPKG)" \
	)
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call Py3Package,python3-pydot))
$(eval $(call BuildPackage,python3-pydot))
