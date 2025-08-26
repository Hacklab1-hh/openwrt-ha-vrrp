#!/bin/sh
# Roll back from reviewfix14b to reviewfix14a: restore compatibility symlinks
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"

mkdir -p "$ROOT_DIR/share/upgrade"
ln -sf "./config/upgradepath.unified.json"  "$ROOT_DIR/upgradepath.unified.json"
ln -sf "./config/updatepath.unified.json"   "$ROOT_DIR/updatepath.unified.json"
ln -sf "../config/upgradepath.unified.json" "$ROOT_DIR/share/upgrade/upgradepath.unified.json"
ln -sf "../config/updatepath.unified.json"  "$ROOT_DIR/share/upgrade/updatepath.unified.json"

echo "Rollback to reviewfix14a compatibility symlinks done."
