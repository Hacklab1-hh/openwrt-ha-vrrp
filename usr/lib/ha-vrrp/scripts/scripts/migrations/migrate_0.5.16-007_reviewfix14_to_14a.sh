#!/bin/sh
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
CFG_DIR="$ROOT_DIR/config"
mkdir -p "$CFG_DIR" "$ROOT_DIR/share/upgrade"

# Move/normalize any existing files into config/
[ -f "$ROOT_DIR/./config/upgradepath.unified.json" ] && mv -f "$ROOT_DIR/./config/upgradepath.unified.json" "$CFG_DIR/./config/upgradepath.unified.json" || true
[ -f "$ROOT_DIR/./config/updatepath.unified.json" ] && mv -f "$ROOT_DIR/./config/updatepath.unified.json" "$CFG_DIR/./config/updatepath.unified.json" || true
[ -f "$ROOT_DIR/upgrade.united.path.json" ] && mv -f "$ROOT_DIR/upgrade.united.path.json" "$CFG_DIR/./config/upgradepath.unified.json" || true

# Create/refresh symlinks
cd "$ROOT_DIR"
ln -sf "./config/./config/upgradepath.unified.json" "./config/upgradepath.unified.json"
ln -sf "./config/./config/updatepath.unified.json"  "./config/updatepath.unified.json"
mkdir -p "./share/upgrade"
ln -sf "../config/./config/upgradepath.unified.json" "./share/upgrade/./config/upgradepath.unified.json"
ln -sf "../config/./config/updatepath.unified.json"  "./share/upgrade/./config/updatepath.unified.json"

echo "Migrated to centralized upgrade/update paths (14a)."
