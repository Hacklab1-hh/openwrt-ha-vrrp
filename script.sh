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
  *)
    echo "Unknown command: $cmd" >&2
    echo "Available commands: manage_docs, readme, help" >&2
    exit 1
    ;;
esac