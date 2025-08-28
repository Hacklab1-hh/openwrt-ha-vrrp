#!/bin/sh
# dev-harvest.sh – sammelt heruntergeladene Releases und IPK‑Pakete
#
# Dieses Skript durchsucht den Download‑Ordner des Benutzers (sowie ein
# optionales Unterverzeichnis "vrrp-repo") nach heruntergeladenen
# Release‑Archiven (openwrt-ha-vrrp-*.tar.gz/.tar/.zip) und IPK‑Paketen
# (ha-vrrp_*_all.ipk) und kopiert sie in die Entwicklungs‑Workspace‑
# Verzeichnisse.  Der Workspace liegt standardmäßig unter
# <Benutzer>/\_workspace, analog zum presets.json.  Unter Linux wird
# $HOME verwendet, unter Windows $USERPROFILE.

set -eu

# Bestimme das Home‑Verzeichnis und damit den Download‑Ordner
if [ -n "${USERPROFILE:-}" ]; then
  # Windows
  HOME_DIR="$USERPROFILE"
  DOWNLOAD_DIR="$USERPROFILE/Downloads"
else
  HOME_DIR="$HOME"
  DOWNLOAD_DIR="$HOME/Downloads"
fi

# Bestimme das Workspace‑Verzeichnis
WORKSPACE="$HOME_DIR/_workspace"
REPO_DIR="$WORKSPACE/vrrp-repo"
IPK_DIR="$WORKSPACE/vrrp-ipk-repo"

# Erstelle die Zielverzeichnisse, falls nicht vorhanden
mkdir -p "$REPO_DIR" "$IPK_DIR"

# Sammle Dateien aus den Download‑Quellen
copy_files() {
  src_dir="$1"
  [ -d "$src_dir" ] || return 0
  # Release‑Archive kopieren
  for f in "$src_dir"/openwrt-ha-vrrp-*.*.*.tar.gz "$src_dir"/openwrt-ha-vrrp-*.*.*.tar "$src_dir"/openwrt-ha-vrrp-*.*.*.zip; do
    [ -f "$f" ] && cp -f "$f" "$REPO_DIR/"
  done
  # IPK‑Pakete kopieren
  for f in "$src_dir"/ha-vrrp_*_all.ipk; do
    [ -f "$f" ] && cp -f "$f" "$IPK_DIR/"
  done
}

# Standard‑Download‑Ordner und optionales Unterverzeichnis vrrp-repo durchsuchen
copy_files "$DOWNLOAD_DIR"
copy_files "$DOWNLOAD_DIR/vrrp-repo"

echo "[dev-harvest] Dateien in $REPO_DIR und $IPK_DIR aktualisiert."