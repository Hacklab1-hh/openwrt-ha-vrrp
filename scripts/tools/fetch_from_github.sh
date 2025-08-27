#!/bin/sh
# Fetches a package tarball from GitHub and extracts it to DESTDIR.
# Env:
#   GITHUB_REPO : owner/repo (default: Hacklab1-hh/openwrt-ha-vrrp)
#   SRC_REF     : tag/branch/commit (default: main or VERSION if provided)
#   VERSION     : version string used to choose SRC_REF if set
#   DESTDIR     : extraction destination (required)
#   CURL_OPTS   : extra curl options (optional)
#   WGET_OPTS   : extra wget options (optional)

set -eu
. "$(dirname -- "$0")/common.sh"

REPO="${GITHUB_REPO:-Hacklab1-hh/openwrt-ha-vrrp}"
REF="${SRC_REF:-}"
VER="${VERSION:-}"
DEST="${DESTDIR:-}"
[ -n "$DEST" ] || die "DESTDIR is required"

if [ -z "$REF" ] && [ -n "$VER" ]; then
  REF="$VER"
fi
[ -n "$REF" ] || REF="main"

mkdir -p "$DEST"

URL_TAG="https://codeload.github.com/${REPO}/tar.gz/refs/tags/${REF}"
URL_HEAD="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${REF}"

download_and_extract() {
  local url="$1"
  local tmp tgz top
  tmp="$(mktemp -d)"
  tgz="$tmp/pkg.tgz"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL ${CURL_OPTS:-} -o "$tgz" "$url" || return 1
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tgz" ${WGET_OPTS:-} "$url" || return 1
  else
    die "Neither curl nor wget available"
  fi
  tar -xzf "$tgz" -C "$tmp"
  top="$(find "$tmp" -maxdepth 1 -type d -name '*openwrt-ha-vrrp*' ! -path "$tmp" | head -n1 || true)"
  [ -n "$top" ] || die "Could not find extracted package root"
  cp -a "$top"/. "$DEST"/
  rm -rf "$tmp"
}

log "Fetching from GitHub repo=$REPO ref=$REF into $DEST"
if ! download_and_extract "$URL_TAG"; then
  warn "Tag not found, trying branch"
  download_and_extract "$URL_HEAD"
fi
log "Fetch complete"
