# CHANGELOG

## 0.5.16-007_reviewfix17_a4_fix3.md

# Changelog – 0.5.16‑007_reviewfix17_a4_fix3

## Zusammenfassung

Dieses Release ist ein kleines Wartungsupdate, das die Entwickler:innen‑Werkzeuge erweitert.  Es führt neue CLI‑Skripte ein, mit denen die README‑Dateien versionsspezifisch ausgegeben werden können, und ergänzt ein zentrales Hilfeskript mit einer Übersicht der vorhandenen Werkzeuge.  Die eigentlichen Funktionen des Add‑ons bleiben unverändert.

## Änderungen

- **Neue CLI‑Skripte**
  - `scripts/readme.sh`: Gibt die README‑Teilfassung für die aktuelle oder eine angegebene Version auf der Kommandozeile aus.  Erkennt Versionsnummern in Paketnamen (Tarballs, Zip‑ oder IPK‑Dateien) und Commit‑Tags.
  - `scripts/help.sh`: Zeigt eine Kurzübersicht aller wichtigen Helfer im Projekt an, inklusive der Parameter für `manage_docs.sh` und der Nutzung von `readme.sh`.
- **Neue Teilfassungen**: Für Architektur und Konzepte gibt es neue Dateien, die die oben genannten Erweiterungen beschreiben.
- **Upgradepfad**: `config/upgradepath.unified.json` wurde um einen Eintrag für diese Version erweitert; das zugehörige Migrationsskript ist leer, da keine Laufzeitänderungen vorgenommen wurden.

## Hinweise

Dieses Release richtet sich vor allem an Entwickler:innen, die das Repository bearbeiten.  Es werden keine neuen Funktionen im Add‑on selbst eingeführt.  Die vorherigen Upgrade‑ und Preset‑Konzepte bleiben gültig.
## 0.5.16-007_reviewfix17_a4_fix2.md

# Changelog – 0.5.16‑007_reviewfix17_a4_fix2

## Zusammenfassung

Diese Wartungsversion erweitert **reviewfix17_a4_fix1** um ein zentrales Manager‑Skript zur Pflege der Dokumentation sowie die Konsolidierung der Readme‑Dateien.  Funktional ändert sich das Verhalten des Add‑ons nicht; vielmehr wird die Dokumentationspflege erleichtert und das Dateilayout aufgeräumt.

## Änderungen

- **Neues Manager‑Skript (`manage_docs.sh` / `manage_docs.ps1`):**
  - Fügt Einträge zu versionsspezifischen Teilfassungen (Concepts, Architecture, Changelogs, Readmes, Features, Known‑Issues) hinzu.
  - Ermöglicht optional die Finalisierung einer neuen Version über `--new-version`, kopiert dabei bestehende Teilfassungen, aktualisiert die `VERSION`‑Datei und ruft die vorhandenen Helper zur Synchronisierung auf.
  - Wird sowohl als POSIX‑Shell‑Skript als auch als PowerShell‑Skript bereitgestellt, um die Nutzung unter BusyBox/OpenWrt, Linux und Windows zu ermöglichen.
- **Readme‑Migration:** Die im Verzeichnis `docs/Readme` abgelegten Dateien wurden in die strukturierte Ordnerhierarchie `docs/readmes` und `docs/readmeas` überführt.  Dabei wurden die Dateinamen von `README_0.x.y.md` zu `0.x.y.md` vereinfacht.
- **Neue Teilfassungen:** Neue Versionsspezifische Dokumente für Architektur, Konzepte und Readme beschreiben die Änderungen dieser Version (siehe `docs/architecture/0.5.16-007_reviewfix17_a4_fix2.md`, `docs/concepts/0.5.16-007_reviewfix17_a4_fix2.md` und `docs/readmes/0.5.16-007_reviewfix17_a4_fix2.md`).
- **Upgradepfad aktualisiert:** `config/upgradepath.unified.json` wurde um einen Eintrag für diese Version ergänzt; das zugehörige Migrationsskript (`migrate-to-0.5.16-007_reviewfix17_a4_fix2.sh`) führt derzeit keine Operationen aus.

