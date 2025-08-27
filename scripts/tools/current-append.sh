#!/usr/bin/env bash
set -euo pipefail
CURRENT_FILE="${CURRENT_FILE:-docs/releases/current/current.md}"

usage(){ cat <<'U'
Usage:
  current-append.sh [--file <path>] [--section <ui|api|scripts|docs|overview|known-issues>] \
                    [--bullet "<text>"] [--text "<paragraph>"] \
                    [--migrate-add "<shell code>" | --migrate-add - ] \
                    [--rollback-add "<shell code>" | --rollback-add - ]
U
}

file="$CURRENT_FILE"; section=""; bullet=""; text=""; migrate_add=""; rollback_add=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) file="$2"; shift 2;;
    --section) section="$2"; shift 2;;
    --bullet) bullet="$2"; shift 2;;
    --text) text="$2"; shift 2;;
    --migrate-add) migrate_add="$2"; shift 2;;
    --rollback-add) rollback_add="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "unknown arg: $1" >&2; usage; exit 1;;
  esac
done

ensure_file(){
  local f="$1"
  if [ ! -f "$f" ]; then
    mkdir -p "$(dirname "$f")"
    cat >"$f" <<'T'
# CURRENT (Arbeitsstand, unveröffentlicht)

## Overview
Kurzbeschreibung der aktuellen Arbeiten (1–3 Sätze).

## Changes
### ui
- feat: ...
- fix: ...

### api
- ...

### scripts
- ...

### docs
- ...

## Migration
```migrate-sh
#!/bin/sh
# optional migration steps for this iteration
```
```rollback-sh
#!/bin/sh
# optional rollback steps for this iteration
```
## Known Issues
- ...
T
  fi
}

ensure_heading(){ local f="$1" h="$2"; grep -qx "$h" "$f" || echo "$h" >>"$f"; }

append_bullet(){
  local f="$1" sub="$2" t="$3"
  ensure_file "$f"
  grep -qx "## Changes" "$f" || sed -i '1i ## Changes' "$f"
  grep -qx "### $sub" "$f" || printf "\n### %s\n" "$sub" >> "$f"
  printf -- "- %s\n" "$t" >> "$f"
}

append_text(){
  local f="$1" sec="$2" t="$3"
  ensure_file "$f"
  case "$sec" in
    overview) ensure_heading "$f" "## Overview" ;;
    known-issues) ensure_heading "$f" "## Known Issues" ;;
  esac
  printf "\n%s\n\n" "$t" >> "$f"
}

append_codeblock(){
  local f="$1" tag="$2" code="$3"
  ensure_file "$f"
  [ "$code" = "-" ] && code="$(cat)"
  if grep -q "^\`\`\`$tag" "$f"; then
    awk -v tag="$tag" -v code="$code" '
      BEGIN{inblk=0}
      /^\`\`\`/ { if(inblk){inblk=0; print; next} if($0=="```" tag){inblk=1; print; print code; next} }
      { print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  else
    grep -qx "## Migration" "$f" || printf "\n## Migration\n" >> "$f"
    { printf "```%s\n" "$tag"; printf "%s\n" "$code"; printf "```\n"; } >> "$f"
  fi
}

ensure_file "$file"
if [ -n "$bullet" ]; then
  case "$section" in ui|api|scripts|docs) append_bullet "$file" "$section" "$bullet" ;; *) echo "--bullet requires --section" >&2; exit 2;; esac
fi
if [ -n "$text" ]; then
  case "$section" in overview) append_text "$file" "overview" "$text" ;; known-issues) append_text "$file" "known-issues" "$text" ;; *) echo "--text requires --section overview|known-issues" >&2; exit 2;; esac
fi
[ -n "${migrate_add}" ] && append_codeblock "$file" "migrate-sh" "$migrate_add"
[ -n "${rollback_add}" ] && append_codeblock "$file" "rollback-sh" "$rollback_add"
echo "[current-append] updated $file"
