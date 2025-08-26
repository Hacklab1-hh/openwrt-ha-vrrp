#!/bin/sh
# scripts/tools/upgradepath-migrate.sh
# Moves old update/upgrade path files to scripts/_old, consolidates into scripts/./config/upgradepath.unified.json,
# then generates scripts/upgradepath_unified.{txt,md} and adds compatibility symlinks.

set -eu
BASE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$BASE"
OLD="$SCRIPTS/_old"
mkdir -p "$OLD"

move_old() {
  for f in "$SCRIPTS"/*; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    case "$b" in
      upgradepath*|updatepath*|upgrade_path*)
        mv "$f" "$OLD/$b"
        ;;
    esac
  done
}

# Read from existing JSON or TXT under _old to build unified JSON
build_unified_json() {
  OUT="$SCRIPTS/./config/upgradepath.unified.json"
  JSON_SRC="$OLD/upgradepath_unified.json"
  TXT_SRC="$OLD/upgradepath_unified.txt"
  if [ -f "$JSON_SRC" ]; then
    cp "$JSON_SRC" "$OUT"
    return 0
  fi
  # Fallback: synthesize from TXT
  echo "[" > "$OUT"
  first=1
  if [ -f "$TXT_SRC" ]; then
    while IFS= read -r ln; do
      case "$ln" in \#*|"") continue;; esac
      child="$(echo "$ln" | awk -F'<-' '{gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1}')"
      parent="$(echo "$ln" | awk -F'<-' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')"
      [ -n "$child" ] || continue
      series="$(echo "$child" | awk -F. '{print $1 "." $2}')"
      [ $first -eq 1 ] || echo "," >> "$OUT"
      first=0
      printf '  {"version":"%s","parent":%s,"series":"%s","released":"","stability":"","tags":[],"summary":"","changes":{"file_moves":[],"uci_renames":[],"uci_defaults_set":[],"remove_paths":[],"breaking":false,"deprecations":[]},"rollback":{"file_moves":[],"uci_renames":[],"uci_unset":[]},"notes":""}\n' \
        "$child" "$( [ -n "$parent" ] && printf '"%s"' "$parent" || printf 'null')" "$series" >> "$OUT"
    done < "$TXT_SRC"
  fi
  echo "]" >> "$OUT"
}

gen_derivatives() {
  SRC="$SCRIPTS/./config/upgradepath.unified.json"
  TXT="$SCRIPTS/upgradepath_unified.txt"
  MD="$SCRIPTS/upgradepath_unified.md"
  # TXT
  echo "# Unified Upgrade Path (generated from ./config/upgradepath.unified.json)" > "$TXT"
  awk '
    BEGIN { print "" }
    /"version"/ { gsub(/.*"version":[ ]*"/,""); gsub(/".*/,""); ver=$0 }
    /"parent"/  { if ($0 ~ /null/) par=""; else { gsub(/.*"parent":[ ]*"/,""); gsub(/".*/,""); par=$0 } }
    /}/ {
      if (ver!="") {
        if (par!="") print ver " <- " par; else print ver;
        ver=""; par="";
      }
    }
  ' "$SRC" >> "$TXT"

  # MD
  {
    echo "# Upgrade Path (generated from ./config/upgradepath.unified.json)"
    echo
    echo "| Version | Parent | Released | Stability | Tags | Summary |"
    echo "|---|---|---|---|---|---|"
  } > "$MD"
  awk '
    /"version"/ { gsub(/.*"version":[ ]*"/,""); gsub(/".*/,""); ver=$0 }
    /"parent"/  { if ($0 ~ /null/) par=""; else { gsub(/.*"parent":[ ]*"/,""); gsub(/".*/,""); par=$0 } }
    /"released"/ { gsub(/.*"released":[ ]*"/,""); gsub(/".*/,""); rel=$0 }
    /"stability"/ { gsub(/.*"stability":[ ]*"/,""); gsub(/".*/,""); stab=$0 }
    /"tags"/ { tags=$0; gsub(/.*"tags":[ ]*\[/,"",tags); gsub(/\].*/,"",tags); gsub(/"/,"",tags) }
    /"summary"/ { gsub(/.*"summary":[ ]*"/,""); gsub(/".*/,""); sum=$0 }
    /}/ {
      if (ver!="") {
        printf("| `%s` | `%s` | %s | %s | %s | %s |\n", ver, par, rel, stab, tags, sum);
        ver=""; par=""; rel=""; stab=""; tags=""; sum="";
      }
    }
  ' "$SRC" >> "$MD"
}

make_symlinks() {
  cd "$SCRIPTS"
  ln -sf upgradepath_unified.txt updatepath.txt
  ln -sf upgradepath_unified.txt upgrade_path.txt
  ln -sf ./config/upgradepath.unified.json updatepath.json
  ln -sf ./config/upgradepath.unified.json upgrade_path.json
  ln -sf upgradepath_unified.md updatepath.md
  ln -sf upgradepath_unified.md upgrade_path.md
}

echo "[*] Moving old update/upgrade path files to scripts/_old …"
move_old
echo "[*] Building scripts/./config/upgradepath.unified.json …"
build_unified_json
echo "[*] Generating TXT/MD derivatives …"
gen_derivatives
echo "[*] Creating compatibility symlinks …"
make_symlinks
echo "[✓] Done."