## Hinweise

Es handelt sich um einen rein dokumentationsbezogenen Release.  Die laufenden Installer‑, Uninstaller‑ und UI‑Komponenten bleiben unverändert.  Anwender:innen, die **reviewfix17_a4_fix1** nutzen, müssen keine zusätzlichen Schritte durchführen, außer ggf. das neue Manager‑Skript zur Pflege eigener Notizen zu nutzen.  Für Entwickler:innen empfiehlt es sich, die neuen Readme‑Verzeichnisse zu berücksichtigen und im Zuge weiterer Versionen regelmäßig die Teilfassungen zu aktualisieren.
## 0.5.16-007_reviewfix17_a4_fix1.md

## 0.5.16‑007_reviewfix17_a4_fix1

Diese Version **0.5.16‑007_reviewfix17_a4_fix1** ist ein kleiner Wartungs‑Release.  Sie übernimmt alle Architektur‑ und Konzeptdokumente aus der Vorgängerversion *reviewfix17_a4* und hebt lediglich die Versionsnummer an.  Es wurden keine neuen Funktionen eingeführt.

Wesentliche Punkte:

- **Versionsbump**: Erhöhung der Versionsnummer auf `0.5.16‑007_reviewfix17_a4_fix1` in `VERSION` und allen zentralen Dokumenten.
- **Übernahme der Architektur‑Dokumente**: Die in *a4* eingeführten Architektur‑ und Konzept‑Teilfassungen wurden unverändert übernommen und unter dem neuen Versionsnamen abgelegt (`docs/architecture/0.5.16-007_reviewfix17_a4_fix1.md`, `docs/concepts/0.5.16-007_reviewfix17_a4_fix1.md`).  Dadurch bleiben das Preset‑System und der Versionssprung‑Workflow vollständig dokumentiert.
- **Kein Migrationsbedarf**: Es wird kein zusätzliches Migrationsskript benötigt, da keine strukturellen oder funktionalen Änderungen vorgenommen wurden.

Dieser Fix‑Release dient der Konsistenz der Versionierung und der fortlaufenden Dokumentation.
## 0.5.16-007_reviewfix17_a4.md

## 0.5.16‑007_reviewfix17_a4

Die Version **0.5.16‑007_reviewfix17_a4** ergänzt das Projekt um ein konfigurierbares Preset‑System, das zwischen Dev‑ und Node‑Umgebungen unterscheidet, und dokumentiert die unterstützten OpenWrt‑Versionen für Mango (GL‑MT300N‑V2), Lamobo R1 und x86.  Die wichtigsten Änderungen sind:

- **Preset‑System**: Die neue Datei `config/presets.json` definiert Basispfade, Downloadordner, IPK‑Repositories und Arbeitsverzeichnisse für `dev` (Linux/Windows) und `node` (OpenWrt).  Sie enthält außerdem Geräteprofile mit empfohlenen OpenWrt‑Versionen und Upgrade‑Hinweisen【92603978916730†L320-L322】【633554760445073†L148-L156】【878966515062870†L23-L27】.
- **Versionssprung‑Workflow**: Das Workflow‑System beschreibt nun, wie ein Versionssprung durchgeführt wird: Versionsbump, Aktualisierung der Tags in den Dokumenten via `helper_update_version_tags.sh` und Neuerzeugung der zentralen MD‑Dateien über `helper_sync_docs.sh`.
- **Aktualisierte Architektur‑ und Konzept‑Dokumente**: Die Teilfassungen `docs/architecture/0.5.16-007_reviewfix17_a4.md` und `docs/concepts/0.5.16-007_reviewfix17_a4.md` dokumentieren das Preset‑System, die neuen Arbeitsordner und die Gerätespezifischen OpenWrt‑Versionen.  Zusätzlich wurden die zentralen Architektur‑ und Konzept‑Dokumente für Installer und Migration um Hinweise auf das Preset‑System ergänzt.
- **Pfadhandhabung in Skripten**: `common.sh` und der Installer berücksichtigen nun das Preset beim Ableiten der Zielpfade.  Ein Helper‑Skript verschiebt im Dev‑Modus heruntergeladene Artefakte in das lokale Repo (`_workspace/vrrp-repo`) und ermöglicht den Transfer per `scp` auf Nodes.

