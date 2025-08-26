#!/bin/sh
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
cd "$ROOT_DIR"

# Remove symlinks
[ -L "./config/upgradepath.unified.json" ] && rm -f "./config/upgradepath.unified.json"
[ -L "./config/updatepath.unified.json" ] && rm -f "./config/updatepath.unified.json"
[ -L "./share/upgrade/./config/upgradepath.unified.json" ] && rm -f "./share/upgrade/./config/upgradepath.unified.json" || true
[ -L "./share/upgrade/./config/updatepath.unified.json" ] && rm -f "./share/upgrade/./config/updatepath.unified.json" || true

echo "Rollback of symlinks done (14a -> 14)."
