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
## 0.5.16-007_reviewfix17_a4

# Konzepte reviewfix17_a4

Diese Teilfassung führt ein Preset‑System ein und dokumentiert die Annahmen zu unterstützten OpenWrt‑Versionen sowie den Ablauf eines Versionssprungs.

## Preset‑System

- **Dev‑Preset**: Für Entwickler:innen, die unter Linux oder Windows arbeiten.  Es definiert Pfade für lokale Spiegel (`_workspace/vrrp-repo`), Download‑Ordner, IPK‑Repository und den aktuellen Arbeitsordner.  Der Installer verwendet diese Angaben, um das aktuellste lokale Paket zu installieren.  Ein Helper‑Skript verschiebt alle heruntergeladenen Tar‑, Zip‑ und IPK‑Dateien aus dem Download‑Ordner in das Arbeitsverzeichnis, sodass diese per `scp` auf OpenWrt‑Nodes übertragen werden können.
- **Node‑Preset**: Für Produktivsysteme (OpenWrt).  Es legt Basisverzeichnisse wie `/root/openwrt-ha-vrrp-current`, `/root/openwrt-ha-vrrp-repo` und `/root/vrrp-ipk-repo` fest.  Der Installer lädt dort Archive aus dem lokalen Repo, erstellt Backups und führt das Setup aus.  Dadurch bleibt das System unabhängig von der Entwicklungsumgebung.
- **OpenWrt‑Versionsermittlung**: Die Preset‑Konfiguration ermöglicht es, eine *ermittelte* oder *angenommene* OpenWrt‑Version für die Zielhardware zu hinterlegen.  Für Mango/GL‑MT300N‑V2 ist OpenWrt 22.03.4 aktuell【92603978916730†L320-L322】, für Lamobo R1 existiert aufgrund der DSA‑Umstellung kein Migrationspfad von 19.07 auf 22.03【633554760445073†L148-L156】 (daher Neuinstallation erforderlich), und für x86‑Geräte können Upgrades per sysupgrade von 21.02 über 22.03 auf 23.05 durchgeführt werden【878966515062870†L23-L27】.  Diese Informationen dienen dazu, den Nutzer:innen sinnvolle Upgrade‑Vorschläge zu machen.
- **Device‑Profile**: In `presets.json` sind Geräteprofile hinterlegt, die upgradefähige OpenWrt‑Versionen sowie EOL‑Hinweise enthalten.  Sie können genutzt werden, um Anwender:innen zu warnen oder alternative Pfade (Neuinstallation) vorzuschlagen.

## Versionssprung‑Workflow

- **Automatische Dokumentenaktualisierung**: Wie bereits in *reviewfix17_a3* beschrieben, steuert `config/doc_aggregation.json`, ob historische Teilfassungen an zentrale Dokumente angehängt oder ersetzt werden.  Dieses Verhalten bleibt bestehen; der Versionsbump auf `reviewfix17_a4` sorgt lediglich dafür, dass eine neue Teilfassung in den Archiven erscheint.
- **Konfigurationsgestützte Installation**: Der Installer liest das ausgewählte Preset, nutzt die definierte Verzeichnisstruktur und führt das Installationsskript aus dem jeweiligen `VERSION`‑Unterordner aus.  So kann die Installation sowohl in einer Entwicklungsumgebung als auch auf einem Router erfolgen, ohne dass Pfade manuell angepasst werden müssen.
- **Dev‑Workflow für Archivierung**: Im Dev‑Preset verschiebt ein Helper‑Skript alle geladenen Artefakte (z. B. IPK‑ und Tar‑Dateien) aus dem Download‑Ordner in das Arbeitsverzeichnis `_workspace/vrrp-repo`.  Anschließend können diese Dateien via `scp` auf die Nodes kopiert werden, um offline installiert zu werden.

Diese neuen Konzepte gewährleisten, dass sich das Add‑on sowohl in der Entwicklungsumgebung als auch im produktiven Einsatz nahtlos installieren, updaten und debuggen lässt.  Sie machen das Projekt zukunftssicher und erleichtern das Arbeiten mit unterschiedlichen Geräten und OpenWrt‑Versionen.
## 0.5.16-007_reviewfix17_a4_fix1