Diese Version verbessert die Flexibilität des Add‑ons in unterschiedlichen Umgebungen und erleichtert zukünftige Upgrades für spezifische Hardware.
## 0.5.16-007_reviewfix17_a3.md

## 0.5.16‑007_reviewfix17_a3

Die Version **0.5.16‑007_reviewfix17_a3** führt eine konfigurierbare Steuerung der Dokumentenaggregation ein und hebt die Dokumentationslogik auf eine neue Stufe.  Die wichtigsten Änderungen sind:

- **Neue Version**: Erhöhung der Versionsnummer auf `0.5.16-007_reviewfix17_a3`.
- **Konfigurationsdatei `doc_aggregation.json`**: Unter `config/` befindet sich jetzt eine JSON‑Datei, die steuert, ob zentrale Dokumente wie `architecture.md` und `concepts.md` alle Teilfassungen anhängen (*append*) oder nur die jeweils neueste verwenden (*extend*).
- **Überarbeiteter Aggregator**: `scripts/gen-base-md.sh` wurde erweitert und liest nun die oben genannte Konfiguration.  Je nach Einstellung werden die generierten Dateien im Projekt‑Root entweder aus allen Versionsdateien zusammengesetzt oder nur aus der neuesten Teilfassung.
- **Dokumentationsanpassungen**: Die neuen Funktionen und das Konzept der konfigurierbaren Aggregation werden in den Architektur‑ und Konzept‑Teilfassungen von *reviewfix17_a3* dokumentiert.  Historien‑Dateien wurden entsprechend ergänzt.

Diese Änderungen erweitern die Flexibilität bei der Erstellung der zentralen Dokumente und erlauben es, das Sichtbarkeitsniveau der Historie projektspezifisch anzupassen.
## 0.5.16-007_reviewfix17_a2.md

## 0.5.16‑007_reviewfix17_a2

Die Version **0.5.16‑007_reviewfix17_a2** baut auf den organisatorischen Verbesserungen von *reviewfix17_a1* auf und erweitert die Dokumentations‑ und Build‑Infrastruktur des Projekts.  Die wesentlichen Änderungen sind:

- **Umbennenung und Versionsbump**: Das Release wurde auf `0.5.16-007_reviewfix17_a2` angehoben.  Alle relevanten Dateien (z. B. `VERSION`, `docs/README.md`) wurden entsprechend angepasst.
- **Migration der Basismaterialien**: README‑, Known‑Issues‑ und Feature‑Dateien wurden nach dem Vorbild der Changelogs in eigenständige Verzeichnisse (`docs/readmes`, `docs/known-issues`, `docs/features`) verschoben und konsequent nach Version benannt.  Die alten, präfixierten Dateien werden beim Packen ausgeschlossen.
- **Neues Aggregations‑Script**: Das Helper‑Skript `gen-base-md.sh` aggregiert nun alle versionsspezifischen Dokumente (Changelog, Konzepte, Architektur, Features, Known‑Issues, Readmes) in zentrale Dateien (`changelogs.md`, `concepts.md`, `architecture.md`, `readmes.md`, `known-issues.md`, `features.md`).  Es wird automatisch durch `helper_sync_docs.sh` und `helper_build_package.sh` ausgeführt.
- **Modularisierte Dokumentation**: Für die Teilmodule Installer, Migration, UI und Uninstaller wurden eigene Architektur‑ und Konzept‑Dateien erstellt (z. B. `architecture_installer.md`, `concepts_ui.md`).  Diese Dokumente beschreiben die Struktur und die grundlegenden Gedanken der jeweiligen Komponenten.
- **Anpassungen an Release‑Skripten**: `helper_sync_docs.sh` und `helper_build_package.sh` wurden erweitert, um die neuen Verzeichnisse zu berücksichtigen und `gen-base-md.sh` aufzurufen.  Der Paketbau schließt die alten Ordner mit prae-Prefix aus.

