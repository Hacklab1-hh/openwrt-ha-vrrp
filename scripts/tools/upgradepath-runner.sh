#!/bin/sh
set -eu
. "$(dirname -- "$0")/common.sh"

rd="$(detect_root)"
migdir="$rd/scripts/migrate"

FROM="${FROM:-}"
TO="${TO:-}"
[ -n "$FROM" ] || die "FROM not set"
[ -n "$TO" ]   || die "TO not set"

direct="$migdir/migrate_${FROM}_to_${TO}.sh"
if [ -x "$direct" ]; then
  log "Running direct migration: $(basename "$direct")"
  exec "$direct"
fi

log "No direct migration script found. Attempting chained migrations..."
found=0
cur="$FROM"
max=200
i=0
while [ "$cur" != "$TO" ] && [ $i -lt $max ]; do
  i=$((i+1))
  next="$(ls -1 "$migdir"/migrate_"$cur"_to_*.sh 2>/dev/null | head -n1 || true)"
  if [ -z "$next" ]; then
    warn "No next-step migration found from $cur"
    break
  fi
  log "Step $i: $(basename "$next")"
  sh "$next"
  cur="$(basename "$next")"
  cur="${cur#migrate_}"; cur="${cur%*.sh}"
  cur="${cur#${FROM}_to_}"
  FROM="$cur"
  [ "$cur" = "$TO" ] && found=1 && break
done

[ "$found" -eq 1 ] || die "Migration path not found. Please add migrate scripts or enrich chain."
log "Migration chain complete."
