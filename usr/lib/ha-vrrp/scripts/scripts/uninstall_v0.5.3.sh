#!/bin/sh
# uninstall_v0.5.3.sh – Uninstaller for openwrt-ha-vrrp v0.5.3
set -eu

echo "[uninstall] Stopping services..."
/etc/init.d/ha-vrrp stop 2>/dev/null || true
/etc/init.d/keepalived stop 2>/dev/null || true
/etc/init.d/ha-vrrp disable 2>/dev/null || true

if command -v opkg >/dev/null 2>&1; then
  echo "[uninstall] Removing packages via opkg (if installed)..."
  opkg remove luci-app-ha-vrrp 2>/dev/null || true
  opkg remove ha-vrrp 2>/dev/null || true
fi

echo "[uninstall] Removing overlay files (safe subset)..."
rm -f /etc/config/ha_vrrp
rm -f /etc/init.d/ha-vrrp /etc/init.d/ha-vrrp-syncd
rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -rf /usr/libexec/ha-vrrp
rm -f /usr/sbin/ha-vrrp-*

# LuCI app files (if overlay-copied)
rm -f /usr/lib/lua/luci/controller/ha_vrrp.lua 2>/dev/null || true
rm -rf /usr/lib/lua/luci/model/cbi/ha_vrrp 2>/dev/null || true
rm -rf /usr/lib/lua/luci/view/ha_vrrp 2>/dev/null || true

echo "[uninstall] Done."
