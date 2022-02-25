JOBS ?= 8
CONFIG ?= undefined
PATCHED ?= y
CONFIGS = $(shell ls config | grep -F -- .config | cut -d. -f1)

CACHE_DIR = .cache.$(CONFIG)
CACHE_OLD = $(CACHE_DIR)/.cache_old
CACHE_NOW = .cache_current
SDK_REPO=https://github.com/openwrt/openwrt.git
BUILD_NUMBER ?= 0
IMAGE_DEPLOYMENT_PROFILE ?= local
BUILD = build-$(CONFIG)
PATCHDIR = $(BUILD)/openwrt/patches

# SERIES_DIRS is a list of directories that define the order and selection
# of components that are applied using stow for files/ and quilt for patches/
# This allows product specific list of files/patches that need to be applied.
#
# define default SERIES_DIR, which can be redefined in config/$(CONFIG).mk
# files for each platform
define SERIES_DIRS
public-opensync
endef

include config/$(CONFIG).mk

CONF_PROFILE=conf-$(PROFILE)
FEEDS_PROFILE=feeds-$(PROFILE)

include Makefile.$(OPENWRT_REFBOARD).mk

export OPENSYNC_SRC_ABS=$(realpath $(OPENSYNC_SRC))
export OPENSYNC_TARGET
export IMAGE_DEPLOYMENT_PROFILE
$(info "JOBS=$(JOBS)")
$(info "CONFIG=$(CONFIG)")
$(info "PROFILE=$(PROFILE)")
$(info "OPENSYNC_SRC=$(OPENSYNC_SRC_ABS)")
$(info "OPENSYNC_TARGET=$(OPENSYNC_TARGET)")
$(info "IMAGE_DEPLOYMENT_PROFILE=$(IMAGE_DEPLOYMENT_PROFILE)")
$(info "BUILD_NUMBER=$(BUILD_NUMBER)")

help: ## this help message
	@echo
	@echo 'Provide CONFIG=<config> and OPENSYNC_SRC=<path_to_opensync_root> (path to OpenSync root directory)'
	@echo
	@echo 'Available configurations (<config>) are:'
	@echo $(CONFIGS) | tr ' ' '\n' | sort | xargs -n1 printf "    %s\\n"
	@echo
	@echo 'Optional parameter: IMAGE_DEPLOYMENT_PROFILE=<service_provider_profile> (default is "local")'
	@echo
	@echo 'Available make targets are:'
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {printf "    %-23s %s\n", $$1, $$NF}' $(MAKEFILE_LIST)
	@echo
	@echo "Examples:"
	@echo "    docker/dock-run make CONFIG=mr8300 OPENSYNC_SRC=<path_to_opensync_root> build"
	@echo "    docker/dock-run make CONFIG=mr8300 OPENSYNC_SRC=<path_to_opensync_root> IMAGE_DEPLOYMENT_PROFILE=opensync-dev build"
	@echo "    docker/dock-run make CONFIG=mr8300 OPENSYNC_SRC=<path_to_opensync_root> compile/opensync"
	@echo "    docker/dock-run make CONFIG=mr8300 prepare"
	@echo "    docker/dock-run make CONFIG=mr8300 OPENSYNC_SRC=<path_to_opensync_root> compile"
	@echo "    docker/dock-run make cleanold"
	@echo

build: ## prepare and build a 'CONFIG=<config> OPENSYNC_SRC=~/path/to/opensync [IMAGE_DEPLOYMENT_PROFILE=<profile>]' in build-<config> directory
	make prepare
	make compile
	make image BUILD_NUMBER=$(BUILD_NUMBER)

prepare: ## prepare a 'CONFIG=<config>' (sdk, config, and feeds)
	find ./contrib -type f | xargs md5sum > $(CACHE_NOW) && md5sum config/$(CONFIG).mk >> $(CACHE_NOW)
	cmp -s $(CACHE_NOW) $(CACHE_OLD) || make cache
	! test -e $(BUILD) || make $(BUILD)

$(BUILD): $(shell find config contrib) Makefile.$(OPENWRT_REFBOARD).mk Makefile
	rm -rf .$(BUILD)
	cp -a $(CACHE_DIR) .$(BUILD)
	make $(CONF_PROFILE) CONFIG=$(CONFIG)
	make backup
	mv .$(BUILD) $(BUILD)

backup: ## back up a 'CONFIG=<config>' (add .old.<date> suffix to the directory name)
	! test -e $(BUILD) || mv -f $(BUILD) $(BUILD).old.$(shell date +%Y-%m-%d-%H-%M-%S)

