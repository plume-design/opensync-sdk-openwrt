include $(TOPDIR)/rules.mk

PKG_NAME:=opensync
PKG_VERSION:=3.2.7.0

PKG_BUILD_DEPENDS:=python3-kconfiglib/host python3-jinja2/host python3-markupsafe/host python3-pydot/host python3-pyparsing/host

include $(INCLUDE_DIR)/package.mk

define Package/opensync
	CATEGORY := Network
	TITLE    := cloud network management system
	DEPENDS  := +libev +jansson +protobuf +libprotobuf-c +libmosquitto +libopenssl +openvswitch +libpcap +libuci +libcurl +libubus +libblobmsg-json +tcpdump +curl +lldpd +hostapd
	DEPENDS  += +libnl +@BUSYBOX_CUSTOM +@BUSYBOX_CONFIG_TIMEOUT +@PACKAGE_wpa-cli +@PACKAGE_hostapd-utils +@BUSYBOX_CONFIG_UDHCPD +@PACKAGE_ip-full +@BUSYBOX_CONFIG_LOGGER +@BUSYBOX_CONFIG_VCONFIG
	DEPENDS  += +libmnl +mxml
endef

define Package/opensync/description
	OpenSync is a cloud-agnostic software for the delivery, curation, and management of services for the modern home.
	For more info please visit: https://opensync.io
endef

define Build/Prepare
endef

export OVS_INTERNAL_PATH=$(wildcard $(BUILD_DIR)/linux-$(BOARD)_$(SUBTARGET)/openvswitch*)
OPENSYNC_ROOTFS:=core/work/$(OPENSYNC_TARGET)/rootfs/

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections

TARGET_LDFLAGS += -Wl,--gc-sections

MAKE_FLAGS := \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET=$(OPENSYNC_TARGET) \
	IMAGE_DEPLOYMENT_PROFILE=$(IMAGE_DEPLOYMENT_PROFILE) \
	TOOLCHAIN_DIR=$(TOOLCHAIN_DIR) \
	TOOLCHAIN_PREFIX=$(TARGET_CROSS) \
	NO_RDYNAMIC=1

define Build/Compile
	if [ ! -d $(OPENSYNC_SRC_ABS)/core ]; then \
		echo Error: Invalid opensync soruces path OPENSYNC_SRC_ABS=$(OPENSYNC_SRC_ABS); \
		exit 1; \
	fi
	$(CP) $(OPENSYNC_SRC_ABS)/* $(PKG_BUILD_DIR)/
	$(Build/Patch)
	$(MAKE) -C $(PKG_BUILD_DIR)/core OWRT_CFLAGS="$(TARGET_CFLAGS)" $(MAKE_FLAGS)
	$(MAKE) -C $(PKG_BUILD_DIR)/core rootfs $(MAKE_FLAGS)
endef

define Package/opensync/install
	$(CP) ./files/* $(1)
	$(INSTALL_DIR) $(1)/usr/opensync/{bin,etc,certs}
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(OPENSYNC_ROOTFS)/usr/opensync/bin/* $(1)/usr/opensync/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(OPENSYNC_ROOTFS)/usr/opensync/etc/* $(1)/usr/opensync/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(OPENSYNC_ROOTFS)/usr/opensync/tools/ovsh $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(OPENSYNC_ROOTFS)/usr/opensync/lib/* $(1)/usr/lib
	$(MAKE) -C $(PKG_BUILD_DIR)/core TARGET=$(OPENSYNC_TARGET) rootfs-copy-only INSTALL_ROOTFS_DIR=$(1)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,opensync))
