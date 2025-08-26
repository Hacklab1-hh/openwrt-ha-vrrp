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
