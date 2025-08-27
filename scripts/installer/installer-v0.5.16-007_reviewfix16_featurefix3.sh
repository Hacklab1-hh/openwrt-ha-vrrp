#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"
VERSION="0.5.16-007_reviewfix16_featurefix3"
DESTROOT="${DESTROOT:-/}"
rd="$(detect_root)"
log "Installing version $VERSION into $DESTROOT"
[ -d "$rd/files" ] && SRC="$rd/files" || SRC="$rd"
cp -a "$SRC"/. "$DESTROOT"/
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Install $VERSION complete."
