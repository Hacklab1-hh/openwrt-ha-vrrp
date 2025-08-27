#!/bin/sh
# Common helpers (POSIX sh, busybox-kompatibel)
set -eu

ROOT_HINT="$(dirname -- "$0")"

detect_root() {
  for cand in "$ROOT_HINT"/.. "$ROOT_HINT"/../.. "$ROOT_HINT"/../../.. "$PWD" ; do
    [ -f "$cand/VERSION" ] && echo "$cand" && return 0 || true
    [ -f "$cand/config/upgradepath.unified.json" ] && echo "$cand" && return 0 || true
  done
  echo "$PWD"
}

log()  { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
die()  { echo "[x] $*" >&2; exit 1; }

get_version() {
  if [ -n "${TARGET_VERSION:-}" ]; then
    echo "$TARGET_VERSION"; return 0
  fi
  if [ -n "${VERSION:-}" ] ; then
    echo "$VERSION"; return 0
  fi
  local rd
  rd="$(detect_root)"
  if [ -f "$rd/VERSION" ]; then
    cat "$rd/VERSION"
    return 0
  fi
  echo "0.0.0-unknown"
}

normalize_version_for_filename() {
  echo "$1" | sed 's#[^A-Za-z0-9._-]#_#g'
}

has_git() {
  local rd
  rd="$(detect_root)"
  [ -d "$rd/.git" ] && command -v git >/dev/null 2>&1
}

sha256sum_check() {
  [ -n "${2:-}" ] || return 0
  [ -f "$1" ] || return 0
  local sum
  sum="$(sha256sum "$1" | awk '{print $1}' || true)"
  [ "$sum" = "$2" ]
}

list_local_versioned_installers() {
  local rd instdir
  rd="$(detect_root)"
  instdir="$rd/scripts/installer"
  if [ -d "$instdir" ]; then
    (cd "$instdir" && ls -1 installer-v*.sh 2>/dev/null || true)
  fi
}

list_local_versioned_uninstallers() {
  local rd undir
  rd="$(detect_root)"
  undir="$rd/scripts/uninstaller"
  if [ -d "$undir" ]; then
    (cd "$undir" && ls -1 uninstaller-v*.sh 2>/dev/null || true)
  fi
}
