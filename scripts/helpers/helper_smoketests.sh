#!/bin/sh
# Run simple smoke tests on the repository.
#
# This script performs a minimal syntax check on all shell scripts and
# verifies that essential files exist.  It returns a non‑zero exit code
# on failure.  Intended for use before packaging a release.

set -eu
root="$(cd "$(dirname "$0")/../.." && pwd)"
err=0

# Syntax check for all *.sh files in scripts
for f in $(find "$root/scripts" -type f -name "*.sh" ); do
    # Skip release scripts that intentionally use bash
    case "$f" in
        */release/*) continue;;
    esac
    if ! sh -n "$f"; then
        echo "[helper_smoketests] Syntax error in $f" >&2
        err=1
    fi
done

# Ensure VERSION exists
[ -f "$root/VERSION" ] || { echo "[helper_smoketests] VERSION file missing" >&2; err=1; }

# Ensure docs exist
[ -f "$root/docs/CONCEPTS.md" ] || { echo "[helper_smoketests] docs/CONCEPTS.md missing" >&2; err=1; }
[ -f "$root/docs/ARCHITECTURE.md" ] || { echo "[helper_smoketests] docs/ARCHITECTURE.md missing" >&2; err=1; }

if [ "$err" -eq 0 ]; then
    echo "[helper_smoketests] All smoke tests passed"
fi
exit "$err"