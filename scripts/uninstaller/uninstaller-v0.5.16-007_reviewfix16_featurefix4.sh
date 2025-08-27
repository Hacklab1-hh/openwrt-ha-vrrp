#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"
DESTROOT="${DESTROOT:-/}"
log "Uninstalling version 0.5.16-007_reviewfix16_featurefix4 from $DESTROOT"
rm -f "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"           "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/general.lua"           "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/peers.lua"           "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/segment.lua"           "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/overview.htm"           "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/status.htm"           "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/logs.htm"           "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/discover.htm"           "$DESTROOT/usr/sbin/ha-vrrp-api" 2>/dev/null || true
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Uninstall complete."
