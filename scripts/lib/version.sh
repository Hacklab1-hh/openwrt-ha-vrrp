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
REPO_CONF="/etc/ha-vrrp/installer.conf"
REPO_PATH="${REPO_PATH:-/root/vrrp-repo}"
DOWNLOAD_REPO_PATH="${DOWNLOAD_REPO_PATH:-}"
IPK_REPO_PATH="${IPK_REPO_PATH:-/root/vrrp-ipk-repo}"
IPK_REPO_PATH_ALT="${IPK_REPO_PATH_ALT:-}"
[ -r "$REPO_CONF" ] && . "$REPO_CONF"
series_from_version(){ echo "$1" | awk -F- '{print $1}'; }
patch_from_version(){ case "$1" in *-*) echo "$1" | awk -F- '{print $2}' ;; *) echo "" ;; esac; }
pad3(){ n="${1:-0}"; n=$((10#$n)); printf "%03d" "$n"; }
latest_patch_for_series(){
  series="$1"
  ls -1 "scripts/installer-v${series}-"*.sh 2>/dev/null \
    | sed -n "s|^scripts/installer-v${series}-\([0-9][0-9][0-9]\)\.sh$|\1|p" \
    | sort -n | tail -n1
}
has_installer_for_version(){
  ver="$1"; s="$(series_from_version "$ver")"; p="$(pad3 "$(patch_from_version "$ver")")"
  [ -x "scripts/installer-v${s}-${p}.sh" ]
}
find_release_archive(){
  v="$1"; base="openwrt-ha-vrrp-${v}"
  for d in "$REPO_PATH" "$DOWNLOAD_REPO_PATH"; do
    [ -n "$d" ] || continue
    for ext in ".zip" ".tar.gz" ".tar"; do f="$d/${base}${ext}"; [ -f "$f" ] && { echo "$f"; return 0; }; done
  done
  return 1
}
