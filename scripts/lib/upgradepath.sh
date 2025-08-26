#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

set -eu
UP_TXT="scripts/upgradepath_unified.txt"
norm(){
  echo "$1" | awk 'function pad3(n){return sprintf("%03d", n+0)} {if (match($0,/^([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)$/,m)){printf "%s.%s.%s-%s\n",m[1],m[2],m[3],pad3(m[4])} else {print $0}}'
}
parent_of(){
  want="$(norm "$1")"
  awk -v V="$want" '
    function norm(v,  a,b,c,d){if (match(v,/^([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)$/,m)){return sprintf("%d.%d.%d-%03d",m[1],m[2],m[3],m[4])} return v}
    $0!~/^#/ && NF>0 {child=$1; parent=""; if ($2=="<-" && NF>=3) parent=$3; child=norm(child); parent=norm(parent); if(child==V){print parent; exit 0}}
  ' "$UP_TXT"
}
latest_in_series(){
  ser="$1"
  awk -v S="$ser" '
    function vkey(v,  a,b,c,d){d=-1;if (match(v,/^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9]+))?$/,m)){a=m[1]+0;b=m[2]+0;c=m[3]+0;d=(m[5]==""?-1:m[5]+0)};return sprintf("%03d.%03d.%03d.%03d",a,b,c,d)}
    $0!~/^#/ && NF>0 {child=$1; sub(/\s.*/,"",child); if (index(child,S)==1){arr[child]=vkey(child)}}
    END{bestv="";bestk=""; for (k in arr){if (arr[k]>bestk){bestk=arr[k];bestv=k}} if(bestv!="") print bestv}
  ' "$UP_TXT"
}
# Chain Builder
build_chain(){
  FROM="$(norm "$1")"; TO="$(norm "$2")"
  map="$(awk '
    function norm(v,  a,b,c,d){ if (match(v,/^([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)$/,m)) {return sprintf("%d.%d.%d-%03d",m[1],m[2],m[3],m[4])} return v }
    $0 !~ /^#/ && NF>0 { child=$1; parent=""; if ($2=="<-" && NF>=3) parent=$3; print norm(child) ":" norm(parent) }
  ' "$UP_TXT")"
  parent_of_ver(){ echo "$map" | grep "^$1:" | head -n1 | cut -d: -f2; }
  path_rev=""; cur="$TO"; seen=0
  while [ -n "$cur" ] && [ $seen -le 1000 ]; do
    path_rev="$path_rev $cur"; [ "$cur" = "$FROM" ] && break
    cur="$(parent_of_ver "$cur")"; seen=$((seen+1))
  done
  if echo "$path_rev" | grep -qw "$FROM"; then
    rev=""; for v in $path_rev; do rev="$v $rev"; done
    echo "$rev" | sed -e "s/^ *//" -e "s/ *$//"; return 0
  fi
  path_rev=""; cur="$FROM"; seen=0
  while [ -n "$cur" ] && [ $seen -le 1000 ]; do
    path_rev="$path_rev $cur"; [ "$cur" = "$TO" ] && { echo "$path_rev" | sed -e "s/^ *//" -e "s/ *$//"; return 0; }
    cur="$(parent_of_ver "$cur")"; seen=$((seen+1))
  done
  echo ""; return 2
}
step_pairs(){
  CHAIN="$(build_chain "$1" "$2")" || { echo ""; return 1; }
  [ -n "$CHAIN" ] || { echo ""; return 2; }
  prev=""; for v in $CHAIN; do if [ -z "$prev" ]; then prev="$v"; continue; fi; echo "$prev $v"; prev="$v"; done
}
