#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# --- repo root autodetect (works from scripts/migrate/*) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd)"
cd "$ROOT_DIR"

# Remove symlinks
[ -L "./config/upgradepath.unified.json" ] && rm -f "./config/upgradepath.unified.json"
[ -L "./config/updatepath.unified.json" ] && rm -f "./config/updatepath.unified.json"
[ -L "./share/upgrade/./config/upgradepath.unified.json" ] && rm -f "./share/upgrade/./config/upgradepath.unified.json" || true
[ -L "./share/upgrade/./config/updatepath.unified.json" ] && rm -f "./share/upgrade/./config/updatepath.unified.json" || true

echo "Rollback of symlinks done (14a -> 14)."
