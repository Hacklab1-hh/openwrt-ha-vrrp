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

# Migrate from reviewfix14a to reviewfix14b: drop symlinks and enforce config paths
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd)"

# Remove symlinks if present
[ -L "$ROOT_DIR/upgradepath.unified.json" ] && rm -f "$ROOT_DIR/upgradepath.unified.json"
[ -L "$ROOT_DIR/updatepath.unified.json" ] && rm -f "$ROOT_DIR/updatepath.unified.json"
[ -L "$ROOT_DIR/share/upgrade/upgradepath.unified.json" ] && rm -f "$ROOT_DIR/share/upgrade/upgradepath.unified.json" || true
[ -L "$ROOT_DIR/share/upgrade/updatepath.unified.json" ] && rm -f "$ROOT_DIR/share/upgrade/updatepath.unified.json" || true

# Remove empty share/upgrade dirs
if [ -d "$ROOT_DIR/share/upgrade" ] && [ -z "$(ls -A "$ROOT_DIR/share/upgrade" 2>/dev/null || true)" ]; then
  rmdir "$ROOT_DIR/share/upgrade" || true
  [ -d "$ROOT_DIR/share" ] && [ -z "$(ls -A "$ROOT_DIR/share" 2>/dev/null || true)" ] && rmdir "$ROOT_DIR/share" || true
fi

echo "Migrated to reviewfix14b (symlinks removed; config paths authoritative)."
