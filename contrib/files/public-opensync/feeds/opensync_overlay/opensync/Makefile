include $(TOPDIR)/rules.mk

PKG_NAME:=opensync
PKG_VERSION:=2.0.5.0

PKG_BUILD_DEPENDS:=python3-kconfiglib/host python3-jinja2/host python3-markupsafe/host
HOST_BUILD_DEPENDS:=protobuf-c/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Host/Configure
endef

define Host/Compile
endef

define Host/Install
endef

define Host/Clean
endef

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
	cp $(BUILD_DIR)/hostapd-wpad-full-openssl/hostapd-2020-06-08-5a8b3662/src/utils/os_unix.o $(STAGING_DIR)/usr/lib/
	cp $(BUILD_DIR)/hostapd-wpad-full-openssl/hostapd-2020-06-08-5a8b3662/src/common/wpa_ctrl.o $(STAGING_DIR)/usr/lib/
	cp $(BUILD_DIR)/hostapd-wpad-full-openssl/hostapd-2020-06-08-5a8b3662/src/common/wpa_ctrl.h $(STAGING_DIR)/usr/include/
endef

OPENSYNC_ROOTFS:=work/$(OPENSYNC_TARGET)/rootfs/

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections

TARGET_LDFLAGS += -Wl,--gc-sections

MAKE_FLAGS := \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET="$(OPENSYNC_TARGET)" \
	IMAGE_DEPLOYMENT_PROFILE="$(IMAGE_DEPLOYMENT_PROFILE)" \
	TOOLCHAIN_DIR="$(TOOLCHAIN_DIR)" \
	TOOLCHAIN_PREFIX="$(TARGET_CROSS)" \
	NO_RDYNAMIC=1

define Build/Compile
	if [ ! -d $(OPENSYNC_SRC_ABS)/core ]; then \
		echo Error: Invalid opensync soruces path OPENSYNC_SRC_ABS=$(OPENSYNC_SRC_ABS); \
		exit 1; \
	fi
	cp -r $(OPENSYNC_SRC_ABS)/core/* $(PKG_BUILD_DIR)/
	rm $(PKG_BUILD_DIR)/{vendor,platform,service-provider}
	cp -r $(OPENSYNC_SRC_ABS)/platform $(PKG_BUILD_DIR)/
	cp -r $(OPENSYNC_SRC_ABS)/vendor $(PKG_BUILD_DIR)/
	cp -r $(OPENSYNC_SRC_ABS)/service-provider $(PKG_BUILD_DIR)/
	$(Build/Patch)
	$(STAGING_DIR_HOSTPKG)/bin/protoc-c \
			--c_out=$(PKG_BUILD_DIR)/src/lib/datapipeline/inc \
			--proto_path=$(PKG_BUILD_DIR)/interfaces \
			$(PKG_BUILD_DIR)/interfaces/opensync_stats.proto
	$(CP) $(PKG_BUILD_DIR)/src/lib/datapipeline/inc/opensync_stats.pb-c.c $(PKG_BUILD_DIR)/src/lib/datapipeline/src
	$(RM) $(PKG_BUILD_DIR)/src/lib/datapipeline/inc/opensync_stats.pb-c.c

	$(MAKE) -C $(PKG_BUILD_DIR) V=1 \
		OWRT_CFLAGS="$(TARGET_CFLAGS)" \
		$(MAKE_FLAGS)
	$(MAKE) -C $(PKG_BUILD_DIR) rootfs \
		$(MAKE_FLAGS)
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
	$(MAKE) -C $(PKG_BUILD_DIR) TARGET=$(OPENSYNC_TARGET) rootfs-copy-only INSTALL_ROOTFS_DIR=$(1)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,opensync))
