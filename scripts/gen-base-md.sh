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

# Read aggregation modes from configuration
CONFIG_FILE="$ROOT_DIR/config/doc_aggregation.json"
get_mode() {
  # $1: section name
  sec="$1"
  # default mode is append
  if [ -f "$CONFIG_FILE" ]; then
    # Use python to read the JSON; fall back to append on error
    mode=$(python - "$CONFIG_FILE" "$sec" <<'PY'
import json, sys
try:
    cfg=json.load(open(sys.argv[1]))
    print(cfg.get(sys.argv[2], 'append'))
except Exception:
    print('append')
PY
    ) || mode="append"
  else
    mode="append"
  fi
  echo "$mode"
}

# Adjusted aggregate_section to honour extend/append modes
aggregate_section_with_mode() {
  sec="$1"
  title="$2"
  mode="$3"
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

  # Decide how to build root-level file based on mode.
  case "$mode" in
    append)
      # Append all versions (descending; newest at top)
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
      msg="Generated $out_docs and $out_root"
      ;;
    extend)
      # Use only the newest file as base (last in sorted list)
      last_file="$(printf '%s\n' $files | tail -n1)"
      if [ -n "$last_file" ]; then
        {
          echo "# ${title}"
          echo
          echo "## ${last_file}"
          echo
          sed -e 's/\r$//' "$dir/$last_file"
          echo
        } > "$out_root"
        msg="Generated $out_docs and updated $out_root with latest $last_file"
      else
        msg="Generated $out_docs (no files found for $sec)"
      fi
      ;;
    *)
      # default fallback: append behaviour
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
      msg="Generated $out_docs and $out_root"
      ;;
  esac
  # For README and KNOWN_ISSUES we do not overwrite the root-level file (extend makes no difference here)
  if [ "$title" = "README" ] || [ "$title" = "KNOWN_ISSUES" ]; then
    echo "Generated $out_docs (root-level ${title}.md unchanged)"
  else
    echo "$msg"
  fi
}

# Aggregate updated sections based on config modes.  The order matters: changelogs first, then features, architecture, concepts,
# readmes, and known issues.
for sec_title in \
  "changelogs CHANGELOG" \
  "features FEATURES" \
  "architecture ARCHITECTURE" \
  "concepts CONCEPTS" \
  "readmes README" \
  "known-issues KNOWN_ISSUES"
do
  sec=$(echo "$sec_title" | awk '{print $1}')
  title=$(echo "$sec_title" | awk '{print $2}')
  mode=$(get_mode "$sec")
  aggregate_section_with_mode "$sec" "$title" "$mode"
done
