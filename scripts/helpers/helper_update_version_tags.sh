#!/bin/sh
# Normalize version tags across markdown files.
#
# This helper removes any trailing `_fixN` suffixes from version strings and
# ensures that the second line of each markdown file declares the current
# version.  It reads the version from the repository’s VERSION file.

set -eu
root="$(cd "$(dirname "$0")/../.." && pwd)"
ver_file="$root/VERSION"
if [ ! -f "$ver_file" ]; then
    echo "[helper_update_version_tags] VERSION file not found" >&2
    exit 1
fi
VERSION="$(tr -d '\r\n' < "$ver_file")"

# Iterate over markdown files in the top level and docs directories
find "$root" -maxdepth 2 -type f \( -name "*.md" -o -name "*.txt" \) | while read -r f; do
    # Remove any _fixN suffixes
    sed -i 's/_fix[0-9]\{1,\}//g' "$f"
    # Update the second line to indicate the current version if it starts with 'Current Version:'
    if head -n1 "$f" | grep -q '^#'; then
        if sed -n '2p' "$f" | grep -q '^Current Version:'; then
            # Replace existing line
            sed -i "2s/^Current Version:.*/Current Version: $VERSION/" "$f"
        fi
    fi
done
echo "[helper_update_version_tags] Normalised version tags to $VERSION"