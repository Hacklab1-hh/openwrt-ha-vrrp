#!/bin/sh
# upgrade-path.sh – print upgrade path steps FROM → TO using docs/UPDATE_PATH.csv
# Usage: sh scripts/upgrade-path.sh 0.3.0 0.5.4
set -eu
FROM="${1:-}"
TO="${2:-}"
CSV="$(dirname "$0")/../docs/UPDATE_PATH.csv"
[ -n "$FROM" ] && [ -n "$TO" ] || { echo "Usage: $0 FROM TO" >&2; exit 1; }
[ -f "$CSV" ] || { echo "Missing $CSV" >&2; exit 1; }

# Find indices
IFROM="$(awk -F, -v v="$FROM" 'NR>1 && $2==v {print $1}' "$CSV")"
ITO="$(awk -F, -v v="$TO"   'NR>1 && $2==v {print $1}' "$CSV")"
[ -n "$IFROM" ] && [ -n "$ITO" ] || { echo "Unknown version(s): FROM=$FROM TO=$TO" >&2; exit 2; }

# Ascending or descending
if [ "$IFROM" -le "$ITO" ]; then
  awk -F, -v a="$IFROM" -v b="$ITO" 'NR>1 && $1>=a && $1<=b {print $2}' "$CSV"
else
  # downgrade path (reverse)
  awk -F, -v a="$ITO" -v b="$IFROM" 'NR>1 && $1>=a && $1<=b {print $2}' "$CSV" | tac
fi
