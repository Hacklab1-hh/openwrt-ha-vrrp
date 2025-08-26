#!/bin/sh
# Uninstall helper: stops services and removes our files (not keepalived package).
set -eu

echo "[uninstall] Stopping services..."
/etc/init.d/ha-vrrp stop >/dev/null 2>&1 || true
/etc/init.d/keepalived stop >/dev/null 2>&1 || true

echo "[uninstall] Removing files..."
rm -f /etc/init.d/ha-vrrp
rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -f /usr/sbin/ha-vrrp-apply
rm -rf /usr/libexec/ha-vrrp

# keep config by default; uncomment to remove:
# rm -f /etc/config/ha_vrrp

echo "[uninstall] Note: keepalived package is still installed. Remove via 'opkg remove keepalived' if desired."
