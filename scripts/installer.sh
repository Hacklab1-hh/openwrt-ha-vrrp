#!/bin/sh
# Convenience wrapper → latest 0.5.16 installer
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/installer-v0.5.16.sh" "$@"
