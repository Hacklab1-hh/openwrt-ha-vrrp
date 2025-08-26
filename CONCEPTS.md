# Concepts — OpenWRT HA VRRP (Serie 0.5.16)
**Stand:** 2025-08-24

Dieses Dokument fasst die konzeptionellen Bausteine des Addons zusammen.

## Ziele
- Hochverfügbarkeit per VRRP/Keepalived (Master/Backup) mit klarer Trennung von **UI**, **Core** und **Backends**.
- Reproduzierbare Upgrades dank versionierter **Installer/Uninstaller/Manager** und **Migrationsscripts**.
- Minimal-invasive Integration in LuCI (nur CBI, keine L.ui-Abhängigkeiten).

## Schichtenmodell
1. **UI (LuCI / CBI):** `controller/`, `model/cbi/`, `view/` — zeigt Status und Settings, triggert Aktionen.
2. **Core Scripts:** `/usr/libexec/ha-vrrp/` — Discover/Sync/Keys/etc.
3. **Lib & Migrations:** `/usr/lib/ha-vrrp/lib/`, `/usr/lib/ha-vrrp/scripts/` — Helper, Upgrades.
4. **Konfiguration:** `/etc/config/ha_vrrp`, `/etc/ha-vrrp/` — Persistenz, Keys, Marker.

## Wichtige Konzepte
- **Discover:** Peers anhand eines einstellbaren CIDR-Bereichs pingen; Ergebnisse nach `/tmp/ha-vrrp-discover.json`.
- **SSH Backend:** `auto|openssh|dropbear` — Erkennung bevorzugt OpenSSH (ed25519), Fallback Dropbear (rsa).
- **Sync:** `auto|scp|rsync` — Transport für Config/Keys; `keysync`/`syncpush` als ausführende Skripte.
- **CIDR-Scan:** In `Settings` konfigurierbar (`peer_scan_cidr`), per View ausführbar.
- **Version Marker:** `/usr/lib/ha-vrrp/VERSION` — zur Detection im Manager.

## Upgrade-Philosophie
- **Pre-Migration vor Dateikopie**: Installer rufen versionierte `migrate_*.sh` vor dem Kopieren auf.
- **Idempotent & Rückwärtsverträglich**: Migrationen dürfen mehrfach laufen und alte Layouts erkennen.
- **Dokumentiert**: Deltas & bekannte Probleme in `docs/CHANGELOG_*` und `docs/KNOWN_ISSUES_*`.

## Diagnose
- Protokolle in `/tmp/ha_vrrp_*` prüfen.
- LuCI neu laden: Cache löschen, `rpcd`/`uhttpd` neustarten.
- Lua-Validierung: `lua -e 'dofile("/pfad/datei.lua")'`.

---

## Installer / Uninstaller / Manager — Details

**Installer (versioniert `installer-v<ver>.sh`)**
- Ablauf: *Backup* → *Pre-Migration(en)* → *Dateikopie* → *Berechtigungen* → *VERSION schreiben* → *LuCI Refresh*.
- Pre-Migrations werden **vor** dem Kopieren aufgerufen, z. B.:
  - `migrate_0.5.16_002_to_007.sh` (Strukturangleichungen)
  - `migrate_0.5.16_007_to_008.sh` (Einführung CIDR/ssh_backend defaults)
- Generische Wrapper: `installer-v0.5.16.sh` → delegiert auf **0.5.16-009**, `installer.sh` ruft den Serien-Installer.

**Uninstaller (versioniert `uninstaller-v<ver>.sh`)**
- Entfernt LuCI-Controller/CBI/Views sowie `/usr/libexec/ha-vrrp` und `/usr/lib/ha-vrrp` (inkl. VERSION).
- Führt `rpcd`/`uhttpd`-Neustart und Cache-Flush aus.
- Generische Wrapper: `uninstaller-v0.5.16.sh`, `uninstaller.sh`.

**Manager (`ha-vrrp-manage.sh`)**
- Befehle: `detect` (liest `/usr/lib/ha-vrrp/VERSION` bzw. `uci get ha_vrrp.core.cluster_version`), `install`, `uninstall`, `update`.
- `update`: *Backup* → `install <Ziel>` → *Migrationen* → *LuCI Refresh*.
- Shortcut: `update-to-latest.sh` → Update auf **0.5.16-009**.

