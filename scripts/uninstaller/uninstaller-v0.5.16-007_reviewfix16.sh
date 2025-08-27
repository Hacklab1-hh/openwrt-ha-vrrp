#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"

DESTROOT="${DESTROOT:-/}"
log "Uninstalling version 0.5.16-007_reviewfix16 from $DESTROOT"

# Remove LuCI app files
rm -f "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua" \
      "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/general.lua" \
      "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/peers.lua" \
      "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/overview.htm" 2>/dev/null || true

# Core (keep safe removes even if files moved in future)
rm -f "$DESTROOT/etc/init.d/ha-vrrp" "$DESTROOT/etc/init.d/ha-vrrp-syncd" 2>/dev/null || true
rm -rf "$DESTROOT/usr/libexec/ha-vrrp" 2>/dev/null || true
rm -f "$DESTROOT/usr/sbin/ha-vrrp-apply" "$DESTROOT/usr/sbin/ha-vrrp-sync" "$DESTROOT/usr/sbin/ha-vrrp-autosync" 2>/dev/null || true
rm -f "$DESTROOT/etc/config/ha_vrrp" 2>/dev/null || true

rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Uninstall complete."
