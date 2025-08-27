#!/usr/bin/env bash
# scripts/tools/release-helper.sh — featurefix3
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

say(){ printf "[release] %s\n" "$*"; }
die(){ printf "[release][error] %s\n" "$*" >&2; exit 1; }
usage(){
cat <<'USAGE'
Usage:
  release-helper.sh bump --next <VERSION> [--prev <VERSION>] [--no-git]
  release-helper.sh package --next <VERSION> [--outdir <DIR>]
  release-helper.sh all --next <VERSION> [--prev <VERSION>] [--outdir <DIR>] [--no-git]
USAGE
}

has_git(){ command -v git >/dev/null 2>&1; }
now(){ date +%Y-%m-%d; }

upd_line(){
  local f="$1" pfx="$2" val="$3"
  touch "$f"
  if grep -q "^${pfx}" "$f"; then
    sed -i "s|^${pfx}.*|${pfx}${val}|" "$f"
  else
    tmp="$(mktemp)"; printf "%s%s\n\n" "$pfx" "$val" >"$tmp"; cat "$f" >>"$tmp"; mv "$tmp" "$f"
  fi
}

append_chg(){
  local f="$1" ver="$2" d="$3" sum="$4" bullets="${5:-}"
  touch "$f"
  {
    printf "\n## %s — %s\n" "$ver" "$d"
    printf "%s\n" "$sum"
    [ -n "$bullets" ] && printf "%s\n" "$bullets"
  } >>"$f"
}

sync_central(){
  local ver="$1"
  upd_line "./README.md"           "Current Version: " "$ver"
  upd_line "./CHANGELOG.md"        "Current Version: " "$ver"
  upd_line "./ARCHITECTURE.md"     "Current Version: " "$ver"
  upd_line "./CONCEPTS.md"         "Current Version: " "$ver"
  upd_line "./docs/README.md"      "Current Version: " "$ver"
  upd_line "./docs/CHANGELOG.md"   "Current Version: " "$ver"
  upd_line "./docs/ARCHITECTURE.md" "Current Version: " "$ver"
  upd_line "./docs/CONCEPTS.md"     "Current Version: " "$ver"
}

# --- current.md materialization ---
extract_section(){ # $1 file, $2 heading (e.g. "Changes")
  awk -v h="^## $2" '
    BEGIN{found=0}
    $0 ~ h {found=1; next}
    found && /^## / {exit}
    found {print}
  ' "$1"
}

