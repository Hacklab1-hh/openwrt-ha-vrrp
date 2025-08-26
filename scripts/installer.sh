#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"
SERIES="0.5.16"
PATCH="$(latest_patch_for_series "$SERIES")"
[ -n "$PATCH" ] || { echo "[!] Kein Installer für Serie $SERIES gefunden." >&2; exit 1; }
exec "$HERE/installer-v${SERIES}-${PATCH}.sh" "$@"
