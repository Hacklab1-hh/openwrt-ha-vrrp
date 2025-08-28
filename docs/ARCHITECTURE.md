# ARCHITECTURE (Übersicht)

## 0.5.16-007_reviewfix17_a1.md

# Architektur‑Notizen reviewfix17_a1

In der Version **0.5.16‑007_reviewfix17_a1** wurden die in *reviwefix17* eingeführten Architekturverbesserungen weiter konsolidiert und dokumentiert.  Diese Teilfassung dient dazu, den aktuellen Stand für die automatische Zusammenführung in `CONCEPTS.md`/`ARCHITECTURE.md` festzuhalten.

Die wichtigsten Punkte dieser Version sind:

- **Konsolidierung der Dokumente**: Alle Changelog‑Dateien wurden in das neue Verzeichnis `docs/changelogs` verschoben.  Die Namen der Teilfassungen folgen nun konsequent dem Muster `<VERSION>.md`, wodurch Skripte und Release‑Workflows die Dateien leichter erkennen können.
- **UI‑Build‑Workflow**: Ein dedizierter Prompt (`docs/release-workflow-prompt/ui-build-PROMPT.md`) beschreibt nun, wie die LuCI‑UI modular entwickelt, fehlertolerant gestaltet und mittels JSON‑Status‑API erweitert wird.
- **Helper‑Anpassungen**: `helper_build_package.sh` schließt das alte Verzeichnis `docs/changelog` aus, um doppelte Dateien im Release‑Archiv zu verhindern.  Die Migrations‑ und Release‑Skripte verweisen ausschließlich auf `docs/changelogs`.

Diese Änderungen betreffen primär die Dokumentations‑ und Build‑Infrastruktur und haben keinen Einfluss auf die Kernlogik des Add‑ons.
## 0.5.16-007_reviewfix17_a2.md

# Architektur‑Notizen reviewfix17_a2

In der Version **0.5.16‑007_reviewfix17_a2** wurde die Dokumentations‑ und Build‑Infrastruktur des HA‑VRRP‑Add‑ons nochmals erweitert.  Diese Teilfassung dient dazu, den aktuellen Stand der Architekturänderungen für die automatische Zusammenführung in `ARCHITECTURE.md` festzuhalten.

Die wichtigsten Punkte dieser Version sind:

- **Neue Basisdokumente**: Neben den bisherigen Changelogs werden jetzt auch README‑, Known‑Issues‑ und Features‑Dateien versionsspezifisch gepflegt.  Sie wurden in die neuen Verzeichnisse `docs/readmes`, `docs/known-issues` und `docs/features` verschoben.  Die Dateinamen entsprechen ausschließlich der jeweiligen Version (z. B. `0.5.16-007_reviewfix17_a2.md`), sodass Skripte diese Dateien leichter erkennen und verarbeiten können.
- **Aggregation per Helper**: Ein neues Helper‑Skript (`gen-base-md.sh`) konsolidiert die Inhalte aller versionsspezifischen Dokumente (Changelogs, Konzepte, Architektur, Features, Known‑Issues und Readmes) in zentrale Markdown‑Dateien.  Dieses Skript wird nun automatisch von `helper_sync_docs.sh` und `helper_build_package.sh` aufgerufen, wodurch die aggregierten Übersichten (`architecture.md`, `concepts.md`, `changelogs.md`, `readmes.md`, `known-issues.md` und `features.md`) bei jedem Release zuverlässig aktualisiert werden.
- **Spezialisierte Architektur‑Dateien**: Zusätzlich zu den globalen Architekturdokumenten wurden für die Teilmodule Installer, Migration, UI und Uninstaller eigene Architekturdateien erstellt (z. B. `architecture_installer.md`).  Diese neuen Dateien beschreiben die Struktur und die Beziehungen der jeweiligen Teilmodule detailliert und erleichtern die Einarbeitung neuer Entwickelnder.

Diese Änderungen betreffen primär die Dokumentations‑ und Build‑Infrastruktur und haben keinen Einfluss auf die Kernlogik des Add‑ons.
## 0.5.16-007_reviewfix17_a3.md

# Architektur‑Notizen reviewfix17_a3