## UI — Struktur & Routen (LuCI/CBI)
- Controller: `luci.controller.ha_vrrp` registriert Menüs:
  - `/admin/services/ha_vrrp/overview` (CBI `model/cbi/ha_vrrp/overview.lua`, View `view/ha_vrrp/overview.htm`)
  - `/admin/services/ha_vrrp/settings` (CBI `.../settings.lua`)
  - (optional) Discover: `/admin/services/ha_vrrp/discoverui` + API `discoverrun`/`discoverdata`
  - API: `/admin/services/ha_vrrp/api/status` (Ping/Peer JSON)
- Templates verwenden Guard: `local data = self and self.map and self.map.uci or {}` → robust gegen 19.07/CBI-Kanten.

## Backend — Verzeichnisse & Aufgaben
- `/usr/libexec/ha-vrrp/`: Ausführbare Aktionen (`discover_scan.sh`, `sync/`, `rpc/`).
- `/usr/lib/ha-vrrp/scripts/`: **Migrationen** & Helper.
- `/etc/ha-vrrp/`: Keys, Backups, ggf. SSH-Config; **Backups** als `backup-<timestamp>.tgz`.
- `/usr/lib/ha-vrrp/VERSION`: installierter Stand (vom Installer gesetzt).

## Datenfluss (Beispiel)
1. UI `Settings.lua` schreibt UCI (`ha_vrrp.core.*`), z. B. `ssh_backend`, `peer_scan_cidr`.
2. Discover-View ruft `discover_scan.sh` → scannt CIDR → schreibt `/tmp/ha-vrrp-discover.json`.
3. Overview liest `self.map.uci` (aus `CBI`) und zeigt Quick-Status (Peer/Ping/Backend/Version).

## Migrationen — Katalog (aktueller Stand)
- `migrate_0.5.16_002_to_007.sh` — Platzhalter: zielt auf Verzeichnisumzüge & Namensangleichung.
- `migrate_0.5.16_007_to_008.sh` — Platzhalter: führt neue Defaults (CIDR/SSH) ein und passt ggf. Keys/Config an.
- Weitere Migrationen werden als `migrate_<from>_to_<to>.sh` ergänzt und sind **idempotent** zu designen.



CONCEPTS — openwrt-ha-vrrp

Dieses Dokument fasst die im Projekt (und im Chat) diskutierten Konzepte zusammen und dient als
übersichtlicher Einstieg für Nutzer:innen und Entwickler:innen.

Ziel

High-Availability (HA) für OpenWrt-Router (ab 19.07) mit VRRP (via keepalived) und einem
leicht bedienbaren LuCI-Frontend. Ein aktiver Master führt die .254-VIP je Segment,
ein Standby übernimmt bei Ausfall. Heartbeat über dediziertes Interface/VLAN (z. B. HEARTBEAT VLAN 200).

Leitprinzipien

Modularität über Backends: Firewall (iptables/nft), DHCP/DNS (dnsmasq-Varianten), Netz (swconfig/DSA),
SSH (dropbear/openssh), Keepalived-Versionen – alles als austauschbare „Backend-Adapter“.

OS-Versionskompatibilität: Funktionen so kapseln, dass 19.07, 21.02, 22.03, 23.05 etc. unterstützt
werden, ohne dass Nutzer:innen unterschiedliche Pakete benötigen.

Konfig vor Code: Defaults und Settings liegen konsistent in /etc/config/ha_vrrp und werden durch
LuCI-CBI verwaltet. Hardcoding wird vermieden.

Klares Upgrade/Migrationsmodell: Strukturelle Änderungen gehen über Migration-Skripte (z. B.
migratefrom0.5.14to0.5.15.sh) und nicht über ad-hoc Shell-Kommandos im Installer.

Discover & Sync: Nodes finden/prüfen sich via HEARTBEAT/LAN, Konfigurationen werden wahlweise per
SCP/rsync synchronisiert; SSH-Schlüsselhandling ist Teil des UIs.

Begriffe

Cluster-Nodes: z. B. LamoboR1-1 und LamoboR1-2. Jeder Node hat seine Basis-IP (z. B. 192.168.1.1/2).

VIP: Pro Segment ist .254 die Cluster-VIP des aktiven Masters (z. B. 192.168.1.254).

HEARTBEAT: eigenes Interface/VLAN (typisch VLAN 200, z. B. 192.168.254.1/24). Dient Discover, Health & Sync.

ADMINLAN/LAN/GAST: weitere Segmente; die Konvention „untere IPs sind Node-IPs, .254 ist VIP“.

LuCI-UI (CBI) – Architektur-Entscheidung

