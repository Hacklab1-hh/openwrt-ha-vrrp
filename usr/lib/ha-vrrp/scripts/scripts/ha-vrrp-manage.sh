#!/bin/sh
# ha-vrrp-manage.sh — data-driven update/rollback using scripts/upgradepath_unified.txt
# Usage:
#   scripts/ha-vrrp-manage.sh update <TARGET_VERSION>
#   scripts/ha-vrrp-manage.sh rollback [<TARGET_VERSION>]   # if target omitted: rollback current to its parent

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/upgradepath.sh"

VERSION_FILE="/usr/lib/ha-vrrp/VERSION"

current_version() {
  [ -f "$VERSION_FILE" ] && cat "$VERSION_FILE" || echo ""
}

# Execute migration steps between FROM and TO
run_chain_migrate() {
  FROM="$1"; TO="$2"
  steps="$("$HERE/lib/upgradepath.sh" step_pairs "$FROM" "$TO" 2>/dev/null || true)"
  [ -n "$steps" ] || { echo "[!] Keine Migrationskette von $FROM nach $TO gefunden."; return 2; }
  echo "$steps" | while read -r A B; do
    script="/usr/lib/ha-vrrp/scripts/migrations/migrate_${A}_to_${B}.sh"
    if [ -x "$script" ]; then
      echo "[*] MIGRATE: $A → $B"
      "$script" --migrate || true
    else
      echo "[!] Migrationsskript fehlt: $script (übersprungen)"
    fi
  done
}

run_chain_rollback() {
  FROM="$1"; TO="$2"
  steps="$("$HERE/lib/upgradepath.sh" step_pairs "$FROM" "$TO" 2>/dev/null || true)"
  [ -n "$steps" ] || { echo "[!] Keine Rollback-Kette von $FROM nach $TO gefunden."; return 2; }
  echo "$steps" | while read -r A B; do
    script="/usr/lib/ha-vrrp/scripts/migrations/migrate_${A}_to_${B}.sh"
    if [ -x "$script" ]; then
      echo "[*] ROLLBACK: $B ← $A"
      "$script" --rollback || true
    else
      echo "[!] Migrationsskript fehlt: $script (übersprungen)"
    fi
  done
}

cmd="${1:-}"; shift || true

case "$cmd" in
  update)
    TARGET="${1:-}"
    [ -n "$TARGET" ] || { echo "Usage: $0 update <TARGET_VERSION>"; exit 1; }
    CUR="$(current_version)"
    if [ -z "$CUR" ]; then
      echo "[*] Kein aktueller Versionsstand (frische Installation) — keine Migrationen notwendig."
    else
      run_chain_migrate "$CUR" "$TARGET"
    fi
    ;;

  rollback)
    TARGET="${1:-}"
    if [ -n "$TARGET" ]; then
      PARENT="$( "$HERE/lib/upgradepath.sh" parent_of "$TARGET" 2>/dev/null || true )"
      [ -n "$PARENT" ] || { echo "[!] Kein Parent zu $TARGET gefunden."; exit 2; }
      run_chain_rollback "$TARGET" "$PARENT"
    else
      CUR="$(current_version)"
      [ -n "$CUR" ] || { echo "[!] Aktuelle Version unbekannt (Datei $VERSION_FILE fehlt)."; exit 3; }
      PARENT="$( "$HERE/lib/upgradepath.sh" parent_of "$CUR" 2>/dev/null || true )"
      [ -n "$PARENT" ] || { echo "[!] Kein Parent zu $CUR gefunden."; exit 4; }
      run_chain_rollback "$CUR" "$PARENT"
    fi
    ;;

  *)
    echo "Usage: $0 {update <ver>|rollback [<ver>]}"
    exit 9
    ;;
esac
