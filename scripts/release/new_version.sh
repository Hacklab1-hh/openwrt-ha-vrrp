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

usage() {
  echo "Usage: $0 -v <version> [-p <parent>] [-m <message>] [--no-git]"
  echo "       example: $0 -v 0.5.16-007_reviewfix14d -p 0.5.16-007_reviewfix14c -m 'cleanup & release'"
}
VERSION=""
PARENT=""
MESSAGE=""
DO_GIT=1

while [ $# -gt 0 ]; do
  case "$1" in
    -v) VERSION="$2"; shift 2;;
    -p) PARENT="$2"; shift 2;;
    -m) MESSAGE="$2"; shift 2;;
    --no-git) DO_GIT=0; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done
[ -n "$VERSION" ] || { echo "Missing -v <version>"; usage; exit 1; }

CFG_UP="$ROOT_DIR/config/upgradepath.unified.json"
CFG_UPD="$ROOT_DIR/config/updatepath.unified.json"
[ -f "$CFG_UP" ] && [ -f "$CFG_UPD" ] || { echo "Missing config files in $ROOT_DIR/config"; exit 1; }

# Determine parent if not given: use last 'reviewfix' node (fallback to highest version by string sort)
if [ -z "$PARENT" ]; then
  PARENT="$(grep -oE '"'"'\"version\"\s*:\s*\"[^\"]+\"'"'"' "$CFG_UP" | sed -E 's/.*"version"\s*:\s*"(.*)".*/\1/' | grep reviewfix | tail -n1 || true)"
  [ -n "$PARENT" ] || PARENT="$(grep -oE '"'"'\"version\"\s*:\s*\"[^\"]+\"'"'"' "$CFG_UP" | sed -E 's/.*"version"\s*:\s*"(.*)".*/\1/' | sort | tail -n1)"
fi
echo "New version: $VERSION (parent: $PARENT)"

# Create docs stubs
mkdir -p "$ROOT_DIR/docs/changelog" "$ROOT_DIR/docs/features"
CHANGE_MD="$ROOT_DIR/docs/changelog/${VERSION}.md"
FEAT_MD="$ROOT_DIR/docs/features/${VERSION}.md"
[ -f "$CHANGE_MD" ] || {
cat > "$CHANGE_MD" <<EOF
# ${VERSION} — Changes
- (Bitte ausfüllen) Kurzbeschreibung der Änderungen.
- (Optional) Breaking Changes / Migrationshinweise
EOF
}
[ -f "$FEAT_MD" ] || {
cat > "$FEAT_MD" <<EOF
# ${VERSION} — Features
- (Bitte ausfüllen) Neue Features / Verbesserungen
EOF
}

# Update upgradepath.unified.json
python3 - "$CFG_UP" "$VERSION" "$PARENT" <<'PY'
import json, sys
p, ver, parent = sys.argv[1:4]
data = json.load(open(p, "r", encoding="utf-8"))
vers = data.setdefault("versions", [])
if not any(v.get("version")==ver for v in vers):
    entry = {"version": ver, "archive": f"openwrt-ha-vrrp-{ver}.tar.gz", "parent": parent}
    vers.append(entry)
data["generated"] = __import__("datetime").datetime.utcnow().isoformat()+"Z"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY

# Update updatepath.unified.json (edge parent -> version)
python3 - "$CFG_UPD" "$VERSION" "$PARENT" <<'PY'
import json, sys
p, ver, parent = sys.argv[1:4]
data = json.load(open(p, "r", encoding="utf-8"))
ups = data.setdefault("updates", [])
if not any(u.get("from")==parent and u.get("to")==ver for u in ups):
    ups.append({"from": parent, "to": ver, "type": "inplace", "idempotent": True})
data["generated"] = __import__("datetime").datetime.utcnow().isoformat()+"Z"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY

# Re-generate aggregated docs
"$ROOT_DIR/scripts/gen-base-md.sh"

# Lint migrate layout
"$ROOT_DIR/scripts/lint_migrations.sh"

# optional git ops
if [ $DO_GIT -eq 1 ] && command -v git >/dev/null 2>&1; then
  (cd "$ROOT_DIR" && git add -A && git commit -m "release: ${VERSION} ${MESSAGE:-}" --no-verify || true && git tag "v${VERSION}" || true)
  echo "Git commit/tag attempted. Review with: git log --decorate --oneline -n 3"
else
  echo "Skipping git operations."
fi

echo "New version ${VERSION} prepared."
