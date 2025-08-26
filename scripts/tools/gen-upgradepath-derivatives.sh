#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HERE/./config/upgradepath.unified.json"
TXT="$HERE/upgradepath_unified.txt"
MD="$HERE/upgradepath_unified.md"
[ -r "$SRC" ] || { echo "[!] missing $SRC" >&2; exit 1; }
{
  echo "# Unified Upgrade Path (generated from ./config/upgradepath.unified.json)"
  awk '
    BEGIN{ ver=""; par=""; }
    /"version"[ \t]*:/ { gsub(/.*"version"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); ver=$0 }
    /"parent"[ \t]*:/  { if ($0 ~ /null/) par=""; else { gsub(/.*"parent"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); par=$0 } }
    /}[ \t]*,?[ \t]*$/ {
      if (ver!="") {
        if (par!="") print ver " <- " par; else print ver;
        ver=""; par="";
      }
    }
  ' "$SRC"
} > "$TXT"
{
  echo "# Upgrade Path (generated from ./config/upgradepath.unified.json)"
  echo
  echo "| Version | Parent | Patch | Released | Stability | Tags | Fixline |"
  echo "|---|---|---|---|---|---|---|"
  awk '
    function clean(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    /"version"[ \t]*:/   { gsub(/.*"version"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); ver=$0 }
    /"parent"[ \t]*:/    { if ($0 ~ /null/) par=""; else { gsub(/.*"parent"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); par=$0 } }
    /"patch_name"[ \t]*:/{ gsub(/.*"patch_name"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); patch=$0 }
    /"released"[ \t]*:/  { gsub(/.*"released"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); rel=$0 }
    /"stability"[ \t]*:/{ gsub(/.*"stability"[ \t]*:[ \t]*"/,""); gsub(/".*/,""); stab=$0 }
    /"tags"[ \t]*:/      { tags=""; tags_mode=1; next }
    tags_mode==1 {
      if ($0 ~ /\]/) { tags_mode=0; line=$0; sub(/^[^[]*\[/,"",line); sub(/\].*/,"",line); gsub(/"/,"",line); gsub(/,/, ", ", line); tags=line }
    }
    /"fixline"[ \t]*:/   { line=$0; sub(/.*"fixline"[ \t]*:[ \t]*"/,"",line); sub(/".*/,"",line); fix=line }
    /}[ \t]*,?[ \t]*$/ {
      if (ver!="") {
        printf("| `%s` | `%s` | `%s` | %s | %s | %s | %s |\n", ver, par, patch, rel, stab, tags, fix);
        ver=""; par=""; patch=""; rel=""; stab=""; tags=""; fix="";
      }
    }
  ' "$SRC"
} > "$MD"
echo "[✓] Written $TXT and $MD"
