# README – Uninstaller

**Shebang:** `#!/bin/sh`

## Zweck (heuristisch)
Automatisches Setup/Teardown bzw. Build/Install der HA-VRRP Komponenten.

## Erkannte Kernbefehle
```
/etc/init.d/ha-vrrp stop >/dev/null 2>&1 || true
/etc/init.d/keepalived stop >/dev/null 2>&1 || true
rm -f /etc/init.d/ha-vrrp
rm -f /etc/hotplug.d/iface/95-ha-vrrp-apply
rm -f /usr/sbin/ha-vrrp-apply
rm -rf /usr/libexec/ha-vrrp
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
