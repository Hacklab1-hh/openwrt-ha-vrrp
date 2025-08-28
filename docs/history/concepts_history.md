# Concepts History
## 0.5.16-007_reviwefix17

# Konzepte reviwefix17

Diese Version konzentriert sich auf die Verbesserung der Bedienoberfläche und der Wartbarkeit des HA‑VRRP‑Add‑ons.  Folgende Konzepte wurden eingeführt:

- **Modularisierte LuCI‑UI**: Die Konfigurationsoberfläche ist in eigenständige Module (Übersicht, Status, Allgemein, Peers & Sync, Backup/Restore, Erweitert) aufgeteilt.  Fehler in einem Modul blockieren nicht mehr die gesamte Oberfläche, sondern zeigen eine Fehlermeldung an.
- **Plattformunabhängige Synchronisation**: Neue Hilfsskripte (`sync‑full‑repo.sh` für POSIX/BusyBox und `sync‑full‑repo.ps1` für PowerShell) spiegeln das GitHub‑Repository ohne `git`, entpacken Branches/Tags in versionierte Ordner und setzen einen symbolischen Link auf den zuletzt installierten Stand.
- **JSON‑Status‑API**: Über einen neuen Action‑Endpunkt (`status_json`) im LuCI‑Controller sowie ein CGI‑Skript wird der aktuelle Status als JSON bereitgestellt (installierte Version, Keepalived‑Status, letzter Migrationsschritt).  Dies ermöglicht eine einfache Integration in Überwachungssysteme wie Home Assistant.
- **Backup und Analyse**: Vor jeder Migration wird ein Backup der bestehenden Keepalived‑Konfiguration erstellt.  Vorhandene Backups können analysiert und beim Erzeugen einer neuen Konfiguration übernommen werden.
- **Helper‑Workflows**: Skripte zur Versions‑Normalisierung, zur Pflege der Konzept‑/Architektur‑Dokumente und zur Paketgenerierung sorgen dafür, dass die Dateien `CONCEPTS.md` und `ARCHITECTURE.md` stets den aktuellen Gesamtstand widerspiegeln, während versionsspezifische Teilfassungen im Ordner `docs/concepts` erhalten bleiben.

Diese Konzepte bilden die Grundlage für die fortlaufende Entwicklung des Add‑ons und bereiten den Weg für zukünftige Integrationen.
## 0.5.16-007_reviewfix17_a1

# Konzepte reviewfix17_a1

Diese Teilfassung ergänzt die in Version *reviwefix17* beschriebenen Konzepte um organisatorische Anpassungen und Workflow‑Verbesserungen.  Sie dient als Baustein für die vollständige Zusammenfassung in `CONCEPTS.md`.

## Änderungen und Ergänzungen

- **Migration der Changelog‑Struktur**: Alle versionsspezifischen Changelog‑Dateien wurden aus dem Verzeichnis `docs/changelog` in `docs/changelogs` überführt.  Die Dateinamen verwenden nur noch die Version (ohne Prefix `CHANGELOG_`), was die automatisierte Erkennung erleichtert.
- **Neue UI‑Workflows**: Ein neuer Prompt beschreibt den UI‑Build‑Workflow.  Entwickelnde sollen die LuCI‑UI modular aufbauen, Fehler in einzelnen Modulen auffangen, die JSON‑Status‑API erweitern und UCI zur Konfiguration nutzen.  Tests, Dokumentations‑Updates und ein sauberer Versionsbump gehören ebenfalls dazu.
- **Anpassungen in Helper‑Skripten**: Die Helper‑Skripte wurden erweitert, um das alte `docs/changelog` beim Packen auszuschließen und die neuen History‑Dateien (`concepts_history.md`, `architecture_history.md`) zu pflegen.

Diese organisatorischen Konzepte verbessern den Release‑Prozess und stellen sicher, dass Dokumentation und Skripte konsistent bleiben, während sich die Kernfunktionen des Add‑ons weiterentwickeln.
## 0.5.16-007_reviewfix17_a2

# Konzepte reviewfix17_a2

Diese Teilfassung erweitert die in *reviewfix17_a1* beschriebenen Konzepte um weitere organisatorische und strukturelle Verbesserungen.  Sie dient als Baustein für die vollständige Zusammenfassung in `CONCEPTS.md`.

## Änderungen und Ergänzungen

- **Versionsspezifische Basismaterialien**: README‑, Known‑Issues‑ und Feature‑Dateien werden nun analog zu den Changelogs pro Version gepflegt.  Alle Dateien sind in den Verzeichnissen `docs/readmes`, `docs/known-issues` und `docs/features` abgelegt und tragen ausschließlich den Versionsnamen.  Dadurch können Workflows diese Dateien automatisiert erkennen und verarbeiten.
- **Zentrale Aggregation per Helper**: Mit dem neuen Skript `gen-base-md.sh` werden aus allen versionsspezifischen Dokumenten konsolidierte Gesamtübersichten erstellt.  Die Integration dieses Skripts in `helper_sync_docs.sh` und `helper_build_package.sh` stellt sicher, dass die aggregierten Dateien (z. B. `readmes.md`, `known-issues.md`, `features.md`) immer aktuell sind.
- **Spezialisierte Architektur‑ und Konzept‑Dateien**: Für die Teilmodule Installer, Migration, UI und Uninstaller wurden eigenständige Konzept‑ und Architekturdateien erstellt.  Diese fassen die zentralen Ideen und Strukturen der jeweiligen Komponenten zusammen und dienen als Referenz für Entwickelnde.

Diese organisatorischen Konzepte verbessern den Release‑Prozess und die Dokumentation, ohne die Kernfunktionalität des HA‑VRRP‑Add‑ons zu verändern.
## 0.5.16-007_reviewfix17_a3

# Konzepte reviewfix17_a3

Diese Teilfassung erweitert die in *reviewfix17_a2* dokumentierten organisatorischen Verbesserungen um ein neues Konzept der konfigurierbaren Dokumentenaggregation.

## Neue Konzepte

- **Konfigurierbare Aggregation via JSON**: Die Datei `config/doc_aggregation.json` erlaubt es, das Verhalten der automatischen Dokumentenaggregation zu steuern.  Für jede zentrale Datei (etwa `architecture.md` oder `concepts.md`) kann dort festgelegt werden, ob neue Teilfassungen angehängt werden (*append*) oder ob lediglich die neueste Teilfassung als Basis für das zentrale Dokument verwendet wird (*extend*).  Diese Einstellung beeinflusst sowohl die generierten zentralen Dateien im Projekt‑Root als auch die Übersichten unter `docs/`.
- **Flexible Darstellung der Historie**: Durch die Wahl des Aggregationsmodus kann entschieden werden, ob die komplette Versionshistorie in der zentralen Dokumentation sichtbar sein soll oder ob nur die jeweils aktuelle Fassung angezeigt wird.  Dies erleichtert die Anpassung der Dokumentation an unterschiedliche Zielgruppen (z. B. Anwender vs. Entwickler).
- **Automatische Berücksichtigung im Build‑Prozess**: Das aktualisierte Helper‑Skript `gen-base-md.sh` liest die Konfiguration und erzeugt die zentralen Dokumente entsprechend.  Die Konfigurationsdatei liegt im Repository und wird beim Checkout mitkopiert, sodass der Build‑Prozess reproduzierbar bleibt.

Diese Konzepte stärken die Wartbarkeit der Dokumentation und ermöglichen eine projektspezifische Steuerung der Sichtbarkeit von Versionshistorie und Basisinformationen.
