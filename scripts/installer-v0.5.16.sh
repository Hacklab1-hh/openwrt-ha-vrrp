#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"
PATCH="$(latest_patch_for_series "0.5.16")"
[ -n "$PATCH" ] || { echo "[!] Kein Patch-Installer für Serie 0.5.16 gefunden."; exit 2; }
exec "$HERE/installer-v0.5.16-${PATCH}.sh" "$@"
