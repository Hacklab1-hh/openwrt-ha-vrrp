#!/bin/sh
# ha-vrrp-manage.sh — Meta-Manager für Install/Uninstall/Update (Serie 0.5.16)
# Nutzung:
#   sh scripts/ha-vrrp-manage.sh detect
#   sh scripts/ha-vrrp-manage.sh install <version|series>
#   sh scripts/ha-vrrp-manage.sh uninstall [<version|series|current>]
#   sh scripts/ha-vrrp-manage.sh update [--to 0.5.16-009]
set -eu

SERIES="0.5.16"
LATEST="0.5.16-009"
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
DESTROOT="${DESTROOT:-/}"

red() { printf "\033[31m%s\033[0m\n" "$*" >&2; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
info() { printf "[*] %s\n" "$*"; }

detect_version() {
  # 1) Installed marker
  if [ -f "/usr/lib/ha-vrrp/VERSION" ]; then
    ver="$(cat /usr/lib/ha-vrrp/VERSION | tr -d '\r\n')"
    [ -n "$ver" ] && echo "$ver" && return 0
  fi
  # 2) UCI
  if command -v uci >/dev/null 2>&1; then
    ver="$(uci -q get ha_vrrp.core.cluster_version 2>/dev/null || true)"
    [ -n "$ver" ] && echo "$ver" && return 0
  fi
  # 3) Fallback (unknown)
  echo "unknown"
  return 0
}

backup_config() {
  ts="$(date +%Y%m%d-%H%M%S)"
  dst="/etc/ha-vrrp/backup-$ts.tgz"
  mkdir -p /etc/ha-vrrp
  tar czf "$dst" /etc/config/ha_vrrp /etc/ha-vrrp 2>/dev/null || true
  info "Config-Backup unter: $dst"
}

run_migrations() {
  # Optional vorhandene Migrationen ausführen
  for s in         "/usr/lib/ha-vrrp/scripts/migrate_0.5.16_002_to_007.sh"         "/usr/lib/ha-vrrp/scripts/migrate_0.5.16_007_to_008.sh"       ; do
    [ -x "$s" ] && { info "Running migration: $s"; "$s" || true; }
  done
}

refresh_luci() {
  rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
  /etc/init.d/rpcd restart 2>/dev/null || true
  /etc/init.d/uhttpd restart 2>/dev/null || true
}

do_install() {
  target="$1"
  case "$target" in
    "$SERIES") target="v$SERIES";;
    "$LATEST") target="v$LATEST";;
    v*) : ;;
    *) target="v$target";;
  esac
  inst="$HERE/installer-$target.sh"
  if [ ! -x "$inst" ]; then
    red "Installer nicht gefunden: $inst"
    exit 2
  fi
  backup_config
  info "Installiere via: $inst"
  DESTROOT="$DESTROOT" "$inst"
  run_migrations
  refresh_luci
  green "Install fertig: $target"
}

do_uninstall() {
  target="${1:-current}"
  case "$target" in
    current)
      ver="$(detect_version)"
      [ "$ver" = "unknown" ] && { red "Keine installierte Version erkannt."; exit 3; }
      target="v$ver"
      ;;
    "$SERIES") target="v$SERIES";;
    "$LATEST") target="v$LATEST";;
    v*) : ;;
    *) target="v$target";;
  esac
  uninst="$HERE/uninstaller-$target.sh"
  if [ ! -x "$uninst" ]; then
    red "Uninstaller nicht gefunden: $uninst"
    exit 2
  fi
  info "Deinstalliere via: $uninst"
  DESTROOT="$DESTROOT" "$uninst"
  refresh_luci
  green "Uninstall fertig: $target"
}

do_update() {
  target="${1:-$LATEST}"
  if [ "$target" = "$SERIES" ]; then target="$LATEST"; fi
  current="$(detect_version)"
  info "Gefundene Version: $current → Ziel: $target"
  if [ "$current" = "$target" ]; then
    info "Bereits auf Zielversion."
    exit 0
  fi
  # Installiere Zielversion
  do_install "$target"
  green "Update abgeschlossen: $current → $target"
}

cmd="${1:-help}"; shift || true
case "$cmd" in
  detect) detect_version ;;
  install) do_install "${1:-$LATEST}" ;;
  uninstall) do_uninstall "${1:-current}" ;;
  update) do_update "${1:-$LATEST}" ;;
  *)
    echo "Usage: $0 [detect|install <ver|series>|uninstall [<ver|series|current>]|update [--to <ver>] ]"
    exit 1
    ;;
esac
