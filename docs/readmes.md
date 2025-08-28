# README (Übersicht)

## 0.1.0.md

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

## 0.2.0.md

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

## 0.3.0.md

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

## 0.3.0a.md

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

## 0.4.0.md

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

## 0.4.0a.md

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

## 0.5.0.md

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

## 0.5.1.md

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

## 0.5.2.md

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

## 0.5.3.md

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

## 0.5.4.md

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

## 0.5.5.md

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

## 0.5.6.md

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

## 0.5.7.md

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

## 0.5.8.md

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

## 0.5.9.md

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

## 0.5.10.md

# openwrt-ha-vrrp v0.5.10

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Key-Management UI initiiert; erste Sync-Mechanik (scp).

## 0.5.11.md

# openwrt-ha-vrrp v0.5.11

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
IPKs erstmals; Controller-Fehler beim LuCI-Laden beobachtet.

## 0.5.12.md

# openwrt-ha-vrrp v0.5.12

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Installer/Uninstaller ergänzt; bekannter Uninstaller-Bug.

## 0.5.13.md

# openwrt-ha-vrrp v0.5.13

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Fixes im Installer; UI teils leer; Cache nötig.

## 0.5.14.md

# openwrt-ha-vrrp v0.5.14

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Menü sichtbar; UI zeigte JSON statt CBI; Uninstaller unvollständig.

## 0.5.15.md

# openwrt-ha-vrrp v0.5.15

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Migrationspfad skizziert; LuCI stabilisiert.

## 0.5.16.md

# openwrt-ha-vrrp v0.5.16

**Datum:** 2025-08-24 14:23:35 

## Kurzbeschreibung
Controller/CBI/Views bereinigt; Overview-500 behoben; Settings erweitert.

## 0.5.16-004.md

# openwrt-ha-vrrp v0.5.16-004

**Datum:** 2025-08-24 03:58:35

## Kurzbeschreibung
Bugfix für LuCI-Views (Overview 500-Fehler behoben), erweiterte Settings (SSH-Backend, CIDR neben Peer-Host),
Sync-Uploads (lokaler privater/öffentlicher Key, Peer-Pub), Versionsanzeige in Overview, Default-Config erweitert.

## Wichtige Änderungen
- Overview-Template nutzt `self.map.uci` statt `m` → behebt 500 Internal Server Error auf 19.07.
- Anzeige der Addon-Version und des SSH-Backends in der Übersicht.
- Settings: neue Felder `ssh_backend` (auto/openssh/dropbear) und `peer_netmask_cidr` (CIDR, z.B. 24).
- Sync: Upload von lokalem privaten Schlüssel, lokalem Pub und Peer-Pub (Trust).
- Instances: kleine Beschreibung (Stub).
- Default `/etc/config/ha_vrrp`: `ssh_backend`, `peer_netmask_cidr`, `cluster_version` ergänzt.

## Hinweise
- Für OpenWrt 19.07 bleibt das UI serverseitiges CBI ohne moderne `L.ui`-Widgets; vermeidet den `L.ui is undefined`-Fehler.
- Logs zu Sync-Aktionen: `/tmp/ha_vrrp_*`.

## 0.5.16-007_reviewfix17_a4_fix2.md

# openwrt-ha-vrrp – Release Notes – v0.5.16‑007_reviewfix17_a4_fix2

**Datum:** 2025‑08‑28

## Features

Diese Version fügt keine neuen Funktionen hinzu, sondern verbessert die Dokumentationsinfrastruktur und das Workflow‑Management:

* Ein neues Manager‑Skript (`manage_docs.sh`/`manage_docs.ps1`) vereinfacht die Pflege der versionsspezifischen Markdown‑Dateien und ermöglicht es, neue Versionen mit einem Befehl zu finalisieren.
* Die Readme‑Dateien aus früheren Releases wurden in das strukturierte Verzeichnis `docs/readmes` migriert; alte Dateinamen mit dem Präfix `README_` wurden durch den reinen Versionsstring ersetzt.  Zusätzliche Entwürfe können in `docs/readmeas` abgelegt werden.

