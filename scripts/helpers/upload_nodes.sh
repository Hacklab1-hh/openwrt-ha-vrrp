#!/bin/sh
# upload_nodes.sh – überträgt Pakete auf entfernte Knoten via scp
#
# Dieses Skript lädt alle Archive im lokalen Workspace (vrrp-repo und
# vrrp-ipk-repo) zu den angegebenen Zielknoten hoch.  Die Knoten
# sollten per SSH erreichbar sein (z. B. als Hostname oder IP).  Vor
# dem Kopieren werden auf dem Ziel die Verzeichnisse /root/vrrp-repo und
# /root/vrrp-ipk-repo angelegt.  Anschließend werden alle Dateien aus
# dem lokalen vrrp-repo nach /root/vrrp-repo und alle IPK‑Pakete aus
# vrrp-ipk-repo nach /root/vrrp-ipk-repo kopiert.

set -eu

usage() {
  echo "Usage: upload_nodes.sh <node1> [<node2> ...]" >&2
  echo "  Überträgt Pakete aus dem lokalen _workspace auf die angegebenen Nodes." >&2
  exit 1
}

[ "$#" -ge 1 ] || usage

WORKSPACE="${HOME}/_workspace"
REPO_SRC="${WORKSPACE}/vrrp-repo"
IPK_SRC="${WORKSPACE}/vrrp-ipk-repo"

# Prüfen, ob Quellverzeichnisse existieren
if [ ! -d "$REPO_SRC" ]; then
  echo "[upload_nodes] Source repo directory not found: $REPO_SRC" >&2
  exit 1
fi
if [ ! -d "$IPK_SRC" ]; then
  echo "[upload_nodes] Source ipk directory not found: $IPK_SRC" >&2
  exit 1
fi

for NODE in "$@"; do
  echo "[upload_nodes] Verbinde zu $NODE..."
  # Zielverzeichnisse anlegen
  ssh "$NODE" "mkdir -p /root/vrrp-repo /root/vrrp-ipk-repo" || {
    echo "[upload_nodes] Fehler beim Anlegen der Verzeichnisse auf $NODE" >&2
    continue
  }
  # Dateien kopieren
  scp -q "$REPO_SRC"/* "$NODE":/root/vrrp-repo/ || {
    echo "[upload_nodes] Fehler beim Kopieren der Repo-Dateien nach $NODE" >&2
  }
  scp -q "$IPK_SRC"/* "$NODE":/root/vrrp-ipk-repo/ || {
    echo "[upload_nodes] Fehler beim Kopieren der IPK-Dateien nach $NODE" >&2
  }
  echo "[upload_nodes] Dateien erfolgreich an $NODE übertragen."
done