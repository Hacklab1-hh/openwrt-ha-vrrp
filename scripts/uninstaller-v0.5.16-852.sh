#!/bin/sh
# Version-specific uninstaller for openwrt-ha-vrrp 0.5.16-852
set -eu
DESTROOT="${DESTROOT:-/}"
rm -rf "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"                "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp"                "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp"                "$DESTROOT/usr/libexec/ha-vrrp"                "$DESTROOT/usr/lib/ha-vrrp"
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
