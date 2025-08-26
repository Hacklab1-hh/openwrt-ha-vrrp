#!/bin/sh
# Installer for openwrt-ha-vrrp 0.5.16-007
# Usage: sh scripts/installer-v0.5.16-007.sh [DESTROOT=/]
set -eu
DESTROOT="${DESTROOT:-/}"
echo "Installing openwrt-ha-vrrp 0.5.16-007 to $DESTROOT"

cd "$(dirname "$0")/.."
PKGROOT="$(pwd)"

# Create target dirs
mkdir -p "$DESTROOT/usr/lib/lua/luci"              "$DESTROOT/usr/libexec/ha-vrrp"              "$DESTROOT/usr/lib/ha-vrrp/lib"              "$DESTROOT/usr/lib/ha-vrrp/scripts"

# LuCI app
if [ -d "$PKGROOT/luci-app-ha-vrrp/luasrc" ]; then
  cp -a "$PKGROOT/luci-app-ha-vrrp/luasrc/"* "$DESTROOT/usr/lib/lua/luci/"
fi

# Execs & libs (if present)
[ -d "$PKGROOT/usr/libexec/ha-vrrp" ] && cp -a "$PKGROOT/usr/libexec/ha-vrrp/"* "$DESTROOT/usr/libexec/ha-vrrp/" || true
[ -d "$PKGROOT/usr/lib/ha-vrrp/lib" ] && cp -a "$PKGROOT/usr/lib/ha-vrrp/lib/"* "$DESTROOT/usr/lib/ha-vrrp/lib/" || true
[ -d "$PKGROOT/usr/lib/ha-vrrp/scripts" ] && cp -a "$PKGROOT/usr/lib/ha-vrrp/scripts/"* "$DESTROOT/usr/lib/ha-vrrp/scripts/" || true

# Permissions
chmod 0755 "$DESTROOT/usr/libexec/ha-vrrp/"* 2>/dev/null || true
chmod 0755 "$DESTROOT/usr/lib/ha-vrrp/lib/"* 2>/dev/null || true
chmod 0755 "$DESTROOT/usr/lib/ha-vrrp/scripts/"*.sh 2>/dev/null || true

# Refresh LuCI & web
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

echo "Install done (v0.5.16-007)."