## Changelog

Bitte beachten Sie den ausführlichen Changelog in `docs/changelogs/0.5.16-007_reviewfix17_a4_fix2.md` für Details zu allen Änderungen.

## Installation / Uninstallation / Build

Die Installations- und Uninstallationsscripte bleiben unverändert gegenüber der Vorversion.  Entwickler:innen können das neue Manager‑Skript nutzen, um neue Releases zu erstellen und die Dokumentation zu aktualisieren.  Der reguläre Build‑Prozess via `helper_build_package.sh` erzeugt weiterhin das Pakettarball in `dist/`.
## 0.5.16-007_reviewfix17_a4_fix3.md

# openwrt-ha-vrrp – Release Notes – v0.5.16‑007_reviewfix17_a4_fix3

**Datum:** 2025‑08‑28

## Features

Diese Version führt zwei kleine CLI‑Werkzeuge ein:

* **scripts/readme.sh** – Ein Helferskript, das die README‑Teilfassung der aktuellen oder einer angegebenen Version auf der Kommandozeile ausgibt.  Es erkennt sowohl reine Versionsbezeichnungen als auch Paket‑ oder IPK‑Dateinamen und extrahiert den Versionsstring automatisch.
* **scripts/help.sh** – Eine kurze Übersicht über die wichtigsten Werkzeuge des Projekts, insbesondere wie `manage_docs.sh` und `readme.sh` verwendet werden.

## Changelog

Die vollständige Liste der Änderungen finden Sie in `docs/changelogs/0.5.16-007_reviewfix17_a4_fix3.md`.

## Installation / Uninstallation / Build

Es gibt keine Änderungen an den Installations- oder Uninstallationsscripten gegenüber der Vorversion.  Entwickler:innen können `manage_docs.sh` nutzen, um weitere Einträge hinzuzufügen und neue Versionen zu erstellen.  Für den Build‑Prozess wird weiterhin `helper_build_package.sh` verwendet.


## 0.5.16-007_reviewfix17_a4_fix4.md

# openwrt-ha-vrrp – Release Notes – v0.5.16‑007_reviewfix17_a4_fix4

**Datum:** 2025‑08‑28

## Features

Diese Version fügt zwei neue Helferskripte hinzu, die den Umgang mit
heruntergeladenen Release‑Archiven und IPK‑Paketen vereinfachen:

* **copy_downloads.sh / copy_downloads.ps1** – Durchsucht das
  Download‑Verzeichnis nach OpenWRT‑HA‑VRRP‑Archiven und den zugehörigen
  IPK‑Paketen.  Gefundene Dateien werden in das lokale
  `_workspace` kopiert und dort in `vrrp-repo` bzw. `vrrp-ipk-repo`
  abgelegt.

* **upload_nodes.sh / upload_nodes.ps1** – Überträgt die im
  Workspace gespeicherten Pakete via `scp` an eine oder mehrere
  OpenWrt‑Nodes.  Die Zielverzeichnisse `/root/vrrp-repo` und
  `/root/vrrp-ipk-repo` werden automatisch erstellt.

Diese Helfer werden über die zentralen Wrapper `script.sh`,
`script.ps1` und `script.bat` mit den neuen Subkommandos
`copy_downloads` und `upload_nodes` angesprochen.  Dadurch wird der
Installations‑ und Update‑Prozess insbesondere in Multi‑Node‑Setups
deutlich effizienter.

## Changelog

Die vollständige Liste der Änderungen ist in
`docs/changelogs/0.5.16-007_reviewfix17_a4_fix4.md` dokumentiert.

## Installation / Uninstallation / Build

Die bestehenden Installations‑ und Uninstallationsskripte bleiben
unverändert.  Zur Vorbereitung eines neuen Releases im Dev‑Modus
können Entwickler:innen nun mit `copy_downloads` die zuletzt
heruntergeladenen Artefakte einsammeln und anschließend mit
`upload_nodes` auf die gewünschten Router verteilen.  Der eigentliche
Installer wird danach wie gewohnt auf dem Zielsystem ausgeführt.
