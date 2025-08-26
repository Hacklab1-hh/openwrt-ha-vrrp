#!/bin/sh
# Convenience wrapper → latest 0.5.16 uninstaller
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/uninstaller-v0.5.16.sh" "$@"