Diese Änderungen verbessern die Pflege und Konsistenz der Dokumentation, ohne die Funktionalität des Add‑ons zu verändern.
## 0.5.16-007_reviewfix17_a1.md

# 0.5.16-007_reviewfix17_a1 — 2025-08-27

### Added

- **Installer‑Build‑Prompt**: Ein neues Workflow‑Dokument (`docs/release-workflow-prompt/installer-build-PROMPT.md`) definiert die Schritte zum Erzeugen von Installer‑/Uninstaller‑Skripten und Paket-Builds.  Damit wird der Build‑Prozess für das HA‑VRRP‑Addon nachvollziehbar und automatisiert.
- **Erweiterte Workflow‑Dokumentation**: Das UI‑Build‑Prompt (`ui-build-PROMPT.md`) wurde aktualisiert, und `docs/README.md` listet nun alle relevanten Workflow‑Prompts (Development, UI‑Build, Installer‑Build) auf.
- **Cross‑Plattform Sync‑Skripte**: Ergänzend zu den bestehenden BusyBox‑Shell‑Scripts wurde ein PowerShell‑Äquivalent (`sync-full-repo.ps1`) bereitgestellt.

### Changed

- **Changelogs migriert**: Alle versionsspezifischen Changelogs wurden vom Verzeichnis `docs/changelog` in `docs/changelogs` verschoben und umbenannt (z. B. `CHANGELOG_0.4.0.md` → `0.4.0.md`).  Release‑ und Migration‑Skripte verwenden nun ausschließlich den neuen Pfad.
- **Dokumentation aktualisiert**: `docs/README.md` und das Top‑Level `README.md` wurden auf die neue Version `0.5.16-007_reviewfix17_a1` angehoben und enthalten jetzt Verweise auf alle Workflow‑Prompts.  Die Dateien `ARCHITECTURE.md` und `CONCEPTS.md` (sowohl im Root als auch unter `docs/`) tragen ebenfalls die aktuelle Versionsnummer.

### Fixed

- Keine spezifischen Fehlerbehebungen in dieser Version.
## 0.5.16-007_reviewfix16_featurefix15_fix1.md

## Changelog — 0.5.16-007_reviewfix16_featurefix15_fix1


## 0.5.16-007_reviewfix16_featurefix5_fix2_2.md

# Changelog – v0.5.9

- Automatisch generierte Doku aus Archiv-PARSING & Chat-Notizen

## 0.5.16-007_reviewfix16_featurefix5_fix2.md

# Changelog – v0.1.0

-

## 0.5.16-007_reviewfix16_featurefix5_fix1.md

## Changelog — 0.5.16-007_reviewfix16_featurefix5_fix1


## 0.5.16-007_reviewfix16_featurefix4.md

## Changelog — 0.5.16-007_reviewfix16_featurefix4

- feat: ...
- fix: ...
- ...
- ...
- docs: move workflow prompt to `docs/release-workflow-prompt/development-change-PROMPT-WORKFLOW.md`
- ...

## 0.5.16-007_reviewfix14e.md

# 0.5.16-007_reviewfix14e — Installer/Uninstaller & Node Flow
- Neuer Installer/Uninstaller-Flow auf OpenWrt-Node
- Konsistenzchecks (migrations/docs)
- Update-/Upgradegraph erweitert (14d→14e)

## 0.5.16-007_reviewfix14b2b.md

# 0.5.16-007_reviewfix14b2b — Robustness (2025-08-26 15:59:44)
- ROOT_DIR-Autodetektion in allen Skripten
- Self-Test migrations
- Upgradegraph: 14b2→14b2a→14b2b

## 0.5.16-007_reviewfix14b1.md

