#!/bin/sh
set -eu
CIDR="$(uci -q get ha_vrrp.core.discover_cidr || echo)"
if [ -z "$CIDR" ] || [ "$CIDR" = "0.0.0.0/0" ]; then
  sec="inst_hb"
  if ! uci -q get ha_vrrp.$sec >/dev/null 2>&1; then
    for s in $(uci -q show ha_vrrp | awk -F. '/^ha_vrrp\.[^=]+=/ {print $2}' | cut -d= -f1); do
      n="$(uci -q get ha_vrrp.$s.name || echo)"; [ "$n" = "HEARTBEAT" ] && sec="$s" && break
    done
  fi
  src="$(uci -q get ha_vrrp.$sec.unicast_src_ip || echo)"
  vip="$(uci -q get ha_vrrp.$sec.vip_cidr || echo 192.168.254.254/24)"
  CIDR="${src%.*}.0/24"; [ -z "$src" ] && CIDR="${vip%.*/*}.0/24"
fi
NET="${CIDR%/*}"; BASE="${NET%.*}"; MIN="$(uci -q get ha_vrrp.core.discover_min || echo 1)"; MAX="$(uci -q get ha_vrrp.core.discover_max || echo 10)"
ME="$(uci -q get ha_vrrp.core.peer_host || echo)"
for i in $(seq "$MIN" "$MAX") 254; do
  IP="${BASE}.${i}"
  [ "$IP" = "$ME" ] && continue
  ping -c1 -W1 "$IP" >/dev/null 2>&1 && echo "$IP"
done
