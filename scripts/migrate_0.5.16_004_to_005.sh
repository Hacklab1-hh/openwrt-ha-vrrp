#!/bin/sh
# Migration 0.5.16-004 -> 0.5.16-005
# Mappe ggf. alte Keys auf neue:
#  - interface -> iface
#  - vip -> vip_cidr
#  - stelle sicher, dass unicast_src_ip existiert, falls iface eine IP hat (best effort)

set -eu

CFG="ha_vrrp"
changed=0

for sec in $(uci -q show "$CFG" | awk -F. '/=instance/{print $2}'); do
  iface="$(uci -q get $CFG.$sec.interface 2>/dev/null || true)"
  if [ -n "${iface:-}" ]; then
    uci set $CFG.$sec.iface="$iface" || true
    uci delete $CFG.$sec.interface || true
    changed=1
  fi

  vip="$(uci -q get $CFG.$sec.vip 2>/dev/null || true)"
  if [ -n "${vip:-}" ]; then
    uci set $CFG.$sec.vip_cidr="$vip" || true
    uci delete $CFG.$sec.vip || true
    changed=1
  fi

  # setze unicast_src_ip, falls leer und iface vorhanden
  have_src="$(uci -q get $CFG.$sec.unicast_src_ip 2>/dev/null || true)"
  iface_ok="$(uci -q get $CFG.$sec.iface 2>/dev/null || true)"
  if [ -z "${have_src:-}" ] && [ -n "${iface_ok:-}" ]; then
    ipaddr="$(ip -o -4 addr show dev "$iface_ok" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)"
    if [ -n "$ipaddr" ]; then
      uci set $CFG.$sec.unicast_src_ip="$ipaddr" || true
      changed=1
    fi
  fi
done

if [ "$changed" = "1" ]; then
  uci commit "$CFG"
  echo "Migration ha_vrrp 0.5.16-004 -> 0.5.16-005 angewendet."
else
  echo "Migration ha_vrrp: nichts zu ändern."
fi

exit 0
