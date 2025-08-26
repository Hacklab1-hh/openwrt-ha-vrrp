# openwrt-ha-vrrp – Release Notes – v0.5.15

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

---

# openwrt-ha-vrrp – Release Notes – v0.2.0

**Datum:** 2025-08-23

## Features
- (keine Daten gefunden)

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_MAINTAINER`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`
- `LUCI_DEPENDS`
- `LUCI_PKGARCH`
- `LUCI_TITLE`
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`

---

# openwrt-ha-vrrp – Release Notes – v0.3.0

**Datum:** 2025-08-23

## Features
Peer-Discovery/Sync/Dual-Status

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_NAME`
- `PKG_VERSION`
- `PKG_NAME`
- `PKG_VERSION`

---

# openwrt-ha-vrrp – Release Notes – v0.4.0

**Datum:** 2025-08-23

## Features
Peer-Discovery/Sync/Dual-Status + WAN Health Checks

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_NAME`
- `PKG_VERSION`
- `PKG_NAME`
- `PKG_VERSION`

---

# openwrt-ha-vrrp – Release Notes – v0.3.0a

**Datum:** 2025-08-23

## Features
- UCI-driven Keepalived (VRRP, unicast)
- Multi-instance, optional VLAN per instance
- Peer discovery (HEARTBEAT scan)
- Peer sync (SSH keys + push /etc/config/*)
- Dual-node LuCI status

Build in OpenWrt SDK:
  cp -a ha-vrrp <buildroot>/package/
  cp -a luci-app-ha-vrrp <buildroot>/package/
  make package/ha-vrrp/compile V=s
  make package/luci-app-ha-vrrp/compile V=s

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`
- `LUCI_DEPENDS`
- `LUCI_PKGARCH`
- `LUCI_TITLE`
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`

---

# openwrt-ha-vrrp – Release Notes – v0.4.0a

**Datum:** 2025-08-23

## Features
- (keine Daten gefunden)

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`
- `LUCI_DEPENDS`
- `LUCI_PKGARCH`
- `LUCI_TITLE`
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`

---

# openwrt-ha-vrrp – Release Notes – v0.5.0

**Datum:** 2025-08-23

## Features
- IPv6 Healthchecks (wan6) via track_script
- Multi-VIP (`vip_list`)
- Peer Discovery (CIDR/min/max)
- Auto-Sync Daemon (procd) + Sync-Button
- Cleaned LuCI Status/Renderer

## Changelog
- Konsolidiert 0.3.0 + 0.4.0-Funktionalität; neue Scripts `check_wan6_gw.sh`, `ha-vrrp-autosync`

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.0
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.1

**Datum:** 2025-08-23

## Features
- Rückwärtskompatibel zu 0.2.0 (core→instance Fallback)
- Stabilisierung Discovery/Sync
- Doku & Makefiles aktualisiert

## Changelog
- Renderer robust gegen fehlende Instanzen; Status JSON verbessert

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.1
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.2

**Datum:** 2025-08-23

## Features
- `examples/` mit UCI-Apply-Skripten (LamoboR1-1/2)
- Heartbeat VLAN 200 Beispiele

## Changelog
- Quickstart-Skripte `apply-LamoboR1-*.sh`

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.2
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.3

**Datum:** 2025-08-23

## Features
- `README_0.1.0` aus Ur-README übernommen
- Version-Bumps in Package-Makefiles

## Changelog
- Installer/Uninstaller auf 0.5.3 gehoben

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.3
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.4

**Datum:** 2025-08-23

## Features
- Legacy-kompatible Installer/Uninstaller (Ur-Verhalten)
- Makefile-Targets `legacy-install`/`legacy-uninstall`

## Changelog
- Paketversion 0.5.4, Doku ergänzt

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.4
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.5

**Datum:** 2025-08-23

## Features
- Vollständige `etc/` & `usr/` Struktur im Paketlayout
- Mapping-Doku `README-file-mapping.md`

## Changelog
- Paketversion 0.5.5

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.5
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.6

**Datum:** 2025-08-23

## Features
- LuCI: Liste `Network/Interfaces` inkl. DHCP-Status
- Button „VRRP anlegen“ je Interface

## Changelog
- Controller: `listifaces`, `createinst`

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.6
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.7

**Datum:** 2025-08-23

## Features
- Peer-Verwaltung in LuCI: Auto-Discover, Discover(Liste), Manuell + optional `unicast_peer` für Instanzen

## Changelog
- Controller: `discover_adv`, `autodiscover`, `setpeer`; Status JSON enthält `instance_sections`

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.7
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.8

**Datum:** 2025-08-23

## Features
- Discover: Interface-Auswahl in UI, **HEARTBEAT** vorgewählt

## Changelog
- `autodiscover` nutzt optional gewähltes Interface/Subnetz

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.8
# (Keine konkreten Skripte im Archiv erkannt)
```

---

# openwrt-ha-vrrp – Release Notes – v0.5.9

**Datum:** 2025-08-23

## Features
- Vollständige, versionierte Dokumentation pro Release (README_/CHANGELOG_/FEATURES_/INSTALL_) und Masterdateien

## Changelog
- Automatisch generierte Doku aus Archiv-PARSING & Chat-Notizen

## Installation / Uninstallation / Build
### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.9
# (Keine konkreten Skripte im Archiv erkannt)
```


## v0.5.10
- **Update-Pfad** (maschinenlesbar): `docs/update-path.json`, `docs/update-path.yaml`, `docs/UPDATE_PATH.csv`, `docs/UPDATE_EDGES.csv`.
- Helper: `scripts/upgrade-path.sh FROM TO` listet die Zwischenversionen.


## v0.5.12
- Fix: LuCI-Controller Quoting/Syntax korrigiert (kein ccache/dispatcher-Error mehr).
