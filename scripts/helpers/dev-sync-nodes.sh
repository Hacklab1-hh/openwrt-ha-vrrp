#!/bin/sh
# dev-sync-nodes.sh – lädt die im Workspace liegenden Releases/IPKs auf Nodes hoch
#
# Dieses Skript synchronisiert die Dateien aus dem Entwicklungs‑Workspace
# auf definierte OpenWrt‑Router via scp.  Es können entweder beide
# Nodes (all) oder nur ein einzelner Node (1 oder 2) gewählt werden.
# Die Namen der Nodes müssen per SSH erreichbar sein (z. B.
# "LamoboR1-1" und "LamoboR1-2").

set -eu

usage() {
  echo "Usage: dev-sync-nodes.sh [--nodes all|1|2]" >&2
  exit 1
}

# Default‑Werte
NODES="all"

# Argumente parsen
while [ "$#" -gt 0 ]; do
  case "$1" in
    --nodes)
      NODES="$2"; shift 2;;
    --help|-h)
      usage;;
    *)
      echo "Unknown parameter: $1" >&2
      usage;;
  esac
done

# Bestimme Workspace
if [ -n "${USERPROFILE:-}" ]; then
  HOME_DIR="$USERPROFILE"
else
  HOME_DIR="$HOME"
fi
WORKSPACE="$HOME_DIR/_workspace"
REPO_DIR="$WORKSPACE/vrrp-repo"
IPK_DIR="$WORKSPACE/vrrp-ipk-repo"

# Node‑Namen definieren
NODE1="LamoboR1-1"
NODE2="LamoboR1-2"

# Hilfsfunktion für scp
sync_to_node() {
  target="$1"
  # Erstelle Zielordner auf dem Router
  if command -v ssh >/dev/null 2>&1; then
    ssh "root@$target" "mkdir -p /root/vrrp-repo /root/vrrp-ipk-repo" || true
  fi
  # Release‑Archive
  for f in "$REPO_DIR"/openwrt-ha-vrrp-*.*.*.tar.gz "$REPO_DIR"/openwrt-ha-vrrp-*.*.*.tar "$REPO_DIR"/openwrt-ha-vrrp-*.*.*.zip; do
    [ -f "$f" ] && scp "$f" "root@$target:/root/vrrp-repo/" || true
  done
  # IPK‑Pakete
  for f in "$IPK_DIR"/ha-vrrp_*_all.ipk; do
    [ -f "$f" ] && scp "$f" "root@$target:/root/vrrp-ipk-repo/" || true
  done
}

# Auswahl der Nodes
case "$NODES" in
  all)
    sync_to_node "$NODE1"
    sync_to_node "$NODE2"
    ;;
  1)
    sync_to_node "$NODE1"
    ;;
  2)
    sync_to_node "$NODE2"
    ;;
  *)
    echo "Unknown nodes option: $NODES" >&2
    usage;;
esac

echo "[dev-sync-nodes] Synchronisation abgeschlossen für Nodes: $NODES"