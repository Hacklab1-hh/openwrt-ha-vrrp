#!/bin/sh
set -eu
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
ok=1
for f in "$ROOT_DIR/config/upgradepath.unified.json" "$ROOT_DIR/config/updatepath.unified.json"; do
  if [ ! -f "$f" ]; then echo "FAIL: missing $f"; ok=0; else echo "OK: $f"; fi
done
[ $ok -eq 1 ] && echo "SELF-TEST: OK" && exit 0 || (echo "SELF-TEST: FAIL"; exit 1)
