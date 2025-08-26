#!/bin/sh
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
CFG_DIR="$ROOT_DIR/config"
mkdir -p "$CFG_DIR" "$ROOT_DIR/share/upgrade"

# Move/normalize any existing files into config/
[ -f "$ROOT_DIR/upgradepath.unified.json" ] && mv -f "$ROOT_DIR/upgradepath.unified.json" "$CFG_DIR/upgradepath.unified.json" || true
[ -f "$ROOT_DIR/updatepath.unified.json" ] && mv -f "$ROOT_DIR/updatepath.unified.json" "$CFG_DIR/updatepath.unified.json" || true
[ -f "$ROOT_DIR/upgrade.united.path.json" ] && mv -f "$ROOT_DIR/upgrade.united.path.json" "$CFG_DIR/upgradepath.unified.json" || true

# Create/refresh symlinks
cd "$ROOT_DIR"
ln -sf "./config/upgradepath.unified.json" "./upgradepath.unified.json"
ln -sf "./config/updatepath.unified.json"  "./updatepath.unified.json"
mkdir -p "./share/upgrade"
ln -sf "../config/upgradepath.unified.json" "./share/upgrade/upgradepath.unified.json"
ln -sf "../config/updatepath.unified.json"  "./share/upgrade/updatepath.unified.json"

echo "Migrated to centralized upgrade/update paths (14a)."