Die Version **0.5.16‑007_reviewfix17_a3** bringt eine neue Ebene der Konfigurierbarkeit für die automatische Dokumentenaggregation.  Während in *reviewfix17_a2* die Grundlage für die Konsolidierung von Dateien gelegt wurde, ermöglicht diese Version über eine JSON‑Konfiguration feinere Einstellungen.

Wichtige Änderungen:

- **Konfigurierbare Aggregation**: Im Ordner `config/` liegt nun die Datei `doc_aggregation.json`.  Sie definiert für jede zentrale Markdown‑Datei (z. B. `architecture.md`, `concepts.md`, `features.md`, `readmes.md`, `known-issues.md`), ob neue Teilfassungen *angehängt* werden (`"append"`) oder ob die zentrale Datei ausschließlich aus der jeweils neuesten Teilfassung *erweitert* wird (`"extend"`).  Dadurch lässt sich das Verhalten des Helpers `gen-base-md.sh` ohne Codeänderungen anpassen.
- **Erweiterter Aggregator**: Das Skript `scripts/gen-base-md.sh` liest diese Konfiguration und generiert die zentralen Dateien entsprechend.  Im *Append*-Modus werden alle Versionen (neueste zuerst) in die zentrale Datei aufgenommen; im *Extend*-Modus besteht die zentrale Datei nur aus der aktuellsten Teilfassung.  Die überarbeiteten zentralen Dateien werden weiterhin bei jedem Aufruf von `helper_sync_docs.sh` und `helper_build_package.sh` erzeugt.
- **Dokumentation der Konfiguration**: Die Verfügbarkeit und Nutzung dieser Konfiguration ist sowohl in den Architektur‑ als auch in den Konzept‑Dokumentationen vermerkt.  Entwicklerinnen und Entwickler können durch Anpassen der JSON‑Datei steuern, welche Teile der Historie in den zentralen Dokumenten sichtbar sein sollen.

Diese Anpassungen erhöhen die Flexibilität beim Dokumenten‑Build‑Prozess und verbessern die Anpassbarkeit an projektinterne Präferenzen, ohne die Funktionsweise des Add‑ons zu beeinträchtigen.
## 0.5.16-007_reviwefix17.md

# Architektur‑Notizen reviwefix17

In der Version **0.5.16‑007_reviwefix17** wurde die Architektur des HA‑VRRP‑Add‑ons wie folgt erweitert:

- **Schichtenmodell für die UI**: Die LuCI‑Oberfläche besteht aus Controller, Modell (CBI) und Views.  Für jede Funktionalität (Übersicht, Status, Allgemein, Peers & Sync, Backup/Restore, Erweitert) gibt es einen eigenen View‑ und Modell‑Layer.  Der Controller registriert zusätzlich den JSON‑Status‑Endpunkt `status_json`.
- **Helper‑Skripte**: Ein neuer Satz von Helpers (`helper_update_version_tags.sh`, `helper_sync_docs.sh`, `helper_smoketests.sh`, `helper_build_package.sh`) automatisiert die Pflege der Dokumente und den Release‑Prozess.  Diese Scripts werden aus den Manager‑Skripten (Installer, Uninstaller, Migration) aufgerufen.
- **Status‑API**: Über einen neuen CGI‑Handler (`/cgi‑bin/ha‑vrrp‑status`) sowie eine LuCI‑Action wird der Betriebszustand als JSON ausgegeben.  Der Status liest die aktuelle Version (`/etc/ha‑vrrp/version`), prüft den Keepalived‑Prozess und den letzten Migrationszustand (`/etc/ha‑vrrp/state.json`).
- **Synchronisationsschicht**: Die Sync‑Skripte laden ZIP‑Archive von GitHub und entpacken sie auf dem lokalen System, sodass `current` immer auf den aktuell installierten Stand zeigt.  Dadurch wird der Einsatz ohne installiertes `git` und in Offline‑Umgebungen unterstützt.
- **Migrationsframework**: Die unified Upgrade‑Path‑Definition wurde um diese Version ergänzt.  Das zugehörige Migration‑Skript dokumentiert das Update, erstellt ein Backup und setzt die neue Version.

Diese Änderungen festigen die modulare Architektur des Projekts, erleichtern die Wartung und ermöglichen eine nahtlose Integration in andere Systeme.
