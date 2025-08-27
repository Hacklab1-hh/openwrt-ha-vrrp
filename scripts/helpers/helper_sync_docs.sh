#!/bin/sh
# Synchronise concept and architecture documents.
#
# This helper ensures that the `docs/CONCEPTS.md` and `docs/ARCHITECTURE.md`
# files always reflect the current version and append versionspecific
# partials into their corresponding history files.  It is intended to be
# run before packaging a release.

set -eu
root="$(cd "$(dirname "$0")/../.." && pwd)"
ver_file="$root/VERSION"
docs="$root/docs"
if [ ! -f "$ver_file" ]; then
    echo "[helper_sync_docs] VERSION file not found" >&2
    exit 1
fi
VERSION="$(tr -d '\r\n' < "$ver_file")"

# Ensure history files exist
mkdir -p "$docs/history"
[ -f "$docs/history/concepts_history.md" ] || echo "# Concepts History" > "$docs/history/concepts_history.md"
[ -f "$docs/history/architecture_history.md" ] || echo "# Architecture History" > "$docs/history/architecture_history.md"

# Update current documents
update_current() {
    file="$1"
    title="$2"
    if [ ! -f "$file" ]; then
        echo "# $title" > "$file"
    fi
    # Replace or insert the current version line
    if grep -q '^Current Version:' "$file"; then
        sed -i "s/^Current Version:.*/Current Version: $VERSION/" "$file"
    else
        # Insert after first header
        sed -i "1a\\\nCurrent Version: $VERSION\n" "$file"
    fi
}

update_current "$docs/CONCEPTS.md" "CONCEPTS"
update_current "$docs/ARCHITECTURE.md" "ARCHITECTURE"

# Append partials to history if not already present
append_history() {
    partial="$1"; hist="$2"
    [ -f "$partial" ] || return 0
    if ! grep -q "## $VERSION" "$hist" 2>/dev/null; then
        {
            echo "## $VERSION"
            echo ""
            cat "$partial"
            echo ""
        } >> "$hist"
        echo "[helper_sync_docs] appended $(basename "$partial") to $(basename "$hist")"
    fi
}

append_history "$docs/concepts/$VERSION.md" "$docs/history/concepts_history.md"
append_history "$docs/architecture/$VERSION.md" "$docs/history/architecture_history.md"

echo "[helper_sync_docs] Synced docs for $VERSION"