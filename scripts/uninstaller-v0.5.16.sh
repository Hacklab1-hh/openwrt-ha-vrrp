#!/bin/sh
# Generic uninstaller for openwrt-ha-vrrp 0.5.16 → delegates to latest build
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/uninstaller-v0.5.16-009.sh" "$@"