# 0.5.16-007_reviewfix14b1 — Maintenance (2025-08-26 15:28:26)
- Ergänzt: `config/upgradepath.unified.json` um Knoten **14**, **14a**, **14b**, **14b1**, **14c**.
- Ergänzt: `config/updatepath.unified.json` um Kanten:
  - 13 → 14
  - 14 → 14a (Migration-Skript)
  - 14a → 14b (Migration-Skript)
  - 14b → 14b1 (Metadaten/Docs)
  - 14b → 14c (Migration-Skript, entfernt legacy-ur-archive)
  - 14c → 14b (Rollback definiert)
- Keine inhaltlichen Änderungen an VRRP-/LuCI-Logik; reine Upgrade-/Dokumentationspflege.

## 0.5.16-004.md

# Changelog v0.5.16-004

- Fix: Overview 500 wegen `m` nil → Template greift nun auf `self.map.uci` zu.
- Neu: Version-/Backend-Anzeige in Overview.
- Neu: Settings um `ssh_backend`, `peer_netmask_cidr` und Hilfetexte erweitert.
- Neu: Sync-Seite unterstützt Upload von privatem Schlüssel (lokal), lokalem Pub und Peer-Pub (Trust).
- Neu: Instances-View mit Kurzbeschreibung (Platzhalter).
- Config: Standardwerte `ssh_backend=auto`, `peer_netmask_cidr=24`, `cluster_version=0.5.16-004`.

## 0.5.16.md

# Changelog v0.5.16

- Controller/CBI/Views bereinigt; Overview-500 behoben; Settings erweitert.

## 0.5.15.md

# Changelog v0.5.15

- Migrationspfad skizziert; LuCI stabilisiert.

## 0.5.14.md

# Changelog v0.5.14

- Menü sichtbar; UI zeigte JSON statt CBI; Uninstaller unvollständig.

## 0.5.13.md

# Changelog v0.5.13

- Fixes im Installer; UI teils leer; Cache nötig.

## 0.5.12.md

# Changelog v0.5.12

- Installer/Uninstaller ergänzt; bekannter Uninstaller-Bug.

## 0.5.11.md

# Changelog v0.5.11

- IPKs erstmals; Controller-Fehler beim LuCI-Laden beobachtet.

## 0.5.10.md

# Changelog v0.5.10

- Key-Management UI initiiert; erste Sync-Mechanik (scp).

## 0.5.9.md

# Changelog – v0.5.9

- Automatisch generierte Doku aus Archiv-PARSING & Chat-Notizen

## 0.5.8.md

# Changelog – v0.5.8

- `autodiscover` nutzt optional gewähltes Interface/Subnetz

## 0.5.7.md

# Changelog – v0.5.7

- Controller: `discover_adv`, `autodiscover`, `setpeer`; Status JSON enthält `instance_sections`

## 0.5.6.md

# Changelog – v0.5.6

- Controller: `listifaces`, `createinst`

## 0.5.5.md

# Changelog – v0.5.5

- Paketversion 0.5.5

## 0.5.4.md

# Changelog – v0.5.4

- Paketversion 0.5.4, Doku ergänzt

## 0.5.3.md

# Changelog – v0.5.3

- Installer/Uninstaller auf 0.5.3 gehoben

## 0.5.2.md

# Changelog – v0.5.2

- Quickstart-Skripte `apply-LamoboR1-*.sh`

## 0.5.1.md

# Changelog – v0.5.1

- Renderer robust gegen fehlende Instanzen; Status JSON verbessert

## 0.5.0.md

# Changelog – v0.5.0

- Konsolidiert 0.3.0 + 0.4.0-Funktionalität; neue Scripts `check_wan6_gw.sh`, `ha-vrrp-autosync`

## 0.4.0a.md

# Changelog – v0.4.0a

-

## 0.4.0.md

# Changelog – v0.4.0

-

## 0.3.0a.md

# Changelog – v0.3.0a

-

## 0.3.0.md

# Changelog – v0.3.0

-

## 0.2.0.md

# Changelog – v0.2.0

-

## 0.1.0.md

# Changelog – v0.1.0

-

