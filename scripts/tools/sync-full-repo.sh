#!/bin/sh
# sync-full-repo.sh
#
# Download and mirror GitHub repositories without using git.  This script
# retrieves tar.gz archives of branches or tags from GitHub, unpacks them
# into a `mirror/<ref>` directory and updates a `current` symlink to the
# most recently processed ref.  It is designed to run on BusyBox/ash and
# requires only `wget` or `curl` and `tar`.

set -eu

usage() {
    echo "Usage: $0 -o <owner> -r <repo> [-f <refs_file>] [-x <ref>] [--api] [--no-symlink]" >&2
    echo "       -o|--owner   GitHub owner/user (required)" >&2
    echo "       -r|--repo    GitHub repository name (required)" >&2
    echo "       -f|--refs    File with refs to mirror (one per line)" >&2
    echo "       -x|--ref     Single ref to mirror" >&2
    echo "       --api       Use GitHub API (requires GITHUB_TOKEN) to list branches and tags" >&2
    echo "       --no-symlink Do not update the 'current' symlink" >&2
}

OWNER=""
REPO=""
REFS_FILE=""
ONE_REF=""
USE_API=0
NO_SYMLINK=0

while [ $# -gt 0 ]; do
    case "$1" in
        -o|--owner) OWNER="$2"; shift 2;;
        -r|--repo)  REPO="$2"; shift 2;;
        -f|--refs)  REFS_FILE="$2"; shift 2;;
        -x|--ref)   ONE_REF="$2"; shift 2;;
        --api)      USE_API=1; shift 1;;
        --no-symlink) NO_SYMLINK=1; shift 1;;
        -h|--help)  usage; exit 0;;
        *) echo "Unknown option: $1" >&2; usage; exit 1;;
    esac
done

[ -n "$OWNER" ] || { echo "owner required" >&2; usage; exit 2; }
[ -n "$REPO" ] || { echo "repo required" >&2; usage; exit 2; }

BASE_DIR="$(pwd)"
MIRROR_DIR="$BASE_DIR/mirror"
CURRENT_LINK="$BASE_DIR/current"
mkdir -p "$MIRROR_DIR"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

dl() {
    url="$1"; out="$2"
    if have_cmd curl; then
        curl -L --silent --fail "$url" -o "$out"
    elif have_cmd wget; then
        wget -q -O "$out" "$url"
    else
        echo "Neither curl nor wget found" >&2; exit 3
    fi
}

api_list_refs() {
    if [ -z "${GITHUB_TOKEN:-}" ]; then
        echo "GITHUB_TOKEN not set for API listing" >&2; exit 4
    fi
    tmpb="$MIRROR_DIR/.branches.json"
    tmpt="$MIRROR_DIR/.tags.json"
    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$OWNER/$REPO/branches?per_page=100" > "$tmpb"
    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$OWNER/$REPO/tags?per_page=200" > "$tmpt"
    # Extract 'name' fields (simple sed/awk for BusyBox)
    sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$tmpb"
    sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$tmpt"
    rm -f "$tmpb" "$tmpt"
}

collect_refs() {
    if [ "$USE_API" -eq 1 ]; then
        api_list_refs
    elif [ -n "$ONE_REF" ]; then
        echo "$ONE_REF"
    elif [ -n "$REFS_FILE" ] && [ -f "$REFS_FILE" ]; then
        sed 's/#.*$//' "$REFS_FILE" | tr -d '\r' | awk 'NF>0'
    else
        echo "No refs provided. Use -x, -f or --api" >&2; exit 5
    fi
}

download_and_extract() {
    ref="$1"
    tmp_tar="$MIRROR_DIR/${OWNER}_${REPO}_${ref}.tar.gz"
    url="https://github.com/$OWNER/$REPO/archive/refs/heads/$ref.tar.gz"
    # Try branch first; fall back to tag
    if ! dl "$url" "$tmp_tar"; then
        url="https://github.com/$OWNER/$REPO/archive/refs/tags/$ref.tar.gz"
        dl "$url" "$tmp_tar"
    fi
    dest="$MIRROR_DIR/$ref"
    rm -rf "$dest"
    mkdir -p "$dest"
    tar -xzf "$tmp_tar" -C "$dest"
    # Move contents of the single top-level directory up
    sub=$(find "$dest" -mindepth 1 -maxdepth 1 -type d | head -n1 || true)
    if [ -n "$sub" ]; then
        find "$sub" -mindepth 1 -maxdepth 1 -exec mv {} "$dest" \;
        rmdir "$sub" || true
    fi
    rm -f "$tmp_tar"
    echo "$dest"
}

last=""
for ref in $(collect_refs); do
    last=$(download_and_extract "$ref")
done

if [ "$NO_SYMLINK" -eq 0 ] && [ -n "$last" ]; then
    rm -f "$CURRENT_LINK"
    ln -s "$last" "$CURRENT_LINK" || {
        echo "$last" > "$BASE_DIR/CURRENT_PATH.txt"
    }
fi

exit 0