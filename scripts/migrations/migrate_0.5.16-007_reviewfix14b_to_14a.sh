#!/bin/sh
# --- repo root autodetect (works from scripts/migrations/*) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# Roll back from reviewfix14b to reviewfix14a: restore compatibility symlinks
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd)"

mkdir -p "$ROOT_DIR/share/upgrade"
ln -sf "./config/upgradepath.unified.json"  "$ROOT_DIR/upgradepath.unified.json"
ln -sf "./config/updatepath.unified.json"   "$ROOT_DIR/updatepath.unified.json"
ln -sf "../config/upgradepath.unified.json" "$ROOT_DIR/share/upgrade/upgradepath.unified.json"
ln -sf "../config/updatepath.unified.json"  "$ROOT_DIR/share/upgrade/updatepath.unified.json"

echo "Rollback to reviewfix14a compatibility symlinks done."
