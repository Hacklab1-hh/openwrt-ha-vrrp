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

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"
PATCH="$(latest_patch_for_series "0.5.16")"
[ -n "$PATCH" ] || { echo "[!] Kein Patch-Installer für Serie 0.5.16 gefunden."; exit 2; }
exec "$HERE/installer-v0.5.16-${PATCH}.sh" "$@"
