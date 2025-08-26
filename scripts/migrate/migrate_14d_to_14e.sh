#!/bin/sh
set -eu
ROOT_DIR="$(pwd)"
SRC_DIR="$(CDPATH= cd -- "$(dirname -- "$0")"/../../diff_14d_to_14e && pwd)"
# Copy files
list_file_copy() {
cat <<'EOF'
scripts/installer.sh
scripts/uninstaller.sh
scripts/node/lib_repo.sh
docs/changelog/0.5.16-007_reviewfix14e.md
docs/features/0.5.16-007_reviewfix14e.md
scripts/migrate/json_patch_14e.py
EOF
}
while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  dst="$ROOT_DIR/$rel"; mkdir -p "$(dirname "$dst")"
  cp -f "$SRC_DIR/$rel" "$dst"
  echo "[+] copied $rel"
done <<EOF
$(list_file_copy)
EOF
# Patch JSONs
if command -v python3 >/dev/null 2>&1; then
  (cd "$ROOT_DIR" && python3 scripts/migrate/json_patch_14e.py)
else
  echo "[WARN] python3 not found; please update config JSONs manually."
fi
echo "[OK] Migration 14d -> 14e applied."
