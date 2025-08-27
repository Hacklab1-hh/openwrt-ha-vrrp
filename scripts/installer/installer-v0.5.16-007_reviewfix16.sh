#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"

VERSION="0.5.16-007_reviewfix16"
DESTROOT="${DESTROOT:-/}"

rd="$(detect_root)"
log "Installing version $VERSION into $DESTROOT"

# Prefer structured package tree if present
if [ -d "$rd/ha-vrrp/files" ]; then
  SRC="$rd/ha-vrrp/files"
else
  SRC="$rd/files"
fi

cp -a "$SRC"/. "$DESTROOT"/

# Refresh LuCI caches
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Install $VERSION complete."