Ab v0.5.16 wurden die LuCI-Views gezielt auf serverseitige CBI-Formulare umgestellt (19.07-kompatibel).
Vorherige Ansätze mit JS-Widgets (L.ui.*) führten auf 19.07 zu Fehlern („L.ui is undefined“).

Wichtigste Fixes (aus Changelog und Chat):

Controller wurde entschlackt: reine entry()-Routen, keine Shell/awk-Fragmente in Lua-Dateien (Fehlerursache in v0.5.11).

CBI-Templates nutzen self.map.uci statt globalem m → behebt 500er in overview.htm auf 19.07.

API-Status-Endpoint (/admin/services/ha_vrrp/api/status) liefert Ping/Status separat als JSON (blockiert UI nicht).

LuCI-Cache-Handling: nach Installation/Update Cache leeren und uhttpd neu starten.

Konfigurationsmodell (/etc/config/ha_vrrp)

core-Sektion (Beispiele):

option cluster_name 'lab-ha'

option peer_host '192.168.254.2'

option peer_netmask_cidr '24'

option ssh_backend 'auto' # auto|openssh|dropbear

option key_type 'auto' # auto|ed25519|rsa

option sync_method 'auto' # auto|scp|rsync

option fw_backend 'auto' # auto|iptables|nft

option ka_backend 'auto' # auto|ka_2x|ka_2_2plus

option dhcp_backend 'auto' # auto|dnsmasq_legacy|dnsmasq_fw4

option net_backend 'auto' # auto|swconfig|dsa

option priority '150'

option cluster_version '0.5.16-004'

UI erweitert diese Werte kontextsensitiv (z. B. CIDR neben Peer, Backend-Auswahl inkl. „auto“).

Backends (Adapter-Prinzip)

Firewall: iptables (fw3) und nftables (fw4) werden via eigene Skripte/Adapter angesteuert.

Keepalived: unterschiedliche Versionen kapseln Unterschiede in Konfig-Snippets und Start/Reload-Logik.

Netzwerk: swconfig vs. DSA – VLAN/Switch-Zuordnung pro OS-Linie.

SSH: dropbear/openSSH automatisch erkannt, Ed25519 bevorzugt (Fallback RSA).

Discover

Ziel: Peer automatisch ermitteln/prüfen (pingbar?), Start mit Interface HEARTBEAT vorausgewählt.

Strategien: IP-Bereiche 1–10 und .254 testen; optional ADMINLAN/LAN.

Ergebnis: Peer-Kandidatenliste, manuelle Auswahl oder Speicherung.

Sync

Methoden: SCP (Default) oder rsync (später voll implementiert). Auswahl in UI.

Schlüsselverwaltung im UI:

lokales Schlüsselpair erzeugen (ed25519 bevorzugt),

vorhandene Keys hochladen (priv/pub) und Peer-Pub als „trusted“ hinterlegen,

Dropbear/OpenSSH auto-detect, passende ~/.ssh/config-Einträge anlegen.

VRRP-Instanzen

Zielzustand: pro Segment eine Instanz, VIP .254 läuft auf Master.

Konvention: unteren IPs der Nodes sind statisch, VIPs immer .254.

Im UI: künftig Liste/Details/Quick-Actions (Platzhalter in v0.5.16).

Upgrade/Migration

Jede strukturelle Änderung bekommt ein Migration-Skript (migratefromXtoY.sh), vom Installer/Upgrader vor File-Kopie aufgerufen.

Beispiele: Umbau der Verzeichnisstruktur, Anpassungen der Config, Wechsel der Backend-Defaults.

Bekannte Stolpersteine (aus 0.5.12/0.5.14): Uninstaller bereinigte Dateien unvollständig; dokumentiert in Known Issues.

Logging/Diagnose

Sync-/Key-Actions schreiben nach /tmp/ha_vrrp_*.

Bei UI-Problemen: logread, dmesg, LuCI-Cache löschen, Lua-Syntaxchecks der Controller/CBI-Dateien.

Roadmap (aus Chat abgeleitet)

Rsync-Backend vollenden (inkl. Bandbreiten-/Exclude-Regeln).

Discover verbessern (ARP/NDP, LLDP optional).

Instances-UI (CRUD, Inline-Bearbeitung).

Mehr OS-Linien testen (21.02/22.03/23.05), Backends verifizieren.

ARCHITECTURE — openwrt-ha-vrrp

Technische Architektur und Komponentenübersicht.

Top-Level-Komponenten

LuCI-App (Serverseitig, CBI)

