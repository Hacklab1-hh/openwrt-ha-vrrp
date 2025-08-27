#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# uninstall_v0.5.13.sh - clean uninstall for openwrt-ha-vrrp v0.5.13
set -eu

echo "[uninstall] Stopping services (if running)"
[ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp stop || true
[ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd stop || true

echo "[uninstall] Removing files"
# Core conffile kept unless --purge passed
PURGE=0
[ "${1:-}" = "--purge" ] && PURGE=1

rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -f /etc/init.d/ha-vrrp
rm -f /etc/init.d/ha-vrrp-syncd
rm -f /usr/sbin/ha-vrrp-apply
rm -f /usr/sbin/ha-vrrp-sync
rm -f /usr/sbin/ha-vrrp-autosync
rm -rf /usr/libexec/ha-vrrp

# LuCI
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
