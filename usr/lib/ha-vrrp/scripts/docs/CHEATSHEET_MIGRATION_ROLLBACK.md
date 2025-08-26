# HA-VRRP Migration & Rollback – Cheatsheet

Dieses Blatt fasst die wichtigsten Befehle für **Upgrade**, **Rollback**, **Dry-Run** und **Konfiguration** zusammen.
Gültig ab *reviewfix5* (Kettenmigration).

## Grundpfade (per Config überschreibbar)
- Quell-Repo (ZIP/TAR): `REPO_PATH` → Default: `/root/vrrp-repo/`
- IPK-Repo: `IPK_REPO_PATH` → Default: `/root/vrrp-ipk-repo/`
- Optionaler Download-Mirror: `DOWNLOAD_REPO_PATH` (Standard: leer)

Anpassbar in: **`/etc/ha-vrrp/installer.conf`** (siehe `etc/ha-vrrp/installer.conf.example`).

## Schnelleinstieg
```sh
# Höchsten Patch der Serie 0.5.16 installieren
scripts/installer.sh

# Gezielte Version installieren (Migration)
scripts/installer.sh migrate 0.5.16-007

# Aktuelle Version auf deren Parent zurückrollen
scripts/installer.sh rollback

# Konkrete Version zurückrollen (auf deren Parent laut Upgradepfad)
scripts/installer.sh rollback 0.5.16-007
```

## Dry-Run (ohne Änderungen)
```sh
# Beispiel: einzelne Migrationsstufe nur simulieren
/usr/lib/ha-vrrp/scripts/migrate_0.5.15_to_0.5.16.sh --migrate --dry-run

# oder global
MIGRATE_DRYRUN=1 /usr/lib/ha-vrrp/scripts/migrate_0.5.15_to_0.5.16.sh --rollback
```

## Kettenmigration (automatisch, anhand Upgradepfad)
Die Installer nutzen `scripts/lib/upgradepath.sh`, um aus **`scripts/upgradepath_unified.txt`** die Kette `CUR → TARGET` zu bauen
und rufen für jeden Schritt `migrate_<from>_to_<to>.sh` (mit `--migrate` bzw. `--rollback`) auf.

```sh
# Komplett von 0.5.9 bis reviewfix4 (Ziel explizit)
scripts/installer.sh migrate 0.5.16-007_reviewfix4

# Komplettes Rollback bis 0.5.9
scripts/installer.sh rollback 0.5.9
```

## Snapshots & Logs
- Vor jedem Lauf wird ein Snapshot unter **`/etc/ha-vrrp/migrate-snapshots/`** erstellt.
- Log-Ausgaben der Skripte sind mit Präfix `[*, ✓, !, ✗]` versehen.

## Manuelle Einzelstufe
```sh
# Upgrade einer Stufe
/usr/lib/ha-vrrp/scripts/migrate_0.5.10_to_0.5.11.sh --migrate

# Rollback dieser Stufe
/usr/lib/ha-vrrp/scripts/migrate_0.5.10_to_0.5.11.sh --rollback
```

## Dateinamen & Orte
- Kettenlogik: `scripts/lib/upgradepath.sh`  → Funktionen: `build_chain`, `step_pairs`, `parent_of`, `latest_in_series`
- Upgradepfad-Datei (**wird verwendet**): `scripts/upgradepath_unified.txt`
- Optionale JSON-Variante (nur Info): `scripts/upgradepath_unified.json`
- Migration-Helper: `/usr/lib/ha-vrrp/scripts/lib/miglib.sh`
- Einzelstufen: `/usr/lib/ha-vrrp/scripts/migrate_<from>_to_<to>.sh`

## Hinweise
- Alle Skripte sind **idempotent** (mehrfach ausführbar).
- Fehlende Stufenskripte werden übersprungen (mit Hinweis).
- Nach einem **Rollback** einer Version solltest du die ältere Zielversion **neu installieren**, um Dateien konsistent einzuspielen.
```
