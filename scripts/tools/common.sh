#!/bin/sh
set -eu

ROOT_HINT="$(dirname -- "$0")"
detect_root() {
  for cand in "$ROOT_HINT"/.. "$ROOT_HINT"/../.. "$ROOT_HINT"/../../.. "$PWD" ; do
    [ -f "$cand/VERSION" ] && echo "$cand" && return 0 || true
    [ -f "$cand/config/upgradepath.unified.json" ] && echo "$cand" && return 0 || true
  done
  echo "$PWD"
}

sha256sum_check() {
  [ -n "${2:-}" ] || return 0
  [ -f "$1" ] || return 0
  SUM="$(sha256sum "$1" | awk '{print $1}' || true)"
  [ "$SUM" = "$2" ]
}

log() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
die() { echo "[x] $*" >&2; exit 1; }

get_version() {
  if [ -n "${VERSION:-}" ]; then
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
