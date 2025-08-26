#!/bin/sh
set -eu
ensure_one() {
  local sec="$1"
  local IFACE USE_VLAN VLAN_ID DEV
  IFACE="$(uci -q get ha_vrrp.$sec.iface || echo)"
  [ -n "$IFACE" ] || return 0
  USE_VLAN="$(uci -q get ha_vrrp.$sec.use_vlan || echo 0)"
  [ "$USE_VLAN" = "1" ] || return 0
  VLAN_ID="$(uci -q get ha_vrrp.$sec.vlan_id || echo)"
  [ -n "$VLAN_ID" ] || { echo "[ha-vrrp] $sec: use_vlan=1 but vlan_id missing"; return 1; }
  DEV="${IFACE}.${VLAN_ID}"
  ip link show "$DEV" >/dev/null 2>&1 && return 0
  ip link show "$IFACE" >/dev/null 2>&1 || { echo "[ha-vrrp] $sec: base if $IFACE not found"; return 1; }
  ip link add link "$IFACE" name "$DEV" type vlan id "$VLAN_ID"
  ip link set dev "$DEV" up
  echo "[ha-vrrp] VLAN ready: $DEV ($sec)"
}
INSTANCES="$(uci -q show ha_vrrp | awk -F. '/^ha_vrrp\.[^=]+=/ {print $2}' | cut -d= -f1 | sort -u | grep -E '^inst_' || true)"
if [ -z "$INSTANCES" ]; then ensure_one "core"; else for s in $INSTANCES; do ensure_one "$s"; done; fi
