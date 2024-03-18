include $(TOPDIR)/rules.mk
 
PKG_NAME:=tor-relay-scanner
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=tor-relay-scanner-$(PKG_VERSION).pyz
PKG_SOURCE_URL:=https://github.com/ValdikSS/tor-relay-scanner/releases/download/$(PKG_VERSION)
PKG_HASH:=29d15ed4328004a0f10de3e631256755ef05557fbe8aa79042f479e70a00ca2a

include $(INCLUDE_DIR)/package.mk

define Package/tor-relay-scanner
  SECTION:=net
  CATEGORY:=Network
  EXTRA_DEPENDS:=python3
  TITLE:=Tor Relay Scanner
  URL:=https://github.com/ValdikSS/tor-relay-scanner/
  PKGARCH:=all
endef

define Package/tor-relay-scanner/description
 Tor Relay availability checker, for using it as a bridge in countries with censorship
endef

define Package/tor-relay-scanner/conffiles
/etc/config/tor_relay_scanner
endef

define Package/tor-relay-scanner/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tor-relay-scanner-$(PKG_VERSION).pyz $(1)/usr/bin/tor-relay-scanner.pyz
	$(INSTALL_BIN) ./files/tor-relay-scanner $(1)/usr/bin/tor-relay-scanner
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tor_relay_scanner.init $(1)/etc/init.d/tor_relay_scanner
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tor_relay_scanner.conf $(1)/etc/config/tor_relay_scanner
endef

define Build/Prepare
	$(CP) $(DL_DIR)/tor-relay-scanner-$(PKG_VERSION).pyz $(PKG_BUILD_DIR)/tor-relay-scanner-$(PKG_VERSION).pyz
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,tor-relay-scanner))
