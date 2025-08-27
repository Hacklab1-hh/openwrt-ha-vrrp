# openwrt-ha-vrrp – Release Notes – v0.1.0

**Datum:** 2025-08-23

## Features
- (keine Daten gefunden)

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
echo "[install] Checking dependencies (opkg, keepalived, ip-full, uci, uhttpd, luci)..."
if ! need opkg; then
echo "[install] ERROR: opkg not found. Are you on OpenWrt?"; exit 1
opkg update >/dev/null 2>&1 || true
for p in keepalived ip-full uci; do
opkg list-installed | grep -q "^$p " || opkg install "$p"
opkg list-installed | grep -q "^$p " || opkg install "$p" || true
mkdir -p /etc/config /etc/init.d /etc/uci-defaults /usr/libexec/ha-vrrp /usr/sbin /etc/hotplug.d/iface
cp "$SRC_DIR/etc/init.d/ha-vrrp" /etc/init.d/ha-vrrp
cp "$SRC_DIR/etc/uci-defaults/95_ha_vrrp_defaults" /etc/uci-defaults/95_ha_vrrp_defaults
chmod +x /etc/uci-defaults/95_ha_vrrp_defaults || true
if [ -x /etc/uci-defaults/95_ha_vrrp_defaults ]; then
/etc/uci-defaults/95_ha_vrrp_defaults || true
rm -f /etc/uci-defaults/95_ha_vrrp_defaults || true
```

### Uninstaller (Kerndefinition)
```
echo "[uninstall] Note: keepalived package is still installed. Remove via 'opkg remove keepalived' if desired."
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `LUCI_DEPENDS`
- `LUCI_TITLE`
- `PKG_LICENSE`
