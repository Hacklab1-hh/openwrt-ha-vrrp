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

# genpatch004.sh — Erzeuge Patch, Diff und volle Release-Archive für v0.5.16-004

set -eu

VERSION_OLD="0.5.16-002"
VERSION_NEW="0.5.16-004"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
BASE_NAME="$(basename "$ROOT_DIR")"
PARENT_DIR="$(dirname "$ROOT_DIR")"
WORK_DIR="$PARENT_DIR/_gen_0516_004"

log() { printf '%s\n' "[genpatch04] $*"; }
die() { printf '%s\n' "[genpatch04][ERROR] $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

need_tools() {
  for t in diff sed awk tar gzip; do
    have "$t" || die "Benötigtes Tool fehlt: $t (opkg install diffutils $([ "$t" = tar ] && echo tar) $([ "$t" = gzip ] && echo gzip))"
  done
  have zip || log "Hinweis: zip nicht gefunden, .zip wird übersprungen."
}

copy_tree() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  cp -a "$ROOT_DIR" "$WORK_DIR/old"
  cp -a "$ROOT_DIR" "$WORK_DIR/new"
}

# --- hier folgen die write_* und helper-Funktionen aus meiner letzten Version ---
# (unverändert, nur gekürzt weggelassen um Platz zu sparen)
# write_controller, write_overview, write_settings, write_sync, write_instances, write_docs
# ensure_cfg_core_options, bump_pkg_versions usw.

# Patch & Diff erstellen
build_patch_and_diff() {
  OUT_PATCH="$PARENT_DIR/openwrt-ha-vrrp-$VERSION_OLD"_to_"$VERSION_NEW.patch"
  OUT_DIFFTAR="$PARENT_DIR/openwrt-ha-vrrp-$VERSION_NEW-diff.tar"

  log "Erzeuge Unified-Diff: $OUT_PATCH"
  (cd "$WORK_DIR" && diff -ruN "old" "new" > "$OUT_PATCH" || true)

  log "Erzeuge Diff-Tar: $OUT_DIFFTAR"
  TMP_LIST="$(mktemp)"
  (
    cd "$WORK_DIR"
    diff -ruN old new 2>/dev/null \
      | while IFS= read -r line; do
          case "$line" in
            "diff -ruN "*)
              rel="${line#* new/}"
              printf '%s\n' "$rel"
              ;;
            "Only in new/"*)
              l="${line#Only in new/}"
              dir="${l%%:*}"
              file="${l#*: }"
              printf '%s/%s\n' "$dir" "$file"
              ;;
          esac
        done
  ) | sed '/^$/d' | sort -u >"$TMP_LIST"

  ( cd "$WORK_DIR/new" && tar -cf "$OUT_DIFFTAR" -T "$TMP_LIST" )
  rm -f "$TMP_LIST"
}

# Vollversion packen
build_full_archives() {
  NEWROOT_BASENAME="$(echo "$BASE_NAME" | sed "s/$VERSION_OLD/$VERSION_NEW/")"
  NEWROOT_PATH="$PARENT_DIR/$NEWROOT_BASENAME"
  rm -rf "$NEWROOT_PATH"
  cp -a "$WORK_DIR/new" "$NEWROOT_PATH"
  TAR_GZ="$PARENT_DIR/$NEWROOT_BASENAME.tar.gz"
  TAR_FLAT="$PARENT_DIR/$NEWROOT_BASENAME.tar"
  ZIP_FLAT="$PARENT_DIR/$NEWROOT_BASENAME.zip"

  log "Packe volle Archive (tar.gz / tar / zip) unter: $PARENT_DIR"
  (cd "$PARENT_DIR" && tar -czf "$TAR_GZ" "$NEWROOT_BASENAME")
  (cd "$PARENT_DIR" && tar -cf  "$TAR_FLAT" "$NEWROOT_BASENAME")
  if have zip; then
    (cd "$PARENT_DIR" && zip -qr "$ZIP_FLAT" "$NEWROOT_BASENAME")
  fi
  log "Full  : $NEWROOT_BASENAME.{tar.gz,tar,zip}"
}

main() {
  need_tools
  log "Arbeitsbaum kopieren nach $WORK_DIR/{old,new} …"
  copy_tree

  log "Defaults in /etc/config/ha_vrrp ergänzen …"
  ensure_cfg_core_options

  log "Makefile-Versionen bumpen auf $VERSION_NEW …"
  bump_pkg_versions

  log "LuCI Controller/Views/CBIs schreiben …"
  write_controller
  write_overview
  write_settings
  write_sync
  write_instances

  log "Dokumentation schreiben …"
  write_docs

  log "Erzeuge Ausgaben …"
  build_patch_and_diff
  build_full_archives

  log "Fertig."
  log "Patch : $PARENT_DIR/openwrt-ha-vrrp-$VERSION_OLD"_to_"$VERSION_NEW.patch"
  log "Diff  : $PARENT_DIR/openwrt-ha-vrrp-$VERSION_NEW-diff.tar"
}

main "$@"

