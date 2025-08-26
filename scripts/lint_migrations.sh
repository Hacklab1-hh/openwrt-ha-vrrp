#!/bin/sh
set -eu
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
err=0
# Ensure all migrate_*.sh live under scripts/migrate/
bad=$(find "$ROOT_DIR/scripts" -type f -name 'migrate_*.sh' ! -path '*/scripts/migrate/*' -printf '%P\n' || true)
if [ -n "$bad" ]; then
  echo "Migrations outside scripts/migrate/:"
  echo "$bad"
  err=1
fi
# Ensure JSON references point to scripts/migrate/
badjson=$(grep -RIn --include='*path*.json' -E 'scripts/(?!migrate/).*migrate_.*\.sh' "$ROOT_DIR/config" || true)
if [ -n "$badjson" ]; then
  echo "JSONs reference old migration paths:"
  echo "$badjson"
  err=1
fi
if [ $err -eq 0 ]; then
  echo "Migration layout OK."
fi
exit $err
