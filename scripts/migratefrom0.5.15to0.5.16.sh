#!/bin/sh
# migratefrom0.5.15to0.5.16.sh – prepare new UI/keys and safe defaults
set -eu
echo "[migrate] 0.5.15 → 0.5.16 starting"

# Ensure config root
mkdir -p /etc/ha-vrrp

# Add any new UCI keys (idempotent)
uci -q batch <<'EOF'
set ha_vrrp.core=core
set ha_vrrp.core.cluster_name='YOURCLUSTER'
set ha_vrrp.core.fw_backend='auto'
set ha_vrrp.core.ka_backend='auto'
set ha_vrrp.core.dhcp_backend='auto'
set ha_vrrp.core.net_backend='auto'
EOF
uci -q commit ha_vrrp || true

# No destructive changes; views are added by package files
echo "[migrate] done"
