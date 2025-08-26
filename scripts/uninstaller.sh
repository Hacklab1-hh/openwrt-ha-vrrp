#!/bin/sh
set -eu
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
if [ ! -f "$ROOT_DIR/gen-base-md.sh" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
export ROOT_DIR
VRRP_CACHE="/root/vrrp-cache"
VRRP_CUR="/root/openwrt-ha-vrrp_current"
. "$ROOT_DIR/node/lib_repo.sh"
usage(){ cat <<EOF
Usage: $0 [--rollback-prev] [--purge <version|all>] [--keep N]
EOF
}
ROLLBACK=0; PURGE=""; KEEP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --rollback-prev) ROLLBACK=1; shift;;
    --purge) PURGE="${2:-}"; shift 2;;
    --keep) KEEP="${2:-0}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done
[ -L "$VRRP_CUR" ] || [ -e "$VRRP_CUR" ] && rm -f "$VRRP_CUR" || echo "[INFO] kein aktiver Link"
if [ $ROLLBACK -eq 1 ]; then
  prev="$(find "$VRRP_CACHE" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %P\n' 2>/dev/null | sort -n | awk 'END{print prev}{prev=$2}')"
  [ -n "$prev" ] && [ -d "$VRRP_CACHE/$prev" ] && repo_switch_symlink "$VRRP_CACHE" "$VRRP_CUR" "$prev" || echo "[WARN] kein vorheriger Snapshot"
fi
if [ -n "$PURGE" ]; then
  if [ "$PURGE" = "all" ]; then
    for d in $(find "$VRRP_CACHE" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %P\n' | sort -n | awk -v k="$KEEP" '{print $2}' | head -n -"$KEEP"); do
      rm -rf "$VRRP_CACHE/$d"
    done
  else
    [ -d "$VRRP_CACHE/$PURGE" ] && rm -rf "$VRRP_CACHE/$PURGE" || echo "[WARN] Version nicht im Cache: $PURGE"
  fi
fi
