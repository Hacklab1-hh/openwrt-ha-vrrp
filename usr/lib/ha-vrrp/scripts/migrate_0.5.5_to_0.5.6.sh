#!/bin/sh
# migrate_0.5.5_to_0.5.6.sh – auto-generated from upgradepath.unified.json
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/miglib.sh"

FILE_MOVES_MIG=$(cat <<'EOF'

EOF
)
UCI_RENAMES_MIG=$(cat <<'EOF'

EOF
)
UCI_DEFAULTS_MIG=$(cat <<'EOF'

EOF
)
TRASH_MIG=$(cat <<'EOF'

EOF
)

FILE_MOVES_RB=$(cat <<'EOF'

EOF
)
UCI_RENAMES_RB=$(cat <<'EOF'

EOF
)
UCI_UNSET_ON_RB=$(cat <<'EOF'

EOF
)

apply_file_moves() { echo "$1" | while IFS="$(printf '\t')" read -r SRC DST; do [ -n "${SRC:-}" ] || continue; [ -n "${DST:-}" ] || continue; safe_mv "$SRC" "$DST"; done; }
apply_trash_list(){ echo "$1" | while IFS= read -r P; do [ -n "${P:-}" ] || continue; safe_rm "$P"; done; }
apply_uci_renames(){ echo "$1" | while IFS="$(printf '\t')" read -r PKGSEC OLD NEW; do [ -n "${PKGSEC:-}" ] || continue; [ -n "${OLD:-}" ] || continue; [ -n "${NEW:-}" ] || continue; uci_rename_option "$PKGSEC" "$OLD" "$NEW"; done; }
apply_uci_defaults(){ echo "$1" | while IFS="$(printf '\t')" read -r KEY VAL; do [ -n "${KEY:-}" ] || continue; uci_set_if_missing "$KEY" "$VAL"; done; }
unset_uci_keys(){ echo "$1" | while IFS= read -r KEY; do [ -n "${KEY:-}" ] || continue; if uci -q get "$KEY" >/dev/null 2>&1; then if is_dryrun; then echo "DRYRUN: uci delete $KEY"; else uci -q delete "$KEY" || true; fi; fi; done; }

do_migrate(){
  inf "MIGRATION 0.5.5 → 0.5.6"
  mk_snapshot "pre-mig-0.5.5_to_0.5.6" /etc/config/ha_vrrp /usr/lib/ha-vrrp /luci-app-ha-vrrp || true
  apply_file_moves "$FILE_MOVES_MIG"
  apply_uci_renames "$UCI_RENAMES_MIG"
  apply_uci_defaults "$UCI_DEFAULTS_MIG"; uci_commit_ha
  apply_trash_list "$TRASH_MIG"
  ok "Migration 0.5.5 → 0.5.6 abgeschlossen."
}
do_rollback(){
  inf "ROLLBACK 0.5.6 → 0.5.5"
  mk_snapshot "pre-rb-0.5.6_to_0.5.5" /etc/config/ha_vrrp /usr/lib/ha-vrrp /luci-app-ha-vrrp || true
  apply_file_moves "$FILE_MOVES_RB"
  apply_uci_renames "$UCI_RENAMES_RB"
  unset_uci_keys "$UCI_UNSET_ON_RB"; uci_commit_ha
  ok "Rollback 0.5.6 → 0.5.5 abgeschlossen."
}
parse_args "$@"
[ "${_ARG_DIRECTION:-migrate}" = "rollback" ] && do_rollback || do_migrate
