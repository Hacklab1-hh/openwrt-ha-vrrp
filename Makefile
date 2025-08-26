include $(TOPDIR)/rules.mk

PKG_NAME:=ha-vrrp-bundle
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/ha-vrrp-bundle
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=HA VRRP (Keepalived) bundle with UCI + LuCI
  DEPENDS:=+keepalived +ip-full +uci +luci +uhttpd
endef

define Package/ha-vrrp-bundle/description
 HA on OpenWrt via Keepalived (VRRP, unicast), VLAN heartbeat, LuCI UI and UCI->keepalived.conf renderer.
endef

define Build/Prepare
endef
define Build/Configure
endef
define Build/Compile
endef

define Package/ha-vrrp-bundle/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ha-vrrp-bundle))