Controller: luci.controller.ha_vrrp (routet auf die CBI-Modelle und die API)

CBI-Modelle: overview.lua, settings.lua, sync.lua, instances.lua

Views: overview.htm, sync.htm, instances.htm

API: admin/services/ha_vrrp/api/status (JSON: Peer, Ping, Timestamp)

Core-Paket (Shell + Config + Backend-Adapter)

Config: /etc/config/ha_vrrp (zentrale, versionssichtige Optionen)

Scripts (Beispiele): discover.sh, sync/generate_keys.sh, sync/setup_ssh_config.sh, sync/push_keys.sh, rpc/*

Backend-Layer: firewall/keepalived/dhcp/net/ssh abstrahiert pro OS-/Tool-Version

Datenfluss

Settings (LuCI/CBI) → /etc/config/ha_vrrp

Nutzer:innen pflegen Clustername, Peer, Backends, Key/Sync-Präferenzen.

Overview (LuCI/CBI)

liest Core-Optionen, zeigt Version/Peer/Ping-Status und Einstieg in Discover/Sync.

Sync (LuCI/CBI)

triggert Scripts (Key-Erzeugung, SSH-Config, Key-Push, RPC-Test).

Upload-Felder erlauben das Einspielen eigener Keys (priv/pub) und Peer-Pub.

Discover (Script)

scannt HEARTBEAT (default) bzw. weitere Netze, schreibt Ergebnis nach /tmp/ha_vrrp_discover.json.

Instances (LuCI/CBI)

aktuell Platzhalter – Ziel ist die Verwaltung pro VRRP-Instanz/Segment inkl. VIP .254.

Wichtige Architektur-Entscheidungen (aus Chat & Changelogs)

CBI-only für 19.07: Keine Abhängigkeit von L.ui.* → verhindert TypeError „L.ui is undefined“.

Template-Fix: overview.htm greift auf self.map.uci zu (statt global m) → verhindert 500er.

Controller-Minimalismus: Keine Shellfragmente im Lua-Controller, nur entry() und kleine call()-APIs.

Backend-Adaption: iptables/nft, dropbear/openssh, dnsmasq-Varianten, keepalived-Versionen werden als Adapter gekapselt.

Migration vor Install/Upgrade: Umbauten via migratefromXtoY.sh gewährleisten reproduzierbare Upgrades.

Konvention für VIPs: .254 je Segment ist VIP des Masters; Nodes verwenden definierte „untere“ IPs.

Verzeichnisstruktur (empfohlen)openwrt-ha-vrrp/
├── luci-app-ha-vrrp/
│   └── luasrc/
│       ├── controller/ha_vrrp.lua
│       ├── model/cbi/ha_vrrp/{overview.lua, settings.lua, sync.lua, instances.lua}
│       └── view/ha_vrrp/{overview.htm, sync.htm, instances.htm}
├── ha-vrrp/
│   ├── files/etc/config/ha_vrrp
│   ├── files/usr/libexec/ha-vrrp/{discover.sh, sync/*.sh, rpc/*.wrapper}
│   └── Makefile
└── docs/
    ├── CONCEPTS.md
    ├── ARCHITECTURE.md
    ├── README_*.md, CHANGELOG_*.md, KNOWN_ISSUES_*.md
    └── INSTALL/UPGRADE Guides

Kompatibilität / Backendschicht

Firewall: Adapter ruft fw3/iptables oder fw4/nft auf (je nach OS-Version).

SSH: Auto-Detection bevorzugt OpenSSH (ed25519), fallback auf Dropbear (RSA); ~/.ssh/config wird generiert.

Keepalived: Generierung von vrrp_instance-Blöcken pro Segment; Versionen unterscheiden sich in unterstützten Optionen.

DHCP/DNS: dnsmasq-Varianten unterscheiden sich in fw4-Integration/Reload-Mechanik.

Network: VLAN/Switch-Konfig je nach swconfig vs. DSA unterschiedlich.

Upgrade-/Migrationspfad

Installer/Upgrader ruft vor Dateikopien migratefromXtoY.sh auf.

Skripte passen Verzeichnisse, Cfg-Strukturen und Defaultwerte an; dokumentiert in docs/CHANGELOG_* und docs/KNOWN_ISSUES_*.

Diagnose/Support

Logs unter /tmp/ha_vrrp_* prüfen.

LuCI-Cache löschen (/tmp/luci-*) und uhttpd neu starten.

Lua-Dateien syntaktisch testen: lua -e 'dofile("/pfad/zur/datei.lua")'.

