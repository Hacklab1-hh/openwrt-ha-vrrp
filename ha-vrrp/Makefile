include $(TOPDIR)/rules.mk
PKG_NAME:=ha-vrrp
PKG_VERSION:=0.3.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
include $(INCLUDE_DIR)/package.mk

define Package/ha-vrrp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=HA VRRP (Keepalived) with UCI renderer (multi-instance, sync, discovery)
  DEPENDS:=+keepalived +ip-full +uci +openssh-client
endef

define Package/ha-vrrp/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/ha_vrrp $(1)/etc/config/ha_vrrp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ha-vrrp $(1)/etc/init.d/ha-vrrp
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/95-ha-vrrp-apply $(1)/etc/hotplug.d/iface/95-ha-vrrp-apply
	$(INSTALL_DIR) $(1)/usr/libexec/ha-vrrp
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/ensure_vlan.sh $(1)/usr/libexec/ha-vrrp/ensure_vlan.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/notify_master.sh $(1)/usr/libexec/ha-vrrp/notify_master.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/notify_backup.sh $(1)/usr/libexec/ha-vrrp/notify_backup.sh
	$(INSTALL_BIN) ./files/usr/libexec/ha-vrrp/discover_peers.sh $(1)/usr/libexec/ha-vrrp/discover_peers.sh
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/ha-vrrp-apply $(1)/usr/sbin/ha-vrrp-apply
	$(INSTALL_BIN) ./files/usr/sbin/ha-vrrp-sync $(1)/usr/sbin/ha-vrrp-sync
endef
$(eval $(call BuildPackage,ha-vrrp))
