#!/bin/sh
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
cd "$ROOT_DIR"

# Remove symlinks
[ -L "./upgradepath.unified.json" ] && rm -f "./upgradepath.unified.json"
[ -L "./updatepath.unified.json" ] && rm -f "./updatepath.unified.json"
[ -L "./share/upgrade/upgradepath.unified.json" ] && rm -f "./share/upgrade/upgradepath.unified.json" || true
[ -L "./share/upgrade/updatepath.unified.json" ] && rm -f "./share/upgrade/updatepath.unified.json" || true

echo "Rollback of symlinks done (14a -> 14)."
