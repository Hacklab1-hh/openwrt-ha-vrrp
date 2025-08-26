#!/bin/sh
set -eu

IFACE="$(uci -q get ha_vrrp.core.iface || echo wan)"
VLAN_ID="$(uci -q get ha_vrrp.core.vlan_id || echo)"
USE_VLAN="$(uci -q get ha_vrrp.core.use_vlan || echo 0)"

[ "$USE_VLAN" = "1" ] || exit 0
[ -n "$VLAN_ID" ] || { echo "[ha-vrrp] use_vlan=1 but vlan_id missing"; exit 1; }

DEV="${IFACE}.${VLAN_ID}"

ip link show "$DEV" >/dev/null 2>&1 && exit 0

ip link show "$IFACE" >/dev/null 2>&1 || {
  echo "[ha-vrrp] base interface $IFACE not found"; exit 1;
}

ip link add link "$IFACE" name "$DEV" type vlan id "$VLAN_ID"
ip link set dev "$DEV" up

echo "[ha-vrrp] VLAN interface ready: $DEV"
