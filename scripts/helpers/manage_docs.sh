#!/bin/sh
# manage_docs.sh – zentraler Manager zum Hinzufügen von Einträgen zu versionsspezifischen Dokumenten
#
# Dieses Skript ermöglicht es, schnell Notizen oder Änderungen in die
# Markdown‑Dateien der aktuellen Version einzutragen.  Optional kann
# gleichzeitig ein neuer Versions‑Tag gesetzt werden.  In diesem Fall
# werden die bestehenden Teilfassungen kopiert, die VERSION‑Datei wird
# aktualisiert und die bestehenden Helper‑Skripte zur Synchronisation
# werden aufgerufen.  Es ist so gestaltet, dass es sowohl unter
# BusyBox/OpenWrt als auch unter einem regulären Linux‑System läuft.

set -eu

# Hilfsfunktion für die Usage‑Ausgabe
usage() {
  cat <<'USAGE'
Usage: manage_docs.sh --type <section> --entry "Text" [--new-version <version>]

  --type        Abschnitt, der bearbeitet werden soll.  Zulässige Werte:
                changelog, changelogs, features, architecture, concepts,
                readme, readmes, known-issues
  --entry       Der Text, der ans Ende der entsprechenden Datei angehängt wird.
  --new-version Optional: neuer Versionsstring.  Bei Angabe wird die
                aktuelle Version fortgeschrieben, bestehende Dateien werden
                kopiert und die zentralen Dokumente aktualisiert.
USAGE
  exit 1
}

# Parameter einlesen
TYPE=""
ENTRY=""
NEW_VERSION=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --type)       TYPE="$2"; shift 2;;
    --entry)      ENTRY="$2"; shift 2;;
    --new-version) NEW_VERSION="$2"; shift 2;;
    --help|-h)    usage;;
    *)
      echo "Unknown parameter: $1" >&2
      usage;;
  esac
done

# Parameter validieren
[ -n "$TYPE" ] && [ -n "$ENTRY" ] || usage

# Root‑Verzeichnis ermitteln
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VER_FILE="$ROOT/VERSION"
[ -f "$VER_FILE" ] || { echo "[manage_docs] VERSION file not found" >&2; exit 1; }
CUR_VER="$(tr -d '\r\n' < "$VER_FILE")"

# Abschnitt zu Verzeichnis zuordnen
case "$TYPE" in
  changelog|changelogs) DIR="$ROOT/docs/changelogs";;
  features)             DIR="$ROOT/docs/features";;
  architecture)         DIR="$ROOT/docs/architecture";;
  concepts)             DIR="$ROOT/docs/concepts";;
  readme|readmes)       DIR="$ROOT/docs/readmes";;
  known-issues)         DIR="$ROOT/docs/known-issues";;
  *)
    echo "[manage_docs] Unknown type '$TYPE'" >&2
    exit 1;;
esac

mkdir -p "$DIR"
TARGET_FILE="$DIR/$CUR_VER.md"

# Datei initialisieren, falls nicht vorhanden
if [ ! -f "$TARGET_FILE" ]; then
  echo "# $CUR_VER" > "$TARGET_FILE"
fi

# Eintrag anhängen
printf '%s\n\n' "$ENTRY" >> "$TARGET_FILE"
echo "[manage_docs] Added entry to $(echo "$TARGET_FILE" | sed "s|$ROOT/||")"

# Falls eine neue Version angegeben ist: Kopieren von Teilfassungen und Versionsbump
if [ -n "$NEW_VERSION" ]; then
  PREV_VER="$CUR_VER"
  # Liste der Verzeichnisse, die kopiert werden sollen
  for SECTION in changelogs features architecture concepts readmes known-issues; do
    SRC="$ROOT/docs/$SECTION/$PREV_VER.md"
    DST="$ROOT/docs/$SECTION/$NEW_VERSION.md"
    if [ -f "$SRC" ]; then
      mkdir -p "$ROOT/docs/$SECTION"
      cp "$SRC" "$DST"
    fi
  done
  # VERSION aktualisieren
  echo "$NEW_VERSION" > "$VER_FILE"
  echo "[manage_docs] VERSION updated to $NEW_VERSION"
  # Helper-Skripte ausführen
  sh "$ROOT/scripts/helpers/helper_update_version_tags.sh"
  sh "$ROOT/scripts/helpers/helper_sync_docs.sh"
  echo "[manage_docs] Finalised new version $NEW_VERSION"
fi