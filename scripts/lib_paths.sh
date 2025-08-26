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

# Common path helpers for upgrade/update JSONs (14b and later)
set -eu
REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
UPGRADE_JSON="$REPO_ROOT/config/upgradepath.unified.json"
UPDATE_JSON="$REPO_ROOT/config/updatepath.unified.json"
export UPGRADE_JSON UPDATE_JSON
