#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../tools/common.sh"

VERSION="0.5.16-007_reviewfix15a4"
DESTROOT="${DESTROOT:-/}"

rd="$(detect_root)"
log "Installing version $VERSION into $DESTROOT"

SRC1="$rd/ha-vrrp/files"
SRC2="$rd/files"
if [ -d "$SRC1" ]; then
  SRC="$SRC1"
elif [ -d "$SRC2" ]; then
  SRC="$SRC2"
else
  SRC="$rd"
fi

cp -a "$SRC"/. "$DESTROOT"/

rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Install $VERSION complete."
