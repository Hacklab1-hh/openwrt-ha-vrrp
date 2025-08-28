#!/bin/sh
# copy_downloads.sh – kopiert heruntergeladene VRRP‑Pakete in das lokale Workspace
#
# Dieses Skript sucht im Standard‑Downloadverzeichnis des Benutzers oder in
# einem optional übergebenen Verzeichnis nach Artefakten der Form
# "openwrt-ha-vrrp-*" (Tar‑, Zip‑Archiv) sowie nach IPK‑Paketen
# (ha‑vrrp_*-all.ipk).  Gefundene Dateien werden in den lokalen
# Workspace kopiert: Tar/Zips nach vrrp-repo, IPKs nach vrrp-ipk-repo.
# Der Workspace befindet sich in "${HOME}/_workspace".  Existierende
# Dateien werden überschrieben.

set -eu

usage() {
  echo "Usage: copy_downloads.sh [<download_dir>]" >&2
  echo "  Ohne Argument wird das Downloadverzeichnis anhand \$HOME bestimmt." >&2
  exit 1
}

# Optionales Argument: Pfad zum Download‑Verzeichnis
DOWNLOAD_DIR="${1:-}"
if [ -n "$DOWNLOAD_DIR" ]; then
  :
else
  # Fallback: HOME/Downloads
  if [ -n "${HOME:-}" ]; then
    DOWNLOAD_DIR="${HOME}/Downloads"
  else
    echo "[copy_downloads] HOME not set and no download dir specified." >&2
    exit 1
  fi
fi

# Normalize and ensure directory exists
DOWNLOAD_DIR="$(cd "$DOWNLOAD_DIR" 2>/dev/null || { echo "[copy_downloads] Directory not found: $DOWNLOAD_DIR" >&2; exit 1; } && pwd)"

WORKSPACE="${HOME}/_workspace"
REPO_DEST="${WORKSPACE}/vrrp-repo"
IPK_DEST="${WORKSPACE}/vrrp-ipk-repo"
mkdir -p "$REPO_DEST" "$IPK_DEST"

copy_files() {
  local src_dir="$1"
  # kopiere OpenWRT HA VRRP Pakete (tar, tar.gz, zip) nach repo
  for ext in tar.gz tar zip; do
    for f in "$src_dir"/openwrt-ha-vrrp-*.${ext}; do
      [ -f "$f" ] && cp -f "$f" "$REPO_DEST" || true
    done
  done
  # kopiere IPK Pakete nach ipk_repo
  for f in "$src_dir"/ha-vrrp_*.ipk; do
    [ -f "$f" ] && cp -f "$f" "$IPK_DEST" || true
  done
}

# Primäres Download‑Verzeichnis
copy_files "$DOWNLOAD_DIR"

# Falls ein Unterordner vrrp-repo existiert, dort ebenfalls suchen
if [ -d "$DOWNLOAD_DIR/vrrp-repo" ]; then
  copy_files "$DOWNLOAD_DIR/vrrp-repo"
fi

# Falls ein Unterordner vrrp-ipk-repo existiert, dort IPKs suchen
if [ -d "$DOWNLOAD_DIR/vrrp-ipk-repo" ]; then
  for f in "$DOWNLOAD_DIR/vrrp-ipk-repo"/ha-vrrp_*.ipk; do
    [ -f "$f" ] && cp -f "$f" "$IPK_DEST" || true
  done
fi

echo "[copy_downloads] Artefakte wurden nach $REPO_DEST und $IPK_DEST kopiert."