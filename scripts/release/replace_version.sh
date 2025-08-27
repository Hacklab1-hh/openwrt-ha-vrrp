#!/usr/bin/env bash
# scripts/release/replace_version.sh
# Usage (from repo root, in Git Bash):
#   bash scripts/release/replace_version.sh "0.5.16-007_reviewfix16_featurefix15" "0.5.16-007_reviewfix16_featurefix5"
# Notes:
# - Replaces in file CONTENTS (with awk): OLD_fix1 -> NEW, then OLD -> NEW
# - Renames FILES/PATHS (with git mv):   OLD_fix1 -> NEW, then OLD -> NEW
# - Updates VERSION file to NEW.
# - Stages all touched files; you still have to 'git commit ...' yourself.
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "git not found" >&2; exit 1
fi
if ! command -v awk >/dev/null 2>&1; then
  echo "awk not found (install Git Bash / gawk)" >&2; exit 1
fi

OLD="${1:-}"
NEW="${2:-}"

if [[ -z "${OLD}" || -z "${NEW}" ]]; then
  echo "Usage: $0 <OLD> <NEW>" >&2
  exit 2
fi

# Sanity: must be in a git repo
git rev-parse --show-toplevel >/dev/null

echo "== Replace in contents: '${OLD}_fix1' -> '${NEW}', then '${OLD}' -> '${NEW}'"
# List text files that contain the OLD marker (git grep excludes binary with -I)
mapfile -d '' FILES < <(git grep -Ilz -- "${OLD}")
for f in "${FILES[@]}"; do
  # Use awk to do both substitutions
  tmp="${f}.tmp.$$"
  awk -v old="${OLD}" -v newv="${NEW}" '{ gsub(old "_fix1", newv); gsub(old, newv); print }' "${f}" > "${tmp}"
  if ! cmp -s "${f}" "${tmp}"; then
    mv "${tmp}" "${f}"
    git add "${f}"
    echo "  updated: ${f}"
  else
    rm -f "${tmp}"
  fi
done

echo "== Rename files/paths where needed (git mv)"
# Escape OLD for sed regex
OLD_ESC="$(printf '%s' "${OLD}" | sed -e 's/[.[\*^$\/\\]/\\&/g')"

# Go through tracked files to compute new paths
# (We process files only; parent dirs will be created automatically by git mv)
while IFS= read -r -d '' f; do
  newpath="$(printf '%s' "${f}" | sed -e "s/${OLD_ESC}_fix1/${NEW}/g" -e "s/${OLD_ESC}/${NEW}/g")"
  if [[ "${newpath}" != "${f}" ]]; then
    # Ensure parent exists; git mv will create missing parents, but mkdir -p is harmless
    mkdir -p "$(dirname "${newpath}")" 2>/dev/null || true
    git mv -k -- "${f}" "${newpath}" || true
    echo "  renamed: ${f} -> ${newpath}"
  fi
done < <(git ls-files -z)

echo "== Update VERSION file"
printf '%s\n' "${NEW}" > VERSION
git add VERSION
echo "  VERSION := ${NEW}"

echo "== Done. Next steps:"
echo "   git status -sb"
echo "   git commit -m \"${NEW}: normalize version strings and paths (drop _fix1)\""
echo "   git push   # or: git push --force-with-lease (if amending)"