extract_codeblock(){ # $1 file, $2 fence tag (e.g. migrate-sh)
  awk -v tag="$2" '
    BEGIN{inblk=0}
    $0 ~ /^```/ {
      if(inblk){ inblk=0; next }
      if(index($0, tag)){ inblk=1; next }
    }
    inblk {print}
  ' "$1"
}

materialize_current(){
  local ver="$1" cur="docs/releases/current/current.md"
  [ -f "$cur" ] || { say "no current.md found; skipping materialization"; return 0; }
  local outdir="docs/releases/${ver}"; mkdir -p "$outdir" docs/changelogs

  # sections
  local overview changes docs_sec migrate_sec known features ui api scripts
  overview="$(extract_section "$cur" "Overview" || true)"
  changes="$(extract_section "$cur" "Changes" || true)"
  docs_sec="$(extract_section "$cur" "docs" || true)"
  ui="$(extract_section "$cur" "ui" || true)"
  api="$(extract_section "$cur" "api" || true)"
  scripts="$(extract_section "$cur" "scripts" || true)"
  migrate_sec="$(extract_section "$cur" "Migration" || true)"
  known="$(extract_section "$cur" "Known Issues" || true)"
  features="$(printf "%s\n%s\n" "$ui" "$api")"

  # write README.md (overview + pointer)
  {
    printf "# Release %s\n\n" "$ver"
    printf "Current Version: %s\n\n" "$ver"
    printf "## Overview\n%s\n" "${overview:-(none)}"
  } > "${outdir}/README.md"

  # write FEATURES.md
  {
    printf "# Features — %s\n\n" "$ver"
    printf "%s\n" "${features:-(none)}"
  } > "${outdir}/FEATURES.md"

  # write KNOWN-ISSUES.md
  {
    printf "# Known Issues — %s\n\n" "$ver"
    printf "%s\n" "${known:-(none)}"
  } > "${outdir}/KNOWN-ISSUES.md"

  # changelog bullets: gather all list items under Changes
  chgfile="docs/changelogs/${ver}.md"
  {
    printf "## Changelog — %s\n\n" "$ver"
    if [ -n "$changes" ]; then
      echo "$changes" | sed -n 's/^\s*-\s*/- /p'
    else
      echo "- maintenance: release ${ver}"
    fi
  } > "$chgfile"

  # migration script: prefer fenced block
  mig_code="$(extract_codeblock "$cur" "migrate-sh" || true)"
  mkdir -p "scripts/migrate"
  mig="scripts/migrate/migrate-to-${ver}.sh"
  if [ -n "$mig_code" ]; then
    printf "%s\n" "$mig_code" > "$mig"
  else
    cat >"$mig" <<EOF
#!/bin/sh
set -eu
echo "[migrate] nothing specific for ${ver}"
EOF
  fi
  chmod +x "$mig"

  # snapshot current.md
  cp -f "$cur" "${outdir}/CURRENT_SNAPSHOT.md"

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
## Known Issues
- ...
CUR
  say "materialized current.md into releases/${ver}/ and changelogs/"
}

# old cleanups: remove stray versioned scripts in scripts/
clean_scripts_root(){
  shopt -s nullglob
  pushd scripts >/dev/null || return 0
  for f in *; do
    [[ -f "$f" ]] || continue
    if [[ "$f" =~ ^(gen|migrate|installer|uninstaller)[-_].*\.(sh|bash)$ ]]; then
      say "rm scripts/$f"; rm -f "$f"
    fi
  done
  popd >/dev/null || true
  shopt -u nullglob
}

create_installers(){
  local ver="$1"
  mkdir -p scripts/installer scripts/uninstaller scripts/tools
  cat >"scripts/installer/installer-v${ver}.sh" <<INS
#!/bin/sh
set -eu
HERE="\$(cd "\$(dirname "\$0")" && pwd)"
. "\$HERE/../tools/common.sh"
VERSION="${ver}"
DESTROOT="\${DESTROOT:-/}"
rd="\$(detect_root)"
log "Installing version \$VERSION into \$DESTROOT"
[ -d "\$rd/files" ] && SRC="\$rd/files" || SRC="\$rd"
cp -a "\$SRC"/. "\$DESTROOT"/
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Install \$VERSION complete."
INS
  chmod +x "scripts/installer/installer-v${ver}.sh"

  cat >"scripts/uninstaller/uninstaller-v${ver}.sh" <<UN
#!/bin/sh
set -eu
HERE="\$(cd "\$(dirname "\$0")" && pwd)"
. "\$HERE/../tools/common.sh"
DESTROOT="\${DESTROOT:-/}"
log "Uninstalling version ${ver} from \$DESTROOT"
# UI + API files (best-effort)
rm -f "\$DESTROOT/usr/lib/lua/luci/controller/ha_vrrp.lua" \
      "\$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/general.lua" \
      "\$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/peers.lua" \
      "\$DESTROOT/usr/lib/lua/luci/model/cbi/ha_vrrp/segment.lua" \
      "\$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/overview.htm" \
      "\$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/status.htm" \
      "\$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/logs.htm" \
      "\$DESTROOT/usr/lib/lua/luci/view/ha_vrrp/discover.htm" \
      "\$DESTROOT/usr/sbin/ha-vrrp-api" 2>/dev/null || true
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
log "Uninstall complete."
UN
  chmod +x "scripts/uninstaller/uninstaller-v${ver}.sh"
}

pkg_full(){
  local ver="$1" outdir="${2:-/tmp}"
  local name="openwrt-ha-vrrp-${ver}"
  mkdir -p "$outdir"
  tar -C "$(dirname "$PROJECT_ROOT")" -cf "${outdir}/${name}_full.tar" "$(basename "$PROJECT_ROOT")"
  gzip -c "${outdir}/${name}_full.tar" > "${outdir}/${name}_full.tar.gz"
  say "built ${outdir}/${name}_full.tar.gz"
}

cmd="${1:-}"; shift || true
NEXT=""; PREV=""; OUTDIR="/tmp"; NOGIT=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --next) NEXT="$2"; shift 2;;
    --prev) PREV="$2"; shift 2;;
    --outdir) OUTDIR="$2"; shift 2;;
    --no-git) NOGIT=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown arg: $1";;
  esac
done

[[ -z "${NEXT}" ]] && { usage; die "--next <VERSION> is required"; }

case "$cmd" in
  bump)
    echo "${NEXT}" > VERSION
    materialize_current "${NEXT}"
    sync_central "${NEXT}"
    clean_scripts_root
    create_installers "${NEXT}"
    # Append brief entry
    append_chg "docs/CHANGELOG.md" "${NEXT}" "$(now)" "- Maintenance: version bump & current.md materialized."
    if [[ $NOGIT -eq 0 ]] && has_git; then
      git add -A
      git commit -m "chore(release): bump to ${NEXT}" || true
      say "suggest tag: v${NEXT}"
    fi
    ;;
  package)
    pkg_full "${NEXT}" "${OUTDIR}"
    ;;
  all)
    "$0" bump --next "${NEXT}" ${PREV:+--prev "$PREV"} ${NOGIT:+--no-git}
    "$0" package --next "${NEXT}" --outdir "${OUTDIR}"
    ;;
  *)
    usage; die "unknown command: ${cmd}"
    ;;
esac
