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

# --- repo root autodetect (works from scripts/migrate/*) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# Migration to 0.5.16-007: align keys and introduce defaults
set -eu
CFG="ha_vrrp"
changed=0
for sec in $(uci -q show "$CFG" | awk -F. '/=instance/{print $2}'); do
  iface="$(uci -q get $CFG.$sec.interface 2>/dev/null || true)"
  [ -n "${iface:-}" ] && { uci set $CFG.$sec.iface="$iface"; uci delete $CFG.$sec.interface || true; changed=1; }
  vip="$(uci -q get $CFG.$sec.vip 2>/dev/null || true)"
  [ -n "${vip:-}" ] && { uci set $CFG.$sec.vip_cidr="$vip"; uci delete $CFG.$sec.vip || true; changed=1; }
  have_src="$(uci -q get $CFG.$sec.unicast_src_ip 2>/dev/null || true)"
  iface_ok="$(uci -q get $CFG.$sec.iface 2>/dev/null || true)"
  if [ -z "${have_src:-}" ] && [ -n "${iface_ok:-}" ]; then
    ipaddr="$(ip -o -4 addr show dev "$iface_ok" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)"
    [ -n "$ipaddr" ] && { uci set $CFG.$sec.unicast_src_ip="$ipaddr"; changed=1; }
  fi
done

# Introduce core defaults
ssh_backend="$(uci -q get $CFG.core.ssh_backend 2>/dev/null || true)"
if [ -z "${ssh_backend:-}" ]; then
  uci set $CFG.core.ssh_backend='auto'
  changed=1
fi

if [ "$changed" = "1" ]; then
  uci commit "$CFG"
fi
exit 0
