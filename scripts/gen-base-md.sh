#!/bin/sh
set -eu
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
if [ ! -d "$ROOT_DIR/docs" ]; then
  echo "docs/ not found under $ROOT_DIR" >&2
  exit 1
fi

# In newer releases, versioned documents live under pluralised directories (e.g. changelogs, readmes,
# known-issues) and filenames no longer carry prefixes such as CHANGELOG_, README_, etc.  The
# aggregation function below filters out these legacy prefixes when constructing the overview.

aggregate_section() {
  sec="$1"    # e.g., changelogs
  title="$2"  # e.g., CHANGELOG
  out_docs="$ROOT_DIR/docs/${sec}.md"
  out_root="$ROOT_DIR/${title}.md"
  dir="$ROOT_DIR/docs/$sec"

  # Determine exclude glob based on section
  exclude_glob=""
  case "$sec" in
    changelogs)    exclude_glob='CHANGELOG_*' ;;
    features)      exclude_glob='FEATURES_*' ;;
    readmes)       exclude_glob='README_*' ;;
    known-issues)  exclude_glob='KNOWN_ISSUES_*' ;;
    *)             exclude_glob='' ;;
  esac

  # Collect files (*.md) ignoring the section main file itself and excluded patterns
  if [ -n "$exclude_glob" ]; then
    files=$(find "$dir" -maxdepth 1 -type f -name '*.md' ! -name "$exclude_glob" -printf '%f\n' 2>/dev/null | sort -V)
  else
    files=$(find "$dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' 2>/dev/null | sort -V)
  fi
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

  # Build root-level <TITLE>.md (descending → neuestes oben), unless this section is readmes or known-issues.
  # For README and KNOWN_ISSUES we only generate the docs-level overview to avoid overwriting the manual root README.
  if [ "$title" != "README" ] && [ "$title" != "KNOWN_ISSUES" ]; then
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
  else
    echo "Generated $out_docs (root-level ${title}.md unchanged)"
  fi
}

# Aggregate updated sections.  The order matters: changelogs first, then features, architecture, concepts,
# readmes, and known issues.
aggregate_section "changelogs"   "CHANGELOG"
aggregate_section "features"    "FEATURES"
aggregate_section "architecture" "ARCHITECTURE"
aggregate_section "concepts"     "CONCEPTS"
aggregate_section "readmes"     "README"
aggregate_section "known-issues" "KNOWN_ISSUES"
