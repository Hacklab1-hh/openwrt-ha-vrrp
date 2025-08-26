#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"
. "$HERE/lib/upgradepath.sh"

cmd="${1:-auto}"; shift || true
current_version(){ [ -f /usr/lib/ha-vrrp/VERSION ] && cat /usr/lib/ha-vrrp/VERSION || echo ""; }
run_series_patch(){ series="$1"; patch="$(latest_patch_for_series "$series")"; [ -n "$patch" ] || { echo "[!] Kein Installer für Serie $series gefunden." >&2; exit 2; }; exec "$HERE/installer-v${series}-${patch}.sh" "$@"; }
run_exact_version(){ ver="$(norm "$1")"; s="$(series_from_version "$ver")"; p="$(pad3 "$(patch_from_version "$ver")")"; [ -x "$HERE/installer-v${s}-${p}.sh" ] || { echo "[!] Kein installer-v${s}-${p}.sh gefunden." >&2; exit 3; }; exec "$HERE/installer-v${s}-${p}.sh" "$@"; }

case "$cmd" in
  auto|"") run_series_patch "0.5.16" ;;
  migrate) target="${1:-}"; [ -n "$target" ] || { echo "[!] Syntax: installer.sh migrate <version>"; exit 1; }; run_exact_version "$target" migrate ;;
  rollback) target="${1:-}"; if [ -n "$target" ]; then run_exact_version "$target" rollback; else cur="$(current_version)"; [ -n "$cur" ] || { echo "[!] Aktuelle Version unbekannt."; exit 5; }; run_exact_version "$cur" rollback; fi ;;
  *) echo "[!] Unbekannter Befehl: $cmd" >&2; echo "    Nutzung: installer.sh [auto|migrate <ver>|rollback [<ver>]]" >&2; exit 9 ;;
esac

# Auto-migrate upgrade/update paths to 14a layout
if [ -x "$(dirname "$0")/migrate_0.5.16-007_reviewfix14_to_14a.sh" ]; then
  "$(dirname "$0")/migrate_0.5.16-007_reviewfix14_to_14a.sh" || true
fi
