#!/bin/sh
# upgrade-path.sh – print upgrade path steps FROM → TO using scripts/upgradepath_unified.txt
# Usage: sh scripts/upgrade-path.sh 0.5.9 0.5.16-007
set -eu
FROM="${1:-}"
TO="${2:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/upgradepath.sh"

[ -n "$FROM" ] && [ -n "$TO" ] || { echo "Usage: $0 FROM TO" >&2; exit 1; }

CHAIN="$(build_chain "$FROM" "$TO" || true)"
[ -n "$CHAIN" ] || { echo "No path between $FROM and $TO (check scripts/upgradepath_unified.txt)"; exit 2; }

for v in $CHAIN; do
  echo "$v"
done
