#!/bin/sh
# script.sh – einfacher Wrapper für die wichtigsten Helfer
#
# Dieses Skript stellt eine einheitliche CLI für diverse Helfer
# bereit.  Der erste Parameter bestimmt das aufgerufene Unterkommando.
# Der Rest der Parameter wird an das entsprechende Skript weitergereicht.
#
# Beispiele:
#   ./script.sh manage_docs --type readme --entry "Dies ist ein Test" --new-version 0.5.16-007
#   ./script.sh readme 0.5.16-007_reviewfix17_a4_fix2
#   ./script.sh help

cmd="$1"
shift || true
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Prüfe auf neue Wrapper‑Parameter
if [ "$cmd" = "--type" ]; then
  TYPE="$1"; shift || true
  ACTION=""
  NODES="all"
  # weitere Argumente analysieren
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --action)
        ACTION="$2"; shift 2;;
      --nodes)
        NODES="$2"; shift 2;;
      *)
        break;;
    esac
  done
  case "$TYPE" in
    dev-harvest)
      if [ "$ACTION" = "run" ] || [ -z "$ACTION" ]; then
        exec sh "$ROOT/scripts/helpers/dev-harvest.sh" "$@"
      else
        echo "Unknown action for dev-harvest: $ACTION" >&2
        exit 1
      fi
      ;;
    dev-sync-nodes)
      if [ "$ACTION" = "run" ] || [ -z "$ACTION" ]; then
        exec sh "$ROOT/scripts/helpers/dev-sync-nodes.sh" --nodes "$NODES" "$@"
      else
        echo "Unknown action for dev-sync-nodes: $ACTION" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unknown type: $TYPE" >&2
      exit 1
      ;;
  esac
fi

case "$cmd" in
  manage_docs)
    # rufe manage_docs über sh auf, um fehlende Ausführungsrechte zu umgehen
    exec sh "$ROOT/scripts/helpers/manage_docs.sh" "$@"
    ;;
  readme)
    # readme.sh mit sh aufrufen
    exec sh "$ROOT/scripts/readme.sh" "$@"
    ;;
  help)
    # help.sh mit sh aufrufen
    exec sh "$ROOT/scripts/help.sh" "$@"
    ;;
  copy_downloads)
    # Alias für dev-harvest: Dateien sammeln
    exec sh "$ROOT/scripts/helpers/dev-harvest.sh" "$@"
    ;;
  upload_nodes)
    # Alias für dev-sync-nodes: Dateien auf Router hochladen
    exec sh "$ROOT/scripts/helpers/dev-sync-nodes.sh" "$@"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    echo "Available commands: manage_docs, readme, help, copy_downloads, upload_nodes" >&2
    exit 1
    ;;
esac