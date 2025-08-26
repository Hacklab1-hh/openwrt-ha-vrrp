#!/bin/sh
# update-to-latest.sh → ruft den Update-Pfad auf 0.5.16-009
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/ha-vrrp-manage.sh" update "0.5.16-009"
