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

# Version-specific uninstaller for openwrt-ha-vrrp 0.5.9
set -eu
DESTROOT="${DESTROOT:-/}"
rm -rf "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"                "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp"                "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp"                "$DESTROOT/usr/libexec/ha-vrrp"                "$DESTROOT/usr/lib/ha-vrrp"
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
