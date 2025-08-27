#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/tools/common.sh"

VERSION="$(get_version)"
MODE="${MODE:-auto}"
DESTROOT="${DESTROOT:-/}"

log "Uninstaller dispatcher – VERSION=$VERSION MODE=$MODE DESTROOT=$DESTROOT"

rd="$(detect_root)"
un_local="$rd/scripts/uninstaller"
spec_name="uninstaller-v$(normalize_version_for_filename "$VERSION").sh"
spec_path="$un_local/$spec_name"

if [ -x "$spec_path" ]; then
  log "Using local specialized uninstaller: scripts/uninstaller/$spec_name"
  exec "$spec_path"
fi

warn "Specialized uninstaller not found. Running generic uninstall."
rm -rf "$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua"        "$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp"        "$DESTROOT/usr/libexec/ha-vrrp"        "$DESTROOT/usr/lib/ha-vrrp"        "$DESTROOT/etc/init.d/ha-vrrp"        "$DESTROOT/etc/ha-vrrp" 2>/dev/null || true
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Generic uninstall complete."
