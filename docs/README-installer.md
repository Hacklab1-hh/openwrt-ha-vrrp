# README – Installer

**Shebang:** `#!/bin/sh`

## Zweck (heuristisch)
Automatisches Setup/Teardown bzw. Build/Install der HA-VRRP Komponenten.

## Erkannte Kernbefehle
```
opkg update >/dev/null 2>&1 || true
opkg list-installed | grep -q "^$p " || opkg install "$p"
opkg list-installed | grep -q "^$p " || opkg install "$p" || true
cp "$SRC_DIR/etc/config/ha_vrrp" /etc/config/ha_vrrp
cp "$SRC_DIR/etc/init.d/ha-vrrp" /etc/init.d/ha-vrrp
cp "$SRC_DIR/etc/uci-defaults/95_ha_vrrp_defaults" /etc/uci-defaults/95_ha_vrrp_defaults
cp "$SRC_DIR/etc/hotplug.d/iface/95-ha-vrrp-apply" /etc/hotplug.d/iface/95-ha-vrrp-apply
cp "$SRC_DIR/usr/sbin/ha-vrrp-apply" /usr/sbin/ha-vrrp-apply
cp "$SRC_DIR/usr/libexec/ha-vrrp/ensure_vlan.sh" /usr/libexec/ha-vrrp/ensure_vlan.sh
cp "$SRC_DIR/usr/libexec/ha-vrrp/notify_master.sh" /usr/libexec/ha-vrrp/notify_master.sh
cp "$SRC_DIR/usr/libexec/ha-vrrp/notify_backup.sh" /usr/libexec/ha-vrrp/notify_backup.sh
/etc/init.d/keepalived enable || true
/etc/init.d/ha-vrrp enable || true
rm -f /etc/uci-defaults/95_ha_vrrp_defaults || true
/usr/libexec/ha-vrrp/ensure_vlan.sh || true
/usr/sbin/ha-vrrp-apply || true
/etc/init.d/keepalived restart || true
/etc/init.d/ha-vrrp start || true
/etc/init.d/rpcd restart || true
/etc/init.d/uhttpd restart || true
```

## Angepasste Nutzung (v0.5.2)
- Stelle sicher, dass die Paketverzeichnisse unter `package/ha-vrrp` und `package/luci-app-ha-vrrp` im OpenWrt-Buildroot liegen.
- Für Installation verwende bevorzugt die IPKs aus dem Build:
  ```sh
  opkg install /tmp/ha-vrrp_0.5.2-1_*.ipk
  opkg install /tmp/luci-app-ha-vrrp_0.5.2-1_*.ipk
  /etc/init.d/ha-vrrp enable
  /etc/init.d/ha-vrrp start
  ```
- Für Uninstall:
  ```sh
  /etc/init.d/ha-vrrp stop
  opkg remove luci-app-ha-vrrp ha-vrrp
  ```
