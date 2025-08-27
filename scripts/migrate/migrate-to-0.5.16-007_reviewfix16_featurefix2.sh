#!/bin/sh
set -eu
base="$(cd "$(dirname "$0")/../.." && pwd)"
echo "[ha-vrrp] migrating repo to 0.5.16-007_reviewfix16_featurefix2"

cd "$base/scripts"
for f in *; do
  [ -f "$f" ] || continue
  case "$f" in
    gen-*.sh|gen_*.sh|migrate-*.sh|migrate_*.sh|installer-*.sh|installer_*.sh|uninstaller-*.sh|uninstaller_*.sh)
      echo "Removing scripts/$f"; rm -f "$f";;
  esac
done

cd "$base/docs"
mkdir -p changelogs releases
for f in *.md; do
  [ -f "$f" ] || continue
  lf="$(printf '%s' "$f" | tr 'A-Z' 'a-z')"
  ver=""
  case "$f" in
    *[0-9].[0-9].[0-9]*reviewfix*|*reviewfix*|*hotfix*)
      ver="$(printf '%s' "$f" | sed -n 's/.*\([0-9][0-9.\-_]*reviewfix[0-9a-zA-Z_\-]*\).*/\1/p')"
      [ -z "$ver" ] && ver="$(printf '%s' "$f" | sed -n 's/.*\(reviewfix[0-9a-zA-Z_\-]*\).*/\1/p')"
      ;;
  esac
  [ -z "$ver" ] && continue
  rel_dir="releases/$ver"; mkdir -p "$rel_dir"
  case "$lf" in
    *changelog*.md) tgt="changelogs/$ver.md" ;;
    *known*issue*.md) tgt="$rel_dir/KNOWN-ISSUES.md" ;;
    *install*.md) tgt="$rel_dir/INSTALL.md" ;;
    *feature*.md) tgt="$rel_dir/FEATURES.md" ;;
    *readme*.md) tgt="$rel_dir/README.md" ;;
    *) base_noext="${f%.*}"; tgt="$rel_dir/$(printf '%s' "$base_noext" | tr 'a-z' 'A-Z').md" ;;
  esac
  if [ -e "$tgt" ]; then stem="${tgt%.*}"; ext="${tgt##*.}"; tgt="${stem}_2.${ext}"; fi
  echo "Moving $f -> $tgt"
  mkdir -p "$(dirname "$tgt")"
  git mv -f "$f" "$tgt" 2>/dev/null || mv -f "$f" "$tgt"
done

echo "[ha-vrrp] migration complete"
