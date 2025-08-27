#!/usr/bin/env bash
set -euo pipefail
F="${1:-docs/releases/current/current.md}"
TITLE="${2:-Release Notes}"
VER="${3:-}"
[ -f "$F" ] || { echo "[release-notes] file not found: $F" >&2; exit 1; }
echo "$TITLE"
[ -n "$VER" ] && echo "" && echo "**Version:** $VER"
echo ""
awk '/^## Overview/{p=1;print;next} p && /^## / && NR>1{exit} p && NR>1{print}' "$F" | sed '/^## Overview$/d'
echo ""
echo "## Changes"
sed -n '/^## Changes/,/^## /p' "$F" | sed -n 's/^\s*-\s*/- /p'
echo ""
echo "## Migration"
awk '/^```migrate-sh/{b=1;next} b && /^```/{b=0;next} b{print}' "$F"
echo ""
echo "## Rollback"
awk '/^```rollback-sh/{b=1;next} b && /^```/{b=0;next} b{print}' "$F"
