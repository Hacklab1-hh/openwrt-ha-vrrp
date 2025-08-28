#!/bin/sh
# readme.sh – Zeigt die README‑Teilfassung einer bestimmten Version an.
#
# Wird das Skript ohne Parameter aufgerufen, wird die aktuelle Version aus
# der Datei VERSION gelesen und die entsprechende Datei aus
# docs/readmes/ ausgegeben.  Wird ein Parameter übergeben, versucht das
# Skript, einen Versionsstring daraus zu extrahieren.  Unterstützt werden
# Tar‑ und Zip‑Dateien (openwrt‑ha‑vrrp‑<version>.tar.gz/.tar/.zip),
# IPK‑Pakete (ha‑vrrp_<version>-*.ipk) sowie direkte Versions‑ oder
# Commit‑Bezeichnungen.  Falls eine passende Readme gefunden wird,
# wird sie auf die Standardausgabe geschrieben.

set -eu

usage() {
  cat <<'USAGE'
Usage: readme.sh [<version|package|commit>]

  Ohne Argument gibt das Skript die README der aktuellen Version aus.
  Wird ein Argument übergeben, versucht das Skript, den Versionsstring
  daraus zu extrahieren und gibt die passende README aus docs/readmes/
  oder docs/readmeas/ aus.
USAGE
  exit 1
}

# Rootverzeichnis bestimmen
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

extract_version() {
  in="$1"
  case "$in" in
    *.tar.gz|*.tar|*.zip)
      # openwrt-ha-vrrp-<version>.tar.gz
      # extrahiere zwischen dem letzten '-' und der Extension
      b="$(basename "$in")"
      b="${b%.*}"    # remove extension (.gz/.tar/.zip)
      b="${b%.*}"    # remove second extension if gz
      v="${b#openwrt-ha-vrrp-}"
      echo "$v"
      ;;
    *.ipk)
      # ha-vrrp_<version>-*_* .ipk
      b="$(basename "$in")"
      b="${b%.*}"
      b="${b#ha-vrrp_}"
      v="${b%%-*}"
      echo "$v"
      ;;
    v*)
      # commit tags starting with v
      echo "${in#v}"
      ;;
    *)
      # assume direct version
      echo "$in"
      ;;
  esac
}

# Determine version
if [ "$#" -eq 0 ]; then
  [ -f "$ROOT/VERSION" ] || { echo "VERSION file not found" >&2; exit 1; }
  VER="$(tr -d '\r\n' < "$ROOT/VERSION")"
else
  VER="$(extract_version "$1")"
fi

# Try docs/readmes first, then docs/readmeas
FILE=""
if [ -f "$ROOT/docs/readmes/$VER.md" ]; then
  FILE="$ROOT/docs/readmes/$VER.md"
elif [ -f "$ROOT/docs/readmeas/$VER.md" ]; then
  FILE="$ROOT/docs/readmeas/$VER.md"
else
  echo "README for version '$VER' not found." >&2
  exit 1
fi

cat "$FILE"