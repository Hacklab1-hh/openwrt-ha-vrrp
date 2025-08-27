#!/bin/sh
set -eu
mode="${1:-migrate}"
case "$mode" in
  migrate)
    echo "[migrate] nothing specific for 0.5.16-007_reviewfix16_featurefix15_fix1"
    ;;
  rollback)
    echo "[rollback] nothing specific for 0.5.16-007_reviewfix16_featurefix15_fix1"
    ;;
  *) echo "usage: $0 [migrate|rollback]" >&2; exit 1;;
esac
