## v0.1.0

-

---

## v0.2.0

-

---

## v0.3.0

Peer-Discovery/Sync/Dual-Status

---

## v0.4.0

Peer-Discovery/Sync/Dual-Status + WAN Health Checks

---

## v0.3.0a

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

---

## v0.4.0a

-

---

## v0.5.0

- IPv6 Healthchecks (wan6) via track_script
- Multi-VIP (`vip_list`)
- Peer Discovery (CIDR/min/max)
- Auto-Sync Daemon (procd) + Sync-Button
- Cleaned LuCI Status/Renderer

---

## v0.5.1

- Rückwärtskompatibel zu 0.2.0 (core→instance Fallback)
- Stabilisierung Discovery/Sync
- Doku & Makefiles aktualisiert

---

## v0.5.2

- `examples/` mit UCI-Apply-Skripten (LamoboR1-1/2)
- Heartbeat VLAN 200 Beispiele

---

## v0.5.3

- `README_0.1.0` aus Ur-README übernommen
- Version-Bumps in Package-Makefiles

---

## v0.5.4

- Legacy-kompatible Installer/Uninstaller (Ur-Verhalten)
- Makefile-Targets `legacy-install`/`legacy-uninstall`

---

## v0.5.5

- Vollständige `etc/` & `usr/` Struktur im Paketlayout
- Mapping-Doku `README-file-mapping.md`

---

## v0.5.6

- LuCI: Liste `Network/Interfaces` inkl. DHCP-Status
- Button „VRRP anlegen“ je Interface

---

## v0.5.7

- Peer-Verwaltung in LuCI: Auto-Discover, Discover(Liste), Manuell + optional `unicast_peer` für Instanzen

---

## v0.5.8

- Discover: Interface-Auswahl in UI, **HEARTBEAT** vorgewählt

---

## v0.5.9

- Vollständige, versionierte Dokumentation pro Release (README_/CHANGELOG_/FEATURES_/INSTALL_) und Masterdateien
