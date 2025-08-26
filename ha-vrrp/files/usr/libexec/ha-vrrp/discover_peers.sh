#!/bin/sh
set -eu
sec="inst_hb"
if ! uci -q get ha_vrrp.$sec >/dev/null 2>&1; then
  for s in $(uci -q show ha_vrrp | awk -F. '/^ha_vrrp\.[^=]+=/ {print $2}' | cut -d= -f1); do
    n="$(uci -q get ha_vrrp.$s.name || echo)"; [ "$n" = "HEARTBEAT" ] && sec="$s" && break
  done
fi
[ -z "$sec" ] && sec="core"
src="$(uci -q get ha_vrrp.$sec.unicast_src_ip || echo)"
vip="$(uci -q get ha_vrrp.$sec.vip_cidr || echo)"
prefix="192.168.254"
if [ -n "$src" ]; then prefix="${src%.*}"; elif [ -n "$vip" ]; then prefix="${vip%.*/*}"; fi
me="$(uci -q get ha_vrrp.$sec.unicast_src_ip || echo 0.0.0.0)"
for i in $(seq 1 10) 254; do ip="${prefix}.${i}"; [ "$ip" = "$me" ] && continue; ping -c1 -W1 "$ip" >/dev/null 2>&1 && echo "$ip"; done
