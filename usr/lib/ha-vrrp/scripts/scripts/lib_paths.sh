#!/bin/sh
# Common path helpers for upgrade/update JSONs (14b and later)
set -eu
REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd)"
UPGRADE_JSON="$REPO_ROOT/config/upgradepath.unified.json"
UPDATE_JSON="$REPO_ROOT/config/updatepath.unified.json"
export UPGRADE_JSON UPDATE_JSON
