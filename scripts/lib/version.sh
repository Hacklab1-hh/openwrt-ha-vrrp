#!/bin/sh
series_from_version() { echo "$1" | awk -F- '{print $1}'; }
patch_from_version() { case "$1" in *-*) echo "$1" | awk -F- '{print $2}' ;; *) echo "" ;; esac; }
pad3() { n="${1:-0}"; n=$((10#$n)); printf "%03d" "$n"; }
latest_patch_for_series() {
  series="$1"
  ls -1 "scripts/installer-v${series}-"*.sh 2>/dev/null |     sed -n "s|^scripts/installer-v${series}-\([0-9][0-9][0-9]\)\.sh$|\1|p" |     sort -n | tail -n1
}