# Konzepte reviewfix17_a4_fix1

Diese Teilfassung übernimmt die konzeptionellen Neuerungen aus *reviewfix17_a4* und erhöht lediglich die Versionsnummer auf **0.5.16‑007_reviewfix17_a4_fix1**.  Sie enthält keine funktionalen Änderungen gegenüber der Vorversion, sondern dokumentiert die fortgesetzte Verwendung des Preset‑Systems, der Gerätespezifischen OpenWrt‑Profile und des Versionssprung‑Workflows.

## Preset‑System

- **Dev‑Preset**: Für Entwickler:innen, die unter Linux oder Windows arbeiten.  Es definiert Pfade für lokale Spiegel (`_workspace/vrrp-repo`), Download‑Ordner, IPK‑Repository und den aktuellen Arbeitsordner.  Der Installer verwendet diese Angaben, um das aktuellste lokale Paket zu installieren.  Ein Helper‑Skript verschiebt alle heruntergeladenen Tar‑, Zip‑ und IPK‑Dateien aus dem Download‑Ordner in das Arbeitsverzeichnis, sodass diese per `scp` auf OpenWrt‑Nodes übertragen werden können.
- **Node‑Preset**: Für Produktivsysteme (OpenWrt).  Es legt Basisverzeichnisse wie `/root/openwrt-ha-vrrp-current`, `/root/openwrt-ha-vrrp-repo` und `/root/vrrp-ipk-repo` fest.  Der Installer lädt dort Archive aus dem lokalen Repo, erstellt Backups und führt das Setup aus.  Dadurch bleibt das System unabhängig von der Entwicklungsumgebung.
- **OpenWrt‑Versionsermittlung**: Die Preset‑Konfiguration ermöglicht es, eine *ermittelte* oder *angenommene* OpenWrt‑Version für die Zielhardware zu hinterlegen.  Für Mango/GL‑MT300N‑V2 ist OpenWrt 22.03.4 aktuell【92603978916730†L320-L322】, für Lamobo R1 existiert aufgrund der DSA‑Umstellung kein Migrationspfad von 19.07 auf 22.03【633554760445073†L148-L156】 (daher Neuinstallation erforderlich), und für x86‑Geräte können Upgrades per sysupgrade von 21.02 über 22.03 auf 23.05 durchgeführt werden【878966515062870†L23-L27】.  Diese Informationen dienen dazu, den Nutzer:innen sinnvolle Upgrade‑Vorschläge zu machen.
- **Device‑Profile**: In `presets.json` sind Geräteprofile hinterlegt, die upgradefähige OpenWrt‑Versionen sowie EOL‑Hinweise enthalten.  Sie können genutzt werden, um Anwender:innen zu warnen oder alternative Pfade (Neuinstallation) vorzuschlagen.

## Versionssprung‑Workflow

- **Automatische Dokumentenaktualisierung**: Wie bereits in *reviewfix17_a3* beschrieben, steuert `config/doc_aggregation.json`, ob historische Teilfassungen an zentrale Dokumente angehängt oder ersetzt werden.  Dieses Verhalten bleibt bestehen; der Versionsbump auf `reviewfix17_a4_fix1` sorgt lediglich dafür, dass eine neue Teilfassung in den Archiven erscheint.
- **Konfigurationsgestützte Installation**: Der Installer liest das ausgewählte Preset, nutzt die definierte Verzeichnisstruktur und führt das Installationsskript aus dem jeweiligen `VERSION`‑Unterordner aus.  So kann die Installation sowohl in einer Entwicklungsumgebung als auch auf einem Router erfolgen, ohne dass Pfade manuell angepasst werden müssen.
- **Dev‑Workflow für Archivierung**: Im Dev‑Preset verschiebt ein Helper‑Skript alle geladenen Artefakte (z. B. IPK‑ und Tar‑Dateien) aus dem Download‑Ordner in das Arbeitsverzeichnis `_workspace/vrrp-repo`.  Anschließend können diese Dateien via `scp` auf die Nodes kopiert werden.

