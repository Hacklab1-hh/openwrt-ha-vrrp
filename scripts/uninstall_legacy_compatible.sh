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

# uninstall_legacy_compatible.sh – orientiert am Ur-Uninstaller
set -eu

echo "[uninstall-legacy] Stopping services…"
/etc/init.d/ha-vrrp stop 2>/dev/null || true
/etc/init.d/keepalived stop 2>/dev/null || true
/etc/init.d/ha-vrrp disable 2>/dev/null || true

echo "[uninstall-legacy] Removing installed files…"
rm -f /etc/init.d/ha-vrrp /etc/init.d/ha-vrrp-syncd
rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -rf /usr/libexec/ha-vrrp
rm -f /usr/sbin/ha-vrrp-apply /usr/sbin/ha-vrrp-sync /usr/sbin/ha-vrrp-autosync

# Keep config as original did by default
# rm -f /etc/config/ha_vrrp

# LuCI app files (only if overlay-installed)
rm -f /usr/lib/lua/luci/controller/ha_vrrp.lua 2>/dev/null || true
rm -rf /usr/lib/lua/luci/model/cbi/ha_vrrp 2>/dev/null || true
rm -rf /usr/lib/lua/luci/view/ha_vrrp 2>/dev/null || true

echo "[uninstall-legacy] Note: keepalived package remains. Remove with 'opkg remove keepalived' if desired."
echo "[uninstall-legacy] Done."
