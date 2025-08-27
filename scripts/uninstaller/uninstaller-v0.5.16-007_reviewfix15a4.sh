#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"

DESTROOT="${DESTROOT:-/}"
log "Uninstalling version 0.5.16-007_reviewfix15a4 from $DESTROOT"

rm -rf "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"        "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp"        "$DESTROOT/usr/libexec/ha-vrrp"        "$DESTROOT/usr/lib/ha-vrrp"        "$DESTROOT/etc/init.d/ha-vrrp"        "$DESTROOT/etc/ha-vrrp" 2>/dev/null || true

rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Uninstall complete."
