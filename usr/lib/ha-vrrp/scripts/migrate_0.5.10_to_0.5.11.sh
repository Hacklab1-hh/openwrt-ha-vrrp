#!/bin/sh
# migrate_0.5.10_to_0.5.11.sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/miglib.sh"

FILE_MOVES_MIG=$(cat <<'EOF'
/usr/lib/ha-vrrp/scripts/legacy_watch.sh	/usr/lib/ha-vrrp/scripts/watch.sh
/usr/lib/ha-vrrp/templates/fw3	/usr/lib/ha-vrrp/backends/fw3
/usr/lib/ha-vrrp/templates/fw4	/usr/lib/ha-vrrp/backends/fw4
/luci-app-ha-vrrp/htdocs/luci-static/resources/view/ha-vrrp/cluster-old.js	/luci-app-ha-vrrp/htdocs/luci-static/resources/view/ha-vrrp/cluster.js
EOF
)

UCI_RENAMES_MIG=$(cat <<'EOF'
ha_vrrp.core	peer_netmask	peer_netmask_cidr
ha_vrrp.core	cluster_name	cluster_id
EOF
)

UCI_DEFAULTS_MIG=$(cat <<'EOF'
ha_vrrp.core.peer_netmask_cidr	24
ha_vrrp.core.cluster_id	default
EOF
)

TRASH_MIG=$(cat <<'EOF'
/usr/lib/ha-vrrp/scripts/tmp/
/usr/lib/ha-vrrp/templates/obsolete
EOF
)

FILE_MOVES_RB=$(cat <<'EOF'
/usr/lib/ha-vrrp/scripts/watch.sh	/usr/lib/ha-vrrp/scripts/legacy_watch.sh
/usr/lib/ha-vrrp/backends/fw3	/usr/lib/ha-vrrp/templates/fw3
/usr/lib/ha-vrrp/backends/fw4	/usr/lib/ha-vrrp/templates/fw4
/luci-app-ha-vrrp/htdocs/luci-static/resources/view/ha-vrrp/cluster.js	/luci-app-ha-vrrp/htdocs/luci-static/resources/view/ha-vrrp/cluster-old.js
EOF
)

UCI_RENAMES_RB=$(cat <<'EOF'
ha_vrrp.core	peer_netmask_cidr	peer_netmask
ha_vrrp.core	cluster_id	cluster_name
EOF
)

UCI_UNSET_ON_RB=$(cat <<'EOF'
ha_vrrp.core.peer_netmask_cidr
ha_vrrp.core.cluster_id
EOF
)

apply_file_moves() {
  echo "$1" | while IFS="$(printf '\t')" read -r SRC DST; do
    [ -n "${SRC:-}" ] || continue
    [ -n "${DST:-}" ] || continue
    safe_mv "$SRC" "$DST"
  done
}

apply_trash_list() {
  echo "$1" | while IFS= read -r P; do
    [ -n "${P:-}" ] || continue
    safe_rm "$P"
  done
}

apply_uci_renames() {
  echo "$1" | while IFS="$(printf '\t')" read -r PKGSEC OLD NEW; do
    [ -n "${PKGSEC:-}" ] || continue
    [ -n "${OLD:-}" ] || continue
    [ -n "${NEW:-}" ] || continue
    uci_rename_option "$PKGSEC" "$OLD" "$NEW"
  done
}

apply_uci_defaults() {
  echo "$1" | while IFS="$(printf '\t')" read -r KEY VAL; do
    [ -n "${KEY:-}" ] || continue
    uci_set_if_missing "$KEY" "$VAL"
  done
}

unset_uci_keys() {
  echo "$1" | while IFS= read -r KEY; do
    [ -n "${KEY:-}" ] || continue
    if uci -q get "$KEY" >/dev/null 2>&1; then
      if is_dryrun; then
        echo "DRYRUN: uci delete $KEY"
      else
        uci -q delete "$KEY" || true
      fi
    fi
  done
}

do_migrate() {
  inf "Starte MIGRATION 0.5.10 → 0.5.11"
  mk_snapshot "pre-mig-0.5.10_to_0.5.11" /etc/config/ha_vrrp /usr/lib/ha-vrrp /luci-app-ha-vrrp || true

  inf "Dateibewegungen anwenden (10→11)…"
  apply_file_moves "$FILE_MOVES_MIG"

  inf "UCI: Optionenumbenennungen (10→11)…"
  apply_uci_renames "$UCI_RENAMES_MIG"

  inf "UCI: Defaults setzen (nur wenn fehlend)…"
  apply_uci_defaults "$UCI_DEFAULTS_MIG"
  uci_commit_ha

  inf "Aufräumen alter Artefakte…"
  apply_trash_list "$TRASH_MIG"

  ok "Migration 0.5.10 → 0.5.11 abgeschlossen."
}

do_rollback() {
  inf "Starte ROLLBACK 0.5.11 → 0.5.10"
  mk_snapshot "pre-rb-0.5.11_to_0.5.10" /etc/config/ha_vrrp /usr/lib/ha-vrrp /luci-app-ha-vrrp || true

  inf "Dateibewegungen zurückdrehen (11→10)…"
  apply_file_moves "$FILE_MOVES_RB"

  inf "UCI: Optionenumbenennungen zurückdrehen (11→10)…"
  apply_uci_renames "$UCI_RENAMES_RB"

  inf "UCI: 11er Defaults entfernen (falls nicht im 10er Schema)…"
  unset_uci_keys "$UCI_UNSET_ON_RB"
  uci_commit_ha

  ok "Rollback 0.5.11 → 0.5.10 abgeschlossen."
}

parse_args "$@"
if [ "${_ARG_DIRECTION:-}" = "rollback" ]; then
  do_rollback
else
  do_migrate
fi
