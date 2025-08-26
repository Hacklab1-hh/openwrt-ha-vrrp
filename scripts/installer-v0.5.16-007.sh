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
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"
. "$HERE/lib/upgradepath.sh"

TARGET_VERSION="0.5.16-007"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"

action="${1:-migrate}"
echo "[*] Installer $TARGET_VERSION – Aktion: $action"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"; mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
[ -f /etc/config/ha_vrrp ] && tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
CUR=""; [ -f /usr/lib/ha-vrrp/VERSION ] && CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"

do_migrate_chain() {
  if [ -z "${CUR:-}" ]; then
    echo "[*] Frische Installation – keine Migration erforderlich."; return 0
  fi
  echo "[*] Ermittele Migrationskette von $CUR nach $TARGET_VERSION …"
  steps="$("$HERE/lib/upgradepath.sh" step_pairs "$CUR" "$TARGET_VERSION" 2>/dev/null || true)"
  if [ -z "$steps" ]; then
    echo "[!] Keine Kette gefunden (CUR=$CUR TARGET=$TARGET_VERSION)."; return 0
  fi
  echo "$steps" | while read -r FROM TO; do
    script="/usr/lib/ha-vrrp/scripts/migrations/migrate_${FROM}_to_${TO}.sh"
    if [ -x "$script" ]; then echo "[*] MIGRATE Schritt: $FROM → $TO"; "$script" --migrate || true
    else echo "[!] Migrationsskript fehlt: $script (skip)"; fi
  done
}
do_rollback_chain() {
  parent="$( "$HERE/lib/upgradepath.sh" parent_of "$TARGET_VERSION" 2>/dev/null || true )"
  [ -n "$parent" ] || { echo "[!] Kein Parent zu $TARGET_VERSION gefunden."; return 0; }
  echo "[*] Ermittele Rollback-Kette von $TARGET_VERSION nach $parent …"
  steps="$("$HERE/lib/upgradepath.sh" step_pairs "$TARGET_VERSION" "$parent" 2>/dev/null || true)"
  if [ -z "$steps" ]; then echo "[!] Keine Rollback-Kette gefunden."; return 0; fi
  echo "$steps" | while read -r FROM TO; do
    script="/usr/lib/ha-vrrp/scripts/migrations/migrate_${FROM}_to_${TO}.sh"
    if [ -x "$script" ]; then echo "[*] ROLLBACK Schritt: $TO ← $FROM"; "$script" --rollback || true
    else echo "[!] Migrationsskript fehlt: $script (skip)"; fi
  done
}

case "$action" in
  migrate)  do_migrate_chain ;;
  rollback) do_rollback_chain ;;
  *) echo "[!] Unbekannte Aktion: $action"; exit 11 ;;
esac

if [ "$action" = "migrate" ]; then
  [ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
  [ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
  [ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /
  mkdir -p /usr/lib/ha-vrrp
  printf "%s\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION
  uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
  uci -q commit ha_vrrp || true
  rm -f /tmp/luci-* 2>/dev/null || true
  /etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
  /etc/init.d/rpcd restart 2>/dev/null || true
  echo "[*] Installation abgeschlossen: $TARGET_VERSION"
else
  echo "[*] Rollback-Schritte abgeschlossen. Älteres Paket jetzt installieren."
fi