cache: ## (internal)
	[ -d $(CACHE_DIR) ] && rm -rf $(CACHE_DIR); \
	git clone --single-branch --branch $(SDK_BRANCH) $(SDK_REPO) $(CACHE_DIR)/openwrt; \
	git --git-dir=$(CACHE_DIR)/openwrt/.git --work-tree=$(CACHE_DIR)/openwrt checkout $(SDK_REVISION);\
	test "$(PATCHED)" = n || make patch
	make feeds
	find ./contrib -type f | xargs md5sum > $(CACHE_OLD) && md5sum config/$(CONFIG).mk >> $(CACHE_OLD)
	make $(BUILD)

feeds: ## (internal)
	./$(CACHE_DIR)/openwrt/scripts/feeds update -a
	./$(CACHE_DIR)/openwrt/scripts/feeds install -a
	make $(FEEDS_PROFILE)

# Helper function for finding the matching series dirs
define _FIND_SERIES_DIRS
$(notdir $(wildcard $(addprefix $1,$(strip $(SERIES_DIRS)))))
endef

patch: ## (internal; apply contrib/ to build dir)
	# Stow can't overwrite files. We need to do that with some files.
	# So all contrib/files/ that will be stowed are first removed from target.
	# Copying files over has the downside of making it harder to
	# update contrib/files/ back. Stow makes symlinks so modifying files
	# in $(BUILD)/ will change contrib/files/ immediatelly.
	STOW_PKGS="$(call _FIND_SERIES_DIRS,contrib/files/)"; \
		echo stowing: $$STOW_PKGS; \
		for D in $$STOW_PKGS; do find contrib/files/$$D -not -type d -printf "$(CACHE_DIR)/openwrt/%P\n" | xargs rm -vf; done; \
		[ -z "$$STOW_PKGS" ] || stow -t $(CACHE_DIR)/openwrt -d contrib/files --no-folding -R $$STOW_PKGS

	# Patches are copied so if there are some changes in $(CACHE_DIR)/
	# it is safe to checkout a different commit in git and CACHE_DIR it.
	cp -va contrib/patches $(CACHE_DIR)/openwrt
	# generate a single series file for quilt from all series files in the tree
	> $(CACHE_DIR)/openwrt/patches/series
	for D in $(call _FIND_SERIES_DIRS,contrib/patches/); do \
		for DIR in $$D; do \
		SERIES_FILE=contrib/patches/$$DIR/series; \
		if [ -e "$$SERIES_FILE" ]; then \
			echo include series: $$SERIES_FILE; \
			sed "s:^\(#*\):\1$$DIR/:" $$SERIES_FILE >> $(CACHE_DIR)/openwrt/patches/series; \
		fi; \
	done; done
	cd $(CACHE_DIR)/openwrt && ( ! quilt series | grep . || quilt push -a )

update: ## copy quilt patches from build-<config> build dir to contrib/patches/
	@if [ ! -e "$(PATCHDIR)" ]; then \
		echo "ERROR: $(PATCHDIR) directory does not exist!"; \
		exit 1; \
	fi
	rm -rf contrib/patches/*
	cp -va $(PATCHDIR)/* contrib/patches/
	rm -f contrib/patches/series
	for D in $(call _FIND_SERIES_DIRS,contrib/patches/); do \
		for DIR in $$D; do \
		SERIES_FILE=contrib/patches/$$DIR/series; \
		if [ -e "$$SERIES_FILE" ]; then \
			echo update series: $$SERIES_FILE; \
			sed -n "\:^#*$$DIR/[^/]*.patch:s:^\(#*\)$$DIR/\(.*\)$$:\1\2:p" $(PATCHDIR)/series > $$SERIES_FILE; \
		fi; \
	done; done

compile: ## compile a 'CONFIG=<config> OPENSYNC_SRC=<path_to_opensync_root> [IMAGE_DEPLOYMENT_PROFILE=<profile>]' in build-<config>/openwrt directory
	make -C $(BUILD)/openwrt -j $(JOBS)

compile/opensync: ## clean and compile OpenSync with 'CONFIG=<config> OPENSYNC_SRC=<path_to_opensync_root> [IMAGE_DEPLOYMENT_PROFILE=<profile>]' in build-<config>/openwrt directory
	make -C $(BUILD)/openwrt -j1 package/opensync/clean
	make -C $(BUILD)/openwrt -j1 package/opensync/compile

clean: ## remove build-<config> build dir
	rm -rf $(BUILD) .$(BUILD)

cleanold: ## remove all old (automatically renamed) build dirs
	rm -rf build*.old.*

cleancache: ## remove cached local clones of OpenWrt and default feeds repositories
	rm -rf $(CACHE_DIR)
	rm .cache_current

cleanall: ## remove all build dirs, caches and .cache_current
	rm -rf build*/ .build*/ build* .build* .cache*

.PHONY: cache/clean sdk-assemble feeds-default-use-cache feeds patch
.PHONY: update backup prepare compile compile/opensync compile/wrap build
.PHONY: clean cleanold cache cleancache cleanall
