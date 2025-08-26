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

