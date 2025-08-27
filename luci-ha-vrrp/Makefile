
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ha-vrrp
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI UI for HA VRRP (keepalived) with UCI backend
  DEPENDS:=+luci-compat +keepalived +ip-full +uci +jsonfilter +busybox
endef

define Package/$(PKG_NAME)/description
 LuCI UI for openwrt-ha-vrrp. Includes classic CBI pages, overview/status/logs views and JSON API helper.
endef

define Build/Prepare
endef
define Build/Configure
endef
define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./root/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
