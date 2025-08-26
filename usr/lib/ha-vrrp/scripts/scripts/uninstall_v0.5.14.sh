#!/bin/sh
# uninstall_v0.5.14.sh – clean uninstall
set -eu
echo "[uninstall] Stopping services (if running)"
[ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp stop || true
[ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd stop || true

PURGE=0
[ "${1:-}" = "--purge" ] && PURGE=1

echo "[uninstall] Removing files"
rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -f /etc/init.d/ha-vrrp
rm -f /etc/init.d/ha-vrrp-syncd
rm -f /usr/sbin/ha-vrrp-apply
rm -f /usr/sbin/ha-vrrp-sync
rm -f /usr/sbin/ha-vrrp-autosync
rm -rf /usr/libexec/ha-vrrp

rm -f /usr/lib/lua/luci/controller/ha_vrrp.lua
rm -rf /usr/lib/lua/luci/model/cbi/ha_vrrp
rm -rf /usr/lib/lua/luci/view/ha_vrrp

if [ "$PURGE" -eq 1 ]; then
  echo "[uninstall] Purging /etc/config/ha_vrrp"
  rm -f /etc/config/ha_vrrp
fi

echo "[uninstall] Restarting LuCI"
[ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd restart || true
[ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart || true

echo "[uninstall] Done."
