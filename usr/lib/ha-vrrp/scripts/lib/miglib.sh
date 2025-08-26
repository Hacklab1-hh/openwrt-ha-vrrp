#!/bin/sh
set -eu
log(){ echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $*"; }
inf(){ log "[*] $*"; }
ok(){ log "[✓] $*"; }
warn(){ log "[!] $*"; }
err(){ log "[✗] $*"; }
is_dryrun(){ [ "${MIGRATE_DRYRUN:-0}" = "1" ] && return 0; [ "${_ARG_DRYRUN:-0}" = "1" ] && return 0; return 1; }
do_or_echo(){ if is_dryrun; then echo "DRYRUN: $*"; else $@; fi; }
SNAP_DIR_BASE="/etc/ha-vrrp/migrate-snapshots"; mkdir -p "$SNAP_DIR_BASE" 2>/dev/null || true
mk_snapshot(){ _n="$1"; shift || true; TS="$(date +%Y%m%d-%H%M%S)"; OUT="${SNAP_DIR_BASE}/${_n}-${TS}.tgz"; if is_dryrun; then inf "DRYRUN: Snapshot $OUT"; return 0; fi; if [ "$#" -gt 0 ]; then tar -czf "$OUT" "$@" 2>/dev/null || true; else [ -f /etc/config/ha_vrrp ] && tar -czf "$OUT" /etc/config/ha_vrrp 2>/dev/null || true; fi; ok "Snapshot: $OUT"; }
mkparent(){ do_or_echo mkdir -p "$(dirname "$1")"; }
safe_mv(){ SRC="$1"; DST="$2"; [ -e "$SRC" ] || { inf "skip mv: $SRC fehlt"; return 0; }; [ -e "$DST" ] && { inf "skip mv: $DST existiert"; return 0; }; mkparent "$DST"; do_or_echo mv "$SRC" "$DST"; }
safe_cpdir(){ SRC="$1"; DST="$2"; [ -d "$SRC" ] || { inf "skip cp -a: $SRC fehlt"; return 0; }; mkparent "$DST"; do_or_echo cp -a "$SRC/." "$DST/"; }
safe_rm(){ [ -e "$1" ] || { inf "skip rm: $1 existiert nicht"; return 0; }; do_or_echo rm -rf "$1"; }
uci_set_if_missing(){ KEY="$1"; VAL="$2"; if uci -q get "$KEY" >/dev/null 2>&1; then inf "skip uci set: $KEY existiert"; else if is_dryrun; then echo "DRYRUN: uci set $KEY=$VAL"; else uci -q set "$KEY=$VAL" || true; fi; fi; }
uci_rename_option(){ PKGSEC="$1"; OLD="$2"; NEW="$3"; if uci -q get "$PKGSEC.$OLD" >/dev/null 2>&1; then if uci -q get "$PKGSEC.$NEW" >/dev/null 2>&1; then inf "skip uci rename: $PKGSEC.$NEW existiert"; else if is_dryrun; then echo "DRYRUN: uci rename $PKGSEC.$OLD=$NEW"; else uci -q rename "$PKGSEC.$OLD=$NEW" || true; fi; fi; else inf "skip uci rename: $PKGSEC.$OLD fehlt"; fi; }
uci_commit_ha(){ if is_dryrun; then echo "DRYRUN: uci commit ha_vrrp"; else uci -q commit ha_vrrp || true; fi; }
parse_args(){ _ARG_DIRECTION=""; _ARG_DRYRUN=0; while [ $# -gt 0 ]; do case "$1" in --migrate) _ARG_DIRECTION="migrate";; --rollback) _ARG_DIRECTION="rollback";; --dry-run) _ARG_DRYRUN=1;; *) warn "unbekanntes Argument: $1";; esac; shift; done; }
