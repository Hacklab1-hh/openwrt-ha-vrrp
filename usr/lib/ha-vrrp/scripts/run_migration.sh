#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/miglib.sh"
FROM="${1:-}"; TO="${2:-}"; shift 2 || true
case "${FROM}__${TO}" in
  0.5.10__0.5.11) exec "$HERE/migrate_0.5.10_to_0.5.11.sh" --migrate "$@";;
  0.5.11__0.5.10) exec "$HERE/migrate_0.5.10_to_0.5.11.sh" --rollback "$@";;
  *) err "kein Migrationsskript für $FROM → $TO"; exit 2;;
esac
