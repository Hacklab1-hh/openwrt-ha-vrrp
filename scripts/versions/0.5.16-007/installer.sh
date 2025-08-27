#!/bin/sh
# Installer for openwrt-ha-vrrp 0.5.16-007_reviewfix15a
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/tools/common.sh"

VERSION="0.5.16-007_reviewfix15a"
DESTROOT="${DESTROOT:-/}"
MODE="${MODE:-auto}"   # auto|local|github
WORKDIR="${WORKDIR:-/tmp/ha-vrrp-inst}"

log "Installer starting for VERSION=$VERSION MODE=$MODE DESTROOT=$DESTROOT"

ROOT_DIR="$(detect_root)"
PKG_ROOT="$ROOT_DIR"

# determine local package presence
has_local=0
if [ -d "$PKG_ROOT/ha-vrrp/files/usr" ] || [ -d "$PKG_ROOT/usr/lib/ha-vrrp" ]; then
  has_local=1
fi

if [ "$MODE" = "github" ] || [ "$MODE" = "auto" -a $has_local -eq 0 ]; then
  log "Using GitHub fetch mode"
  rm -rf "$WORKDIR"
  mkdir -p "$WORKDIR"
  DESTDIR="$WORKDIR/pkg" VERSION="$VERSION" SRC_REF="$VERSION" \
  "$HERE/tools/fetch_from_github.sh"
  PKG_ROOT="$WORKDIR/pkg"
else
  log "Using local package at $PKG_ROOT"
fi

SRC1="$PKG_ROOT/ha-vrrp/files"
SRC2="$PKG_ROOT/files"
if [ -d "$SRC1" ]; then
  SRC="$SRC1"
elif [ -d "$SRC2" ]; then
  SRC="$SRC2"
else
  SRC="$PKG_ROOT"
fi

log "Copying files from $SRC into $DESTROOT"
cp -a "$SRC"/. "$DESTROOT"/

rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Install complete."