Diese neue Version fügt kein weiteres Konzept hinzu, sondern dokumentiert die Weiterführung des in *a4* eingeführten Preset‑ und Upgrade‑Workflows.
## 0.5.16-007_reviewfix17_a4_fix2

# Konzepte reviewfix17_a4_fix2

Mit der Version **0.5.16‑007_reviewfix17_a4_fix2** wird das bestehende Konzept rund um Preset‑Profile, versionsspezifische Dokumentation und Upgradepfade um ein zentrales Manager‑Skript erweitert.  Gleichzeitig werden die Readme‑Dateien vereinheitlicht und in einer neuen Ordnerstruktur abgelegt.  Dadurch wird die Pflege der Dokumentation für Entwickler:innen und Administrator:innen erleichtert.

## Manager‑Skript zum Dokumentationsmanagement

- **Einträge hinzufügen:** Über das Skript `manage_docs.sh` (und das Windows‑Gegenstück `manage_docs.ps1`) lassen sich Einträge in die Teilfassungen der aktuellen Version einfügen.  Das Skript nimmt den Dateityp (`concepts`, `architecture`, `changelogs`, `readmes`, `features` oder `known‑issues`) und den Text entgegen und appends ihn an die passende Markdown‑Datei innerhalb von `docs/`.  Wird eine Datei dabei zum ersten Mal angelegt, erhält sie einen einfachen Header mit der Versionsnummer.
- **Version finalisieren:** Optional kann mit dem Parameter `--new-version` ein Versionsbump durchgeführt werden.  In diesem Fall kopiert das Skript die Teilfassungen der aktuellen Version in entsprechende Dateien für die neue Version, aktualisiert die `VERSION`‑Datei und ruft die vorhandenen Helper auf, um zentrale Dokumente (z. B. `ARCHITECTURE.md`, `CONCEPTS.md`, `CHANGELOG.md`) zu regenerieren.  Auf diese Weise lässt sich ein neuer Release‑Tag direkt aus der Entwicklungsumgebung heraus erzeugen.
- **Cross‑Platform‑Support:** Da sowohl eine POSIX‑Shell‑Variante als auch eine PowerShell‑Variante bereitgestellt werden, kann das Skript sowohl auf OpenWrt‑/BusyBox‑Systemen als auch unter Linux oder Windows ausgeführt werden.

## Vereinheitlichte Readme‑Struktur

Die bisher im Verzeichnis `docs/Readme` liegenden Readme‑Dateien werden nach `docs/readmes` migriert und in `docs/readmeas` archiviert.  Alte Dateinamen mit dem Präfix `README_` werden durch den reinen Versionsstring ersetzt.  Dadurch wird der Überblick über die vorhandenen Teilfassungen erleichtert und der Aggregator (`gen-base-md.sh`) kann die Dateien korrekt einsortieren.  Für jede neue Version sollte – sofern nötig – ein entsprechendes Dummy‑Readme angelegt werden, um zumindest Platzhaltertexte für Features, Änderungen oder Installationsnotizen bereitzustellen.

## Weiterführung des Preset‑ und Upgrade‑Konzepts

Wie bereits in den vorherigen Versionen erläutert, basiert die Installation und Konfiguration auf den Preset‑Definitionen in `config/presets.json`.  Je nach Umgebung (`dev` oder `node`) werden unterschiedliche Arbeitsverzeichnisse und Basispfade gesetzt.  Gleichzeitig enthält die Datei Gerätedefinitionen mit dem jeweils empfohlenen OpenWrt‑Release: Mangos verwenden 22.03.4【92603978916730†L320-L322】, Lamobo R1 benötigt eine Neuinstallation, da kein Upgradepfad von 19.07 auf 22.03 existiert【633554760445073†L148-L156】, und für x86 sind Upgrades über 21.02 → 22.03 → 23.05 möglich【878966515062870†L23-L27】.

In dieser Version werden keine neuen Kernkonzepte eingeführt.  Vielmehr wird das bisherige Modell um ein Skript zur leichteren Pflege von Dokumentationsdateien ergänzt und die Dateistruktur vereinheitlicht.  Die Migrationstools und Upgradepfade bleiben unverändert erhalten.
