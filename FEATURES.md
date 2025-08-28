# FEATURES

## 0.5.16-007_reviewfix14e.md

# 0.5.16-007_reviewfix14e — Features
- Ein-Klick Update auf dem Node (Git>lokal)
- Rollback/Purge-Funktionen
- Cache/Symlink-Layout stabilisiert

## 0.5.16-007_reviewfix14b2b.md

# 0.5.16-007_reviewfix14b2b — Features
- Einheitliche Root-Erkennung
- Self-Test

## 0.5.16-007_reviewfix14b1.md

# 0.5.16-007_reviewfix14b1 — Features
- Vollständiger Upgradegraph bis 14c im Repository verankert
- Definierte Migrationen & Rollback für 14/14a/14b/14c
- Verbesserte Nachvollziehbarkeit der Update-Pfade (Tooling-Unterstützung)

## 0.5.16.md

# Features v0.5.16

- Controller/CBI/Views bereinigt; Overview-500 behoben; Settings erweitert.
## 0.5.15.md

# Features v0.5.15

- Migrationspfad skizziert; LuCI stabilisiert.
## 0.5.14.md

# Features v0.5.14

- Menü sichtbar; UI zeigte JSON statt CBI; Uninstaller unvollständig.
## 0.5.13.md

# Features v0.5.13

- Fixes im Installer; UI teils leer; Cache nötig.
## 0.5.12.md

# Features v0.5.12

- Installer/Uninstaller ergänzt; bekannter Uninstaller-Bug.
## 0.5.11.md

# Features v0.5.11

- IPKs erstmals; Controller-Fehler beim LuCI-Laden beobachtet.
## 0.5.10.md

# Features v0.5.10

- Key-Management UI initiiert; erste Sync-Mechanik (scp).
## 0.5.9.md

# Features v0.5.9

- Erweiterte Doku-/Changelog-Struktur eingeführt.
## 0.5.8.md

# Features – v0.5.8

- Discover: Interface-Auswahl in UI, **HEARTBEAT** vorgewählt

## 0.5.7.md

# Features – v0.5.7

- Peer-Verwaltung in LuCI: Auto-Discover, Discover(Liste), Manuell + optional `unicast_peer` für Instanzen

## 0.5.6.md

# Features – v0.5.6

- LuCI: Liste `Network/Interfaces` inkl. DHCP-Status
- Button „VRRP anlegen“ je Interface

## 0.5.5.md

# Features – v0.5.5

- Vollständige `etc/` & `usr/` Struktur im Paketlayout
- Mapping-Doku `README-file-mapping.md`

## 0.5.4.md

# Features – v0.5.4

- Legacy-kompatible Installer/Uninstaller (Ur-Verhalten)
- Makefile-Targets `legacy-install`/`legacy-uninstall`

## 0.5.3.md

# Features – v0.5.3

- `README_0.1.0` aus Ur-README übernommen
- Version-Bumps in Package-Makefiles

## 0.5.2.md

# Features – v0.5.2

- `examples/` mit UCI-Apply-Skripten (LamoboR1-1/2)
- Heartbeat VLAN 200 Beispiele

## 0.5.1.md

# Features – v0.5.1

- Rückwärtskompatibel zu 0.2.0 (core→instance Fallback)
- Stabilisierung Discovery/Sync
- Doku & Makefiles aktualisiert

## 0.5.0.md

# Features – v0.5.0

- IPv6 Healthchecks (wan6) via track_script
- Multi-VIP (`vip_list`)
- Peer Discovery (CIDR/min/max)
- Auto-Sync Daemon (procd) + Sync-Button
- Cleaned LuCI Status/Renderer

## 0.4.0a.md

# Features – v0.4.0a

-

## 0.4.0.md

# Features – v0.4.0

Peer-Discovery/Sync/Dual-Status + WAN Health Checks

## 0.3.0a.md

# Features – v0.3.0a

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

## 0.3.0.md

# Features – v0.3.0

Peer-Discovery/Sync/Dual-Status

## 0.2.0.md

# Features – v0.2.0

-

## 0.1.0.md

# Features – v0.1.0

-

