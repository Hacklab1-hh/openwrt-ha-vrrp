#!/bin/sh
set -eu
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
if [ ! -f "$ROOT_DIR/gen-base-md.sh" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
export ROOT_DIR
VRRP_REPO="/root/vrrp-repo"
VRRP_CACHE="/root/vrrp-cache"
VRRP_CUR="/root/openwrt-ha-vrrp_current"
VRRP_GIT_DIR="/root/vrrp-git/openwrt-ha-vrrp"
. "$ROOT_DIR/node/lib_repo.sh"
usage(){ cat <<EOF
Usage: $0 [--version <vers>] [--from-git|--from-local] [--no-docs] [--no-lint]
EOF
}
MODE="auto"; REQ_VERSION=""; DO_DOCS=1; DO_LINT=1
while [ $# -gt 0 ]; do
  case "$1" in
    --version) REQ_VERSION="${2:-}"; shift 2;;
    --from-git) MODE="git"; shift;;
    --from-local) MODE="local"; shift;;
    --no-docs) DO_DOCS=0; shift;;
    --no-lint) DO_LINT=0; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done
mkdir -p "$VRRP_REPO" "$VRRP_CACHE"
if [ $DO_LINT -eq 1 ] && [ -x "$ROOT_DIR/../lint_migrations.sh" ]; then "$ROOT_DIR/../lint_migrations.sh"; fi
if [ $DO_DOCS -eq 1 ] && [ -x "$ROOT_DIR/../gen-base-md.sh" ]; then "$ROOT_DIR/../gen-base-md.sh" || true; fi
if [ "$MODE" = "git" ] || { [ "$MODE" = "auto" ] && [ -d "$VRRP_GIT_DIR/.git" ]; }; then
  echo "[INFO] Quelle: Git"
  repo_git_prepare_snapshot "$VRRP_GIT_DIR" "$VRRP_CACHE" "$REQ_VERSION" || true
  if [ -z "$REQ_VERSION" ]; then REQ_VERSION="$(repo_last_git_version_name "$VRRP_GIT_DIR" || true)"; fi
  if [ -n "$REQ_VERSION" ]; then repo_switch_symlink "$VRRP_CACHE" "$VRRP_CUR" "$REQ_VERSION"; exit 0; fi
  echo "[WARN] Git-Version unbekannt, fallback lokal"
fi
echo "[INFO] Quelle: lokal"
if [ -n "$REQ_VERSION" ]; then
  repo_extract_version_from_local "$VRRP_REPO" "$VRRP_CACHE" "$REQ_VERSION"
  repo_switch_symlink "$VRRP_CACHE" "$VRRP_CUR" "$REQ_VERSION"; exit 0
fi
LATEST="$(repo_find_latest_archive "$VRRP_REPO")"; [ -n "$LATEST" ] || { echo "Keine Archive in $VRRP_REPO" >&2; exit 2; }
VERS="$(repo_guess_version_from_filename "$(basename -- "$LATEST")")"; [ -n "$VERS" ] || VERS="$(date +%Y%m%d-%H%M%S)"
repo_extract_archive_to_cache "$LATEST" "$VRRP_CACHE" "$VERS"
repo_switch_symlink "$VRRP_CACHE" "$VRRP_CUR" "$VERS"
