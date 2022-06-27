#
# Makefile for building Linksys EA8300 (IPQ40XX) firmware
#
# Supported OpenWrt versions:
#   - 19.07.6
#
# WARNING:
# This Makefile must be included from main Makefile and can not be run directly!
#

feeds-generic:
	$(CACHE_DIR)/openwrt/scripts/feeds uninstall openvswitch
	$(CACHE_DIR)/openwrt/scripts/feeds install -a -f -p opensync_feed

OPENSYNC_BUILD_DIR=$(BUILD)/openwrt/build_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/opensync-*
VERSIONS_FILE=core/work/LINKSYS_MR8300/rootfs/usr/opensync/.versions
OPENWRT_IMG_DIR=$(BUILD)/openwrt/bin/targets/ipq40xx/generic
OPENWRT_PKG_DIR=$(BUILD)/openwrt/staging_dir/packages/ipq40xx
VERSION=$(patsubst FIRMWARE:%,%,$(shell cat $(OPENSYNC_BUILD_DIR)/$(VERSIONS_FILE) | grep FIRMWARE))

image:
	mkdir -p $(BUILD)/images
	cp $(OPENWRT_IMG_DIR)/*sysupgrade.bin $(BUILD)/images/$(CONFIG)-sysupgrade-$(VERSION).bin
	cp $(OPENWRT_IMG_DIR)/*factory.bin $(BUILD)/images/$(CONFIG)-factory-$(VERSION).bin
	cp $(OPENWRT_PKG_DIR)/opensync_*.ipk $(BUILD)/images/$(CONFIG)-opensync-$(VERSION).ipk

.PHONY: feeds-generic image
