include $(TOPDIR)/rules.mk

PKG_NAME:=ha-vrrp
PKG_VERSION:=0.5.3
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=ChatGPT

include $(INCLUDE_DIR)/package.mk

define Package/ha-vrrp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=HA VRRP (Keepalived) with UCI renderer (multi-instance, discovery, sync, health, autosync)
  DEPENDS:=+keepalived +ip-full +uci +openssh-client +ubus +jsonfilter +busybox
endef

define Package/ha-vrrp/description
 UCI-driven Keepalived (VRRP, unicast). Multi-instance, VLAN heartbeat, peer discovery & sync,
 IPv4/IPv6 WAN-gateway health checks, multi-VIP, optional autosync daemon.
endef

define Build/Prepare
endef
define Build/Configure
endef
define Build/Compile
endef

define Package/ha-vrrp/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/ha_vrrp $(1)/etc/config/ha_vrrp

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ha-vrrp $(1)/etc/init.d/ha-vrrp
	$(INSTALL_BIN) ./files/etc/init.d/ha-vrrp-syncd $(1)/etc/init.d/ha-vrrp-syncd

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/95-ha-vrrp-apply $(1)/etc/hotplug.d/iface/95-ha-vrrp-apply

	$(INSTALL_DIR) $(1)/usr/libexec/ha-vrrp
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/ensure_vlan.sh $(1)/usr/libexec/ha-vrrp/ensure_vlan.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/notify_master.sh $(1)/usr/libexec/ha-vrrp/notify_master.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/notify_backup.sh $(1)/usr/libexec/ha-vrrp/notify_backup.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/discover_peers.sh $(1)/usr/libexec/ha-vrrp/discover_peers.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/check_wan_gw.sh $(1)/usr/libexec/ha-vrrp/check_wan_gw.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/check_wan6_gw.sh $(1)/usr/libexec/ha-vrrp/check_wan6_gw.sh

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/ha-vrrp-apply $(1)/usr/sbin/ha-vrrp-apply
	$(INSTALL_BIN) ./files/usr/sbin/ha-vrrp-sync $(1)/usr/sbin/ha-vrrp-sync
	$(INSTALL_BIN) ./files/usr/sbin/ha-vrrp-autosync $(1)/usr/sbin/ha-vrrp-autosync
endef

$(eval $(call BuildPackage,ha-vrrp))
