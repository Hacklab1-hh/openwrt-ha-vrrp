#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/tools/common.sh"

VERSION="$(get_version)"
MODE="${MODE:-auto}"
DESTROOT="${DESTROOT:-/}"
WORKDIR="${WORKDIR:-/tmp/ha-vrrp-inst}"

log "Installer dispatcher – VERSION=$VERSION MODE=$MODE DESTROOT=$DESTROOT"

rd="$(detect_root)"
inst_local="$rd/scripts/installer"
spec_name="installer-v$(normalize_version_for_filename "$VERSION").sh"
spec_path="$inst_local/$spec_name"

if [ -x "$spec_path" ]; then
  log "Using local specialized installer: scripts/installer/$spec_name"
  exec "$spec_path"
fi

if [ "$MODE" = "local" ]; then
  warn "Specialized installer not found locally. Proceeding with generic local install."
  SRC1="$rd/ha-vrrp/files"; SRC2="$rd/files"
  if [ -d "$SRC1" ]; then SRC="$SRC1"; elif [ -d "$SRC2" ]; then SRC="$SRC2"; else SRC="$rd"; fi
  log "Copying files from $SRC into $DESTROOT"
  cp -a "$SRC"/. "$DESTROOT"/
  rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
  log "Generic install done."
  exit 0
fi

log "Fetching version from GitHub: $VERSION"
rm -rf "$WORKDIR"; mkdir -p "$WORKDIR"
DESTDIR="$WORKDIR/pkg" VERSION="$VERSION" SRC_REF="$VERSION" "$HERE/tools/fetch_from_github.sh"

spec_path="$WORKDIR/pkg/scripts/installer/$spec_name"
if [ -x "$spec_path" ]; then
  log "Using fetched specialized installer: $(echo "$spec_path" | sed "s#^$WORKDIR/pkg/##")"
  exec "$spec_path"
fi

warn "Fetched tree has no specialized installer for $VERSION. Falling back to generic install."
SRC1="$WORKDIR/pkg/ha-vrrp/files"; SRC2="$WORKDIR/pkg/files"
if [ -d "$SRC1" ]; then SRC="$SRC1"; elif [ -d "$SRC2" ]; then SRC="$SRC2"; else SRC="$WORKDIR/pkg"; fi
log "Copying files from $SRC into $DESTROOT"
cp -a "$SRC"/. "$DESTROOT"/
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Generic install (fetched) done."
