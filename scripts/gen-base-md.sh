#!/bin/sh
set -eu
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
if [ ! -d "$ROOT_DIR/docs" ]; then
  echo "docs/ not found under $ROOT_DIR" >&2
  exit 1
fi

aggregate_section() {
  sec="$1"    # e.g., changelog
  title="$2"  # e.g., CHANGELOG
  out_docs="$ROOT_DIR/docs/${sec}.md"
  out_root="$ROOT_DIR/${title}.md"
  dir="$ROOT_DIR/docs/$sec"

  # Collect files (*.md) ignoring the section main file itself
  files=$(find "$dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' 2>/dev/null | sort -V)
  # Build docs/<sec>.md (ascending → newest at bottom)
  {
    echo "# ${title} (Übersicht)"
    echo
    for f in $files; do
      echo "## ${f}"
      echo
      sed -e 's/\r$//' "$dir/$f"
      echo
    done
  } > "$out_docs"

  # Build root-level <TITLE>.md (descending → neuestes oben)
  files_desc=$(printf '%s\n' $files | tac)
  {
    echo "# ${title}"
    echo
    for f in $files_desc; do
      echo "## ${f}"
      echo
      sed -e 's/\r$//' "$dir/$f"
      echo
    done
  } > "$out_root"
  echo "Generated $out_docs and $out_root"
}

aggregate_section "changelog"   "CHANGELOG"
aggregate_section "features"    "FEATURES"
aggregate_section "architecture" "ARCHITECTURE"
aggregate_section "concepts"     "CONCEPTS"
