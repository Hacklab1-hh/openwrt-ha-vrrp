#!/bin/sh
logger -t ha-vrrp "Transition -> MASTER (state=$STATE)"
EX="$(uci -q get ha_vrrp.core.extra_garp || echo 0)"
VIP="$(uci -q get ha_vrrp.core.vip_cidr | cut -d/ -f1)"
IFACE="$(uci -q get ha_vrrp.core.iface)"
VLAN="$(uci -q get ha_vrrp.core.vlan_id)"
USE_VLAN="$(uci -q get ha_vrrp.core.use_vlan || echo 0)"
[ "$USE_VLAN" = "1" ] && [ -n "$VLAN" ] && IFACE="$IFACE.$VLAN"
if [ "$EX" = "1" ] && command -v arping >/dev/null 2>&1; then
  arping -U -c 3 -I "$IFACE" "$VIP" >/dev/null 2>&1 || true
fi
