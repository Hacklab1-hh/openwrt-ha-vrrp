#!/bin/sh
# Installer for openwrt-ha-vrrp (OpenWrt 19.07)
set -eu

need() {
  which "$1" >/dev/null 2>&1
}

echo "[install] Checking dependencies (opkg, keepalived, ip-full, uci, uhttpd, luci)..."

if ! need opkg; then
  echo "[install] ERROR: opkg not found. Are you on OpenWrt?"; exit 1
fi

opkg update >/dev/null 2>&1 || true

# Core deps
for p in keepalived ip-full uci; do
  opkg list-installed | grep -q "^$p " || opkg install "$p"
done

# Optional but nice
for p in arping luci uhttpd; do
  opkg list-installed | grep -q "^$p " || opkg install "$p" || true
done

# Deploy files (do not overwrite existing /etc/config/ha_vrrp)
echo "[install] Deploying files..."
SRC_DIR="$(pwd)/files"

# Create dirs
mkdir -p /etc/config /etc/init.d /etc/uci-defaults /usr/libexec/ha-vrrp /usr/sbin /etc/hotplug.d/iface

# Config (preserve existing)
if [ ! -f /etc/config/ha_vrrp ]; then
  cp "$SRC_DIR/etc/config/ha_vrrp" /etc/config/ha_vrrp
else
  echo "[install] /etc/config/ha_vrrp exists, keeping it."
fi

# The rest (overwrite allowed; they are ours)
cp "$SRC_DIR/etc/init.d/ha-vrrp" /etc/init.d/ha-vrrp
cp "$SRC_DIR/etc/uci-defaults/95_ha_vrrp_defaults" /etc/uci-defaults/95_ha_vrrp_defaults
cp "$SRC_DIR/etc/hotplug.d/iface/95-ha-vrrp-apply" /etc/hotplug.d/iface/95-ha-vrrp-apply
cp "$SRC_DIR/usr/sbin/ha-vrrp-apply" /usr/sbin/ha-vrrp-apply
cp "$SRC_DIR/usr/libexec/ha-vrrp/ensure_vlan.sh" /usr/libexec/ha-vrrp/ensure_vlan.sh
cp "$SRC_DIR/usr/libexec/ha-vrrp/notify_master.sh" /usr/libexec/ha-vrrp/notify_master.sh
cp "$SRC_DIR/usr/libexec/ha-vrrp/notify_backup.sh" /usr/libexec/ha-vrrp/notify_backup.sh

# Permissions
chmod +x /etc/init.d/ha-vrrp
chmod +x /etc/uci-defaults/95_ha_vrrp_defaults || true
chmod +x /etc/hotplug.d/iface/95-ha-vrrp-apply
chmod +x /usr/sbin/ha-vrrp-apply
chmod +x /usr/libexec/ha-vrrp/*.sh

# Enable services
/etc/init.d/keepalived enable || true
/etc/init.d/ha-vrrp enable || true

# Apply defaults (once)
if [ -x /etc/uci-defaults/95_ha_vrrp_defaults ]; then
  /etc/uci-defaults/95_ha_vrrp_defaults || true
  rm -f /etc/uci-defaults/95_ha_vrrp_defaults || true
fi

# Render keepalived.conf and start
/usr/libexec/ha-vrrp/ensure_vlan.sh || true
/usr/sbin/ha-vrrp-apply || true

/etc/init.d/keepalived restart || true
/etc/init.d/ha-vrrp start || true

# LuCI refresh
/etc/init.d/rpcd restart || true
/etc/init.d/uhttpd restart || true

echo ""
echo "[install] Done."
echo "Next steps:"
echo "  - Set VRID, VIP, iface(+vlan) and unicast src/peers via UCI or LuCI"
echo "  - Then:  /etc/init.d/ha-vrrp restart"
