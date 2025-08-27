# Installer/Uninstaller – v0.5.13

Diese Version liefert robuste Skripte, die die Repository-Position **automatisch** erkennen und wahlweise **IPKs** installieren oder eine **Overlay-Kopie** vornehmen.

## Nutzung

### Installation
```sh
cd openwrt-ha-vrrp-0.5.13/scripts
sh ./install_v0.5.13.sh
```

Was passiert:
- Sucht IPKs in `../ipk_0_5_13`, `ipk_0_5_13`, `/tmp` und im Repo Root.
- Falls gefunden → `opkg install` beider IPKs.
- Sonst Overlay-Kopie:
  - `ha-vrrp/files/*` → nach `/`
  - `luci-app-ha-vrrp/luasrc/*` → nach `/usr/lib/lua/luci/`
- Services werden (re)aktiviert, LuCI neu gestartet, optional `keepalived` neu gestartet, `ha-vrrp-apply` ausgeführt.

### Uninstallation
```sh
cd openwrt-ha-vrrp-0.5.13/scripts
sh ./uninstall_v0.5.13.sh            # Konfiguration bleibt erhalten
sh ./uninstall_v0.5.13.sh --purge    # inkl. Entfernen von /etc/config/ha_vrrp
```

## Typische Fehlerbehebung

- **„Command failed: Not found“** während der Overlay-Kopie:  
  Ursache war häufig ein harter, nicht existierender Pfad. In v0.5.13 nutzt der Installer den Pfad des Skripts selbst (kein Hardcoding).

- **LuCI lädt nicht / Dispatcher-Fehler**:  
  In v0.5.12 bereits gefixed (quote-safe Controller). Stelle sicher, dass `/usr/lib/lua/luci/controller/ha_vrrp.lua` aus v0.5.12+ stammt.

## Hinweise
- Abhängigkeiten (werden per `Depends` durch IPKs gezogen): `keepalived`, `ip-full`, `uci`, `uhttpd`, `luci-base`, `luci-compat`.
- Nach jeder Installation empfiehlt sich:
```sh
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/uhttpd restart
```
