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

        #!/bin/sh
        # Version-specific installer for openwrt-ha-vrrp 0.5.15
        # Performs pre-migration (directory moves/renames) BEFORE copying new files.
        set -eu
        DESTROOT="${DESTROOT:-/}"
        TARGET="0.5.15"
        SERIES="0.5.16"
        LATEST="0.5.16-009"
        HERE="$(cd "$(dirname "$0")" && pwd)"
        PKGROOT="$(cd "$HERE/.." && pwd)"

        version_to_nums() {
  # $1: version like 0.5.16-009 or 0.5.12
  v="$1"
  main="${v%%-*}"
  patch="${v#*-}"
  [ "$patch" = "$v" ] && patch="000"
  IFS=. set -- $main
  major="${1:-0}"; minor="${2:-0}"; micro="${3:-0}"
  printf "%03d %03d %03d %03d" "$major" "$minor" "$micro" "$patch"
}
version_ge() { # $1 >= $2 ?
  set -- $(version_to_nums "$1") $(version_to_nums "$2")
  [ $1 -gt $5 ] && return 0; [ $1 -lt $5 ] && return 1
  [ $2 -gt $6 ] && return 0; [ $2 -lt $6 ] && return 1
  [ $3 -gt $7 ] && return 0; [ $3 -lt $7 ] && return 1
  [ $4 -ge $8 ]
}


        info() { printf "[*] %s\n" "$*"; }
        warn() { printf "\033[33m[!] %s\033[0m\n" "$*"; }
        err()  { printf "\033[31m[✗] %s\033[0m\n" "$*" >&2; exit 1; }

        backup_config() {
          ts="$(date +%Y%m%d-%H%M%S)"
          dst="/etc/ha-vrrp/backup-$ts.tgz"
          mkdir -p /etc/ha-vrrp
          tar czf "$dst" /etc/config/ha_vrrp /etc/ha-vrrp 2>/dev/null || true
          info "Config-Backup: $dst"
        }

        run_pre_migrations() {
          # Dispatch migrations required for TARGET
          if version_ge "$TARGET" "0.5.16-007"; then
            [ -x "$scripts/migrate/migrate_0.5.16_002_to_007.sh" ] && {
              info "Pre-migrate: 0.5.16_002_to_007"
              "$scripts/migrate/migrate_0.5.16_002_to_007.sh" || true
            }
          fi
          if version_ge "$TARGET" "0.5.16-008"; then
            [ -x "$scripts/migrate/migrate_0.5.16_007_to_008.sh" ] && {
              info "Pre-migrate: 0.5.16_007_to_008"
              "$scripts/migrate/migrate_0.5.16_007_to_008.sh" || true
            }
          fi
        }

        refresh_luci() {
          rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
          /etc/init.d/rpcd restart 2>/dev/null || true
          /etc/init.d/uhttpd restart 2>/dev/null || true
        }

        do_install_files() {
          mkdir -p "$DESTROOT/usr/lib/lua/luci"                    "$DESTROOT/usr/libexec/ha-vrrp"                    "$DESTROOT/usr/lib/ha-vrrp/lib"                    "$DESTROOT/usr/lib/ha-vrrp/scripts"

          # LuCI app
          if [ -d "$PKGROOT/luci-app-ha-vrrp/luasrc" ]; then
            cp -a "$PKGROOT/luci-app-ha-vrrp/luasrc/"* "$DESTROOT/usr/lib/lua/luci/"
          fi
          # Execs & libs & scripts
          [ -d "$PKGROOT/usr/libexec/ha-vrrp" ] && cp -a "$PKGROOT/usr/libexec/ha-vrrp/"* "$DESTROOT/usr/libexec/ha-vrrp/" || true
          [ -d "$PKGROOT/usr/lib/ha-vrrp/lib" ] && cp -a "$PKGROOT/usr/lib/ha-vrrp/lib/"* "$DESTROOT/usr/lib/ha-vrrp/lib/" || true
          [ -d "$PKGROOT/usr/lib/ha-vrrp/scripts" ] && cp -a "$PKGROOT/usr/lib/ha-vrrp/scripts/"* "$DESTROOT/usr/lib/ha-vrrp/scripts/" || true

          # Permissions
          chmod 0755 "$DESTROOT/usr/libexec/ha-vrrp/"* 2>/dev/null || true
          chmod 0755 "$DESTROOT/usr/lib/ha-vrrp/lib/"* 2>/dev/null || true
          chmod 0755 "$DESTROOT/usr/lib/ha-vrrp/scripts/"*.sh 2>/dev/null || true

          # Version marker
          mkdir -p "$DESTROOT/usr/lib/ha-vrrp"
          echo "0.5.15" > "$DESTROOT/usr/lib/ha-vrrp/VERSION"
        }

        main() {
          info "Installer startet für Version: $TARGET"
          backup_config
          run_pre_migrations
          do_install_files
          refresh_luci
          info "Install abgeschlossen: $TARGET"
        }
        main "$@"
