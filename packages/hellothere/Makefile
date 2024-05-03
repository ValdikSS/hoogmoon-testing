include $(TOPDIR)/rules.mk
 
PKG_NAME:=hellothere
PKG_VERSION:=0.0.2
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/hellothere
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Hellothere
  URL:=https://example.com/
  PKGARCH:=all
endef

define Package/hellothere/description
 Boot-up remote information sender
endef

define Package/hellothere/conffiles
/etc/config/hellothere
endef

define Package/hellothere/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/hellothere $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hellothere.init $(1)/etc/init.d/hellothere
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/hellothere.conf $(1)/etc/config/hellothere
	$(INSTALL_DIR) $(1)/usr/lib/hellothere
	$(INSTALL_BIN) ./files/lib_hellothere/* $(1)/usr/lib/hellothere/
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,hellothere))
