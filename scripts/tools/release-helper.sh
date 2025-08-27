#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

say(){ printf "[release] %s\n" "$*"; }
now(){ date +%Y-%m-%d; }

upd_line(){ # file prefix value
  local f="$1" p="$2" v="$3"; touch "$f"
  if grep -q "^${p}" "$f"; then sed -i "s|^${p}.*|${p}${v}|" "$f"; else { printf "%s%s\n\n" "$p" "$v"; cat "$f"; } >"$f.tmp" && mv "$f.tmp" "$f"; fi
}

extract_section(){ awk -v h="^## $2" 'BEGIN{f=0}$0~h{f=1;next} f&&/^## /{exit} f{print}' "$1"; }
extract_codeblock(){ awk -v tag="$2" 'BEGIN{b=0} /^```/{ if(b){b=0;next} if(index($0,tag)){b=1;next}} b{print}' "$1"; }

materialize(){
  local ver="$1" cur="docs/releases/current/current.md"
  [ -f "$cur" ] || { say "no current.md, creating empty"; mkdir -p docs/releases/current; echo "# CURRENT" >"$cur"; }
  mkdir -p "docs/releases/$ver" docs/changelogs

  local overview changes ui api known
  overview="$(extract_section "$cur" "Overview" || true)"
  changes="$(extract_section "$cur" "Changes" || true)"
  ui="$(extract_section "$cur" "ui" || true)"
  api="$(extract_section "$cur" "api" || true)"
  known="$(extract_section "$cur" "Known Issues" || true)"
  local mig_code rb_code
  mig_code="$(extract_codeblock "$cur" "migrate-sh" || true)"
  rb_code="$(extract_codeblock "$cur" "rollback-sh" || true)"

  # docs
  echo -e "# Release $ver\n\nCurrent Version: $ver\n\n## Overview\n${overview:-'(none)'}\n" > "docs/releases/$ver/README.md"
  { echo "# Features — $ver"; echo; [ -n "$ui$api" ] && { echo "$ui"; [ -n "$api" ] && { echo; echo "$api"; }; } || echo "(none)"; } > "docs/releases/$ver/FEATURES.md"
  { echo "# Known Issues — $ver"; echo; echo "${known:-'(none)'}"; } > "docs/releases/$ver/KNOWN-ISSUES.md"

  # changelog
  { echo "## Changelog — $ver"; echo; echo "$changes" | sed -n 's/^\s*-\s*/- /p'; } > "docs/changelogs/$ver.md"

  # migrate script (with rollback)
  mkdir -p scripts/migrate
  local mig="scripts/migrate/migrate-to-$ver.sh"
  {
    echo "#!/bin/sh"; echo "set -eu"; echo 'mode="${1:-migrate}"'; echo 'case "$mode" in'
    echo '  migrate)'; [ -n "$mig_code" ] && echo "$mig_code" || echo "    echo \"[migrate] nothing specific for $ver\""; echo "    ;;"
    echo '  rollback)'; [ -n "$rb_code" ] && echo "$rb_code" || echo "    echo \"[rollback] nothing specific for $ver\""; echo "    ;;"
    echo '  *) echo "usage: $0 [migrate|rollback]" >&2; exit 1;;'
    echo "esac"
  } > "$mig"; chmod +x "$mig"

  cp -f "$cur" "docs/releases/$ver/CURRENT_SNAPSHOT.md"
  # reset current.md
  cat > "$cur" <<'CUR'
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
CUR
  say "materialized current.md for $ver"
}

sync_central(){
  local ver="$1"
  upd_line "./README.md" "Current Version: " "$ver"
  upd_line "./CHANGELOG.md" "Current Version: " "$ver"
  upd_line "./ARCHITECTURE.md" "Current Version: " "$ver"
  upd_line "./CONCEPTS.md" "Current Version: " "$ver"
  upd_line "./docs/README.md" "Current Version: " "$ver"
  upd_line "./docs/CHANGELOG.md" "Current Version: " "$ver"
  upd_line "./docs/ARCHITECTURE.md" "Current Version: " "$ver"
  upd_line "./docs/CONCEPTS.md" "Current Version: " "$ver"
}

package_full(){
  local ver="$1" outdir="${2:-/tmp}"
  mkdir -p "$outdir"
  name="openwrt-ha-vrrp-$ver"
  tar -C "$(dirname "$PROJECT_ROOT")" -cf "$outdir/${name}_full.tar" "$(basename "$PROJECT_ROOT")"
  gzip -f "$outdir/${name}_full.tar"
  say "built $outdir/${name}_full.tar.gz"
}

cmd="${1:-}"; shift || true
NEXT=""; PREV=""; OUTDIR="/tmp"; NOGIT=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --next) NEXT="$2"; shift 2;;
    --prev) PREV="$2"; shift 2;;
    --outdir) OUTDIR="$2"; shift 2;;
    --no-git) NOGIT=1; shift;;
    *) shift;;
  esac
done
[ -n "$NEXT" ] || { echo "[release] --next required" >&2; exit 2; }

case "$cmd" in
  bump) echo "$NEXT" > VERSION; materialize "$NEXT"; sync_central "$NEXT" ;;
  package) package_full "$NEXT" "$OUTDIR" ;;
  all) echo "$NEXT" > VERSION; materialize "$NEXT"; sync_central "$NEXT"; package_full "$NEXT" "$OUTDIR" ;;
  *) echo "usage: release-helper.sh <bump|package|all> --next <VERSION> [--outdir <DIR>]" >&2; exit 1;;
esac
