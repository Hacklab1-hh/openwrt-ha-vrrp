#!/bin/sh
# Uninstaller for openwrt-ha-vrrp 0.5.16-007
set -eu
DESTROOT="${DESTROOT:-/}"
echo "Uninstalling openwrt-ha-vrrp 0.5.16-007 from $DESTROOT"

rm -rf "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"            "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp"            "$DESTROOT/usr/lib/lua/luci/view/ha_vrrp"            "$DESTROOT/usr/libexec/ha-vrrp"            "$DESTROOT/usr/lib/ha-vrrp"

rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

echo "Uninstall done (v0.5.16-007)."
