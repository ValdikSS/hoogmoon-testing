include $(TOPDIR)/rules.mk

PKG_NAME:=psiphon
PKG_SOURCE_DATE:=2024-04-30
PKG_SOURCE_VERSION:=a77d3ca70bafcf6bcf060ea7337a7dee01fccbdc
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/Psiphon-Labs/psiphon-tunnel-core.git
PKG_SOURCE_PROTO:=git
PKG_MIRROR_HASH:=SKIP

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=ValdikSS <iam@valdikss.org.ru>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/Psiphon-Labs/psiphon-tunnel-core
GO_PKG_BUILD_PKG:=$(GO_PKG)/ConsoleClient

PSIPHON_BUILDDATE:=$(shell date --iso-8601=seconds)
PSIPHON_BUILDREV:=$(shell git rev-parse --short HEAD)
PSIPHON_GOVERSION:=$(shell go version | cut -d " " -f3 | sed -E 's/[go]+//g')

GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/psiphon/common/buildinfo.buildDate=$(PSIPHON_BUILDDATE) \
	$(GO_PKG)/psiphon/common/buildinfo.buildRepo=$(PKG_SOURCE_URL) \
	$(GO_PKG)/psiphon/common/buildinfo.buildRev=$(PSIPHON_BUILDREV) \
	$(GO_PKG)/psiphon/common/buildinfo.goVersion=$(PSIPHON_GOVERSION)

GO_PKG_TAGS:=PSIPHON_ENABLE_REFRACTION_NETWORKING

include $(INCLUDE_DIR)/package.mk
# Including from /package/feeds/packages, not from /feeds
include ../../../../feeds/packages/lang/golang/golang-package.mk

define Package/psiphon
  TITLE:=Psiphon. Access the entire internet.
  SECTION:=net
  CATEGORY:=Network
  URL:=https://psiphon.ca/
endef

define Package/psiphon/description
  Psiphon is an Internet censorship circumvention system.
endef

define Package/psiphon/conffiles
/etc/config/psiphon
/etc/psiphon/
endef

define Package/psiphon/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ConsoleClient $(1)/usr/bin/psiphon

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/psiphon.init $(1)/etc/init.d/psiphon
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/psiphon.conf $(1)/etc/config/psiphon
	$(INSTALL_DIR) $(1)/etc/psiphon
	$(INSTALL_CONF) $(CURDIR)/files/psiphon.config $(1)/etc/psiphon/psiphon.config
	$(INSTALL_CONF) $(CURDIR)/files/server_list.dat $(1)/etc/psiphon/server_list.dat
endef

$(eval $(call GoBinPackage,psiphon))
$(eval $(call BuildPackage,psiphon))
