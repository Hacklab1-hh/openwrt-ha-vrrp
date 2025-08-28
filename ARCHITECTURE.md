# ARCHITECTURE

## 0.5.16-007_reviwefix17.md

# Architektur‑Notizen reviwefix17

In der Version **0.5.16‑007_reviwefix17** wurde die Architektur des HA‑VRRP‑Add‑ons wie folgt erweitert:

- **Schichtenmodell für die UI**: Die LuCI‑Oberfläche besteht aus Controller, Modell (CBI) und Views.  Für jede Funktionalität (Übersicht, Status, Allgemein, Peers & Sync, Backup/Restore, Erweitert) gibt es einen eigenen View‑ und Modell‑Layer.  Der Controller registriert zusätzlich den JSON‑Status‑Endpunkt `status_json`.
- **Helper‑Skripte**: Ein neuer Satz von Helpers (`helper_update_version_tags.sh`, `helper_sync_docs.sh`, `helper_smoketests.sh`, `helper_build_package.sh`) automatisiert die Pflege der Dokumente und den Release‑Prozess.  Diese Scripts werden aus den Manager‑Skripten (Installer, Uninstaller, Migration) aufgerufen.
- **Status‑API**: Über einen neuen CGI‑Handler (`/cgi‑bin/ha‑vrrp‑status`) sowie eine LuCI‑Action wird der Betriebszustand als JSON ausgegeben.  Der Status liest die aktuelle Version (`/etc/ha‑vrrp/version`), prüft den Keepalived‑Prozess und den letzten Migrationszustand (`/etc/ha‑vrrp/state.json`).
- **Synchronisationsschicht**: Die Sync‑Skripte laden ZIP‑Archive von GitHub und entpacken sie auf dem lokalen System, sodass `current` immer auf den aktuell installierten Stand zeigt.  Dadurch wird der Einsatz ohne installiertes `git` und in Offline‑Umgebungen unterstützt.
- **Migrationsframework**: Die unified Upgrade‑Path‑Definition wurde um diese Version ergänzt.  Das zugehörige Migration‑Skript dokumentiert das Update, erstellt ein Backup und setzt die neue Version.

Diese Änderungen festigen die modulare Architektur des Projekts, erleichtern die Wartung und ermöglichen eine nahtlose Integration in andere Systeme.
## 0.5.16-007_reviewfix17_a4_fix4.md

# Architektur – 0.5.16‑007_reviewfix17_a4_fix4

Diese Teilfassung beschreibt die neuen Komponenten zur
Download‑Synchronisation und Verteilung der Artefakte in der
Version **0.5.16‑007_reviewfix17_a4_fix4**.  Sie ergänzt die bestehende
Architektur (siehe Vorversionen) um eine datenzentrierte Sicht auf
den Entwicklermodus.

## Workspace‑Verzeichnisstruktur

Im Dev‑Modus werden alle relevanten Dateien unter dem
Benutzer‑Verzeichnis `_workspace` abgelegt.  Dieses Release
definiert folgende Struktur:

* **`_workspace/vrrp-repo`** – enthält alle heruntergeladenen
  Release‑Archive (`openwrt-ha-vrrp-*.tar.gz`, `.tar`, `.zip`).
* **`_workspace/vrrp-ipk-repo`** – enthält die zugehörigen
  IPK‑Pakete (`ha-vrrp_*-all.ipk`).

Diese Ordner werden von den neuen Skripten `dev-harvest`
automatisch angelegt und gefüllt (alias: `copy_downloads`).

## Kopier- und Verteilskripte

### dev-harvest.sh / dev-harvest.ps1

Diese Komponente durchsucht das Download‑Verzeichnis des Users
(`~/Downloads` bzw. `%USERPROFILE%\Downloads`) sowie ein optionales
Unterverzeichnis nach Artefakten.  Gefundene Dateien werden in die
oben genannten Workspace‑Ordner kopiert.  Hierdurch entsteht eine
lokale Sammlung aller Versionen, die anschließend für Deployments
verwendet werden kann.  Die früheren Kommandos `copy_downloads`
und `copy_downloads.ps1` fungieren weiterhin als Aliase und leiten
auf dieses Skript um.

### dev-sync-nodes.sh / dev-sync-nodes.ps1

Dieses Skript erwartet optional eine Angabe, welche Zielknoten
adressiert werden sollen (`1`, `2` oder `all`).  Für jeden Knoten
werden via SSH die Zielverzeichnisse `/root/vrrp-repo` und
`/root/vrrp-ipk-repo` angelegt.  Anschließend überträgt das Skript
alle Dateien aus dem lokalen Workspace in die jeweiligen Verzeichnisse.
Dadurch können mehrere Router synchron mit denselben Paketen
versorgt werden.  Die früheren Kommandos `upload_nodes` und
`upload_nodes.ps1` dienen als Aliase für diese Funktion.

## Wrapper auf oberster Ebene

Die Dateien `script.sh`, `script.ps1` und `script.bat` fungieren als
einheitliche CLI‑Wrapper.  Sie leiten Unterkommandos an die jeweiligen
Hilfsskripte weiter.  Mit diesem Release unterstützen die Wrapper
die neuen Typen `dev-harvest` und `dev-sync-nodes` (bzw. deren Aliase
`copy_downloads` und `upload_nodes`) neben den bestehenden
Subkommandos (`manage_docs`, `readme`, `help`).

## Integration in den Versionsworkflow

Beim Erstellen eines neuen Releases kann ein Entwickler nun wie folgt
vorgehen:

1. **Pakete sammeln:** Mit `script.sh --type dev-harvest --action run`
   (oder dem Alias `script.sh copy_downloads`) die zuletzt
   heruntergeladenen Release‑Artefakte und IPKs in das lokale
   Workspace kopieren.
2. **Nodes synchronisieren:** Die lokal gespeicherten Pakete mit
   `script.sh --type dev-sync-nodes --action run [--nodes all|1|2]`
   (oder dem Alias `script.sh upload_nodes`) an die Router verteilen.
3. **Installation:** Auf dem Router kann anschließend der Installer
   ausgeführt werden, um das gewünschte Release einzuspielen.

Diese Ergänzungen unterstützen den Workflow für Multi‑Node‑Setups,
ohne die bestehende Architektur der Installation, Migration und
Konfiguration zu verändern.
## 0.5.16-007_reviewfix17_a4_fix3.md

# Architektur‑Notizen reviewfix17_a4_fix3

Die Version **0.5.16‑007_reviewfix17_a4_fix3** erweitert das vorhandene System um komfortable Hilfsskripte zum Lesen und Pflegen der Dokumentation.  Gleichzeitig bleiben alle in den Vorgängerversionen eingeführten Konzepte – wie das Preset‑System, die Geräteprofile und der versionierte Upgrade‑Workflow – bestehen.  Im Fokus dieses Fix‑Releases stehen die CLI‑Werkzeuge, die Entwickler:innen und Anwender:innen direkten Zugriff auf die versionsspezifischen Readme‑ und Hilfedateien ermöglichen.

## Neue CLI‑Werkzeuge

- **scripts/readme.sh**: Dieses Skript zeigt den Inhalt der README‑Teilfassung für die aktuelle oder eine angegebene Version an.  Wird kein Parameter übergeben, liest es die aktuelle Version aus der Datei `VERSION` und gibt die entsprechende Datei aus `docs/readmes/` aus.  Über einen Parameter kann ein beliebiger Versionsstring, der Name eines Tarballs (`openwrt-ha-vrrp-<version>.tar.gz`), eines IPK‑Pakets (`ha-vrrp_<version>-*.ipk`) oder ein Commit‑Tag übergeben werden; das Skript extrahiert daraus den Versionsanteil und gibt das passende Readme aus.
- **scripts/help.sh**: Dieses Hilfeskript beschreibt die Nutzung der wichtigsten Helfer des Projekts.  Es listet die Parameter für `manage_docs.sh` sowie die Verwendung von `readme.sh` auf und dient als Einstiegspunkt für neue Entwickler:innen.

## Integration mit dem Dokumentationsworkflow

Die neuen Skripte bauen auf dem bestehenden Dokumentationsworkflow auf:

- **Versionsspezifische Readmes**: Alle README‑Teildokumente werden im Ordner `docs/readmes` verwaltet.  `readme.sh` findet anhand des Versionsstrings die entsprechende Datei.  Für alte oder manuelle Entwürfe gibt es zusätzlich das Archivverzeichnis `docs/readmeas`.
- **Manage‑Docs‑Skript**: Mit `manage_docs.sh` lassen sich weiterhin Einträge zu den Teilfassungen hinzufügen und – per `--new-version` – neue Releases finalisieren.  Nach einem Versionsbump aktualisieren die Helper‑Skripte (`helper_update_version_tags.sh`, `helper_sync_docs.sh` und `gen-base-md.sh`) automatisch die zentralen Dokumente und die History.

## Upgradepfad

Wie alle Releases fügt auch **a4_fix3** einen neuen Eintrag in `config/upgradepath.unified.json` hinzu.  Der Eintrag verweist auf den Vorgänger `a4_fix2` als `parent` und benennt das zugehörige Archiv.  Das Migrationsskript (`migrate-to-0.5.16-007_reviewfix17_a4_fix3.sh`) bleibt eine leere Hülle, da dieses Release keine funktionalen Änderungen am Runtime‑Verhalten vornimmt.
## 0.5.16-007_reviewfix17_a4_fix2.md

# Architektur‑Notizen reviewfix17_a4_fix2

Die Version **0.5.16‑007_reviewfix17_a4_fix2** setzt die in *a4_fix1* eingeführte Architektur unverändert fort und erweitert sie um ein zentrales Manager‑Skript zur Pflege der Dokumentation.  Alle zuvor definierten Presets, Geräteprofile und der Versionssprung‑Workflow bleiben bestehen.

## Zentrales Manager‑Skript

- **manage_docs.sh / manage_docs.ps1**: Diese neuen Helper‑Skripte ermöglichen es, während der Entwicklung schnell Notizen und Einträge in die Versionsspezifischen Teilfassungen zu schreiben.  Sie akzeptieren Parameter für den Dateityp (z. B. `concepts`, `architecture`, `changelogs`, `readmes`, `features` oder `known-issues`) und fügen den übergebenen Text am Ende der entsprechenden Datei für die aktuelle Version an.  Optional kann mittels `--new-version` ein neuer Versions‑Tag gesetzt werden; das Skript kopiert dann die bestehenden Teilfassungen für Konzepte, Architektur usw. in eine neue Datei, schreibt das `VERSION`‑File fort und ruft die bestehenden Helper (`helper_update_version_tags.sh` und `helper_sync_docs.sh`) auf, um die zentralen Dokumente und Historien zu aktualisieren.  Es ist in einer POSIX‑Shell‑Version und in einer PowerShell‑Version für Windows verfügbar, sodass sowohl unter BusyBox/OpenWrt als auch unter Linux und Windows dieselbe Funktionalität genutzt werden kann.

## Integration der Readme‑Dateien

- **Migration der `Readme`‑Ordners:** Die bisher im Verzeichnis `docs/Readme` abgelegten versionsspezifischen Readme‑Dateien werden nun in der Ordnerstruktur `docs/readmes` geführt.  Jede Datei trägt dabei nur noch den Versionsstring als Namen (z. B. `0.5.4.md` anstelle von `README_0.5.4.md`).  Diese Vereinheitlichung erleichtert die Aggregation der README‑Inhalte in `docs/readmes.md` und vermeidet Namenskonflikte zwischen alten und neuen Dateiformaten.  Ein zusätzliches Verzeichnis `docs/readmeas` dient dazu, ältere oder manuell gepflegte Readme‑Entwürfe abzulegen; es wird nicht von der Aggregation berücksichtigt, sondern lediglich als Archiv geführt.

## Workflow bei Versionssprüngen

Die bereits in *a4* und *a4_fix1* beschriebenen Abläufe gelten weiterhin:

- **Versionstag setzen:** Vor dem Verpacken oder Bereitstellen eines neuen Releases wird mit dem Manager‑Skript die neue Version in der `VERSION`‑Datei hinterlegt.  Anschließend aktualisieren `helper_update_version_tags.sh` und `helper_sync_docs.sh` alle zentralen Dokumente und hängen die Teilfassungen an die History‑Dateien an.
- **Upgradepfad ergänzen:** Für jede neue Version wird ein weiterer Eintrag in `config/upgradepath.unified.json` angelegt.  Dort wird die Vorgängerversion als `parent` eingetragen und der Archivname vermerkt.  Somit können `run_migrations.sh` oder die Installer‑Skripte die korrekte Reihenfolge der Migrationsskripte bestimmen.
- **Konfigurationsprofile nutzen:** Der Installer liest weiterhin `config/presets.json` aus, um abhängig vom Zielsystem (Dev oder Node) die korrekten Pfade und Arbeitsverzeichnisse zu wählen.  Darüber hinaus enthalten die Geräteprofile die aktuell unterstützten OpenWrt‑Versionen für Mango/GL‑MT300N‑V2, Lamobo R1 und x86【92603978916730†L320-L322】【633554760445073†L148-L156】【878966515062870†L23-L27】.

Diese Teilfassung fügt somit vor allem das Manager‑Skript und die Konsolidierung der Readme‑Dateien hinzu.  Sie stellt sicher, dass die bestehende Architektur mit ihren Presets, Pfaden und Upgrade‑Workflows auch nach dem Versionssprung konsistent bleibt.
## 0.5.16-007_reviewfix17_a4_fix1.md

# Architektur‑Notizen reviewfix17_a4_fix1

Die Version **0.5.16‑007_reviewfix17_a4_fix1** übernimmt die in *reviewfix17_a4* eingeführte Architektur vollständig.  Sie enthält das konfigurierbare Preset‑System, das unterschiedliche Basispfade für Entwicklungsumgebungen und produktive Nodes berücksichtigt, sowie den beschriebenen Workflow für Versionssprünge.  Es gibt keine funktionalen Änderungen gegenüber der Vorversion; diese Teilfassung dokumentiert lediglich den Versionsbump und die Übernahme der bestehenden Architektur.

## Neues Preset‑System

- **Konfigurationsdatei `config/presets.json`**: In dieser Datei werden **Pre‑Sets für `dev` und `node`** definiert.  Jedes Preset beschreibt Basisverzeichnisse, Repository‑Pfade und Arbeitsordner, sowohl für Linux als auch für Windows (im Entwicklungsmodus) oder für OpenWrt‑Umgebungen (im Node‑Modus).  Dadurch kann der Installer das passende Layout wählen und ist in der Lage, Artefakte wie Tarball‑Archive oder IPK‑Pakete in die korrekten Verzeichnisse zu kopieren.  Das Dev‑Preset definiert zum Beispiel, dass sich der Workspace unter `~/Downloads` bzw. `%USERPROFILE%\Downloads` befindet und dass Archive in einen lokalen `_workspace/vrrp-repo` verschoben werden.  Das Node‑Preset legt fest, dass Installationen unter `/root/openwrt-ha-vrrp-current` stattfinden und Repositories nach `/root/openwrt-ha-vrrp-repo` kopiert werden.
- **Unterstützte OpenWrt‑Versionen**: Innerhalb derselben Datei werden als Referenz die aktuell unterstützten OpenWrt‑Versionen pro Gerät hinterlegt.  Für das Mango/GL‑MT300N‑V2 wird OpenWrt 22.03.4 als aktuelle Version ausgewiesen【92603978916730†L320-L322】.  Für Lamobo R1 gibt es keinen Migrationspfad von 19.07 auf 22.03【633554760445073†L148-L156】.  Für generische x86‑Geräte können Upgrades via sysupgrade von 21.02 über 22.03 auf 23.05 durchgeführt werden【878966515062870†L23-L27】.  Diese Angaben dienen dazu, im Installer optionale Upgrades vorzuschlagen oder kompatible Firmware zu ermitteln.
- **Arbeitsordner `current`**: Im Dev‑Preset ist der aktuelle Arbeitsordner immer das Verzeichnis, aus dem der Installer ausgeführt wird.  Im Node‑Preset wird hingegen in `/root/openwrt-ha-vrrp-current` gearbeitet; dort liegen auch die generierten Konfigurationsdateien und Symlinks.

## Workflow bei Versionssprüngen

- **Basisdateien aktualisieren**: Bei jedem Versionssprung wird das Helper‑Skript `helper_update_version_tags.sh` ausgeführt.  Es aktualisiert den Versions‑Header in zentralen Dateien (`README.md`, `CHANGELOG.md`, `ARCHITECTURE.md`, `CONCEPTS.md`, `FEATURES.md`, `KNOWN_ISSUES.md`) und entfernt alte Fix‑Suffixe.  Anschließend ruft `helper_sync_docs.sh` den Aggregator `gen-base-md.sh` auf, der anhand der Konfiguration in `config/doc_aggregation.json` die zentralen Dateien neu generiert (entweder werden Teilfassungen angehängt oder ausschließlich die neueste Fassung verwendet).
- **Pflege des Upgrade‑Pfads**: Für jede neue Version wird in `config/upgradepath.unified.json` ein neues Element ergänzt, das die Vorgängerversion, das zugehörige Archiv und optional ein Migrationsskript benennt.  Bei `a4_fix1` wird beispielsweise eine Zeile mit der Version `0.5.16-007_reviewfix17_a4_fix1` hinzugefügt, die auf `0.5.16-007_reviewfix17_a4` verweist.  Tools wie `run_migrations.sh` können damit die korrekte Reihenfolge der Migrationsskripte ermitteln.
- **Auswahl des Presets**: Der Installer liest `presets.json` und entscheidet anhand der Umgebung (OpenWrt vs. Desktop) und der Nutzereingaben, welches Preset zur Anwendung kommt.  Dadurch sind weitere Anpassungen – etwa andere Basispfade oder zusätzliche Pakete – zentral konfigurierbar und müssen nicht in den Shell‑Skripten selbst geändert werden.

Diese Teilfassung enthält keine neuen architektonischen Konzepte, sondern stellt sicher, dass die Architektur aus der Vorgängerversion *a4* in der neuen Version konsistent weitergeführt wird.
## 0.5.16-007_reviewfix17_a4.md

# Architektur‑Notizen reviewfix17_a4

Die Version **0.5.16‑007_reviewfix17_a4** erweitert die bestehende Architektur um ein konfigurierbares Preset‑System und berücksichtigt unterschiedliche Basispfade für Entwicklungsumgebungen und produktive Nodes.  Außerdem beschreibt sie den Workflow für Versionssprünge, damit die Basisdateien mit den Helpern korrekt erstellt werden.

## Neues Preset‑System

- **Konfigurationsdatei `config/presets.json`**: In dieser Datei werden **Pre‑Sets für `dev` und `node`** definiert.  Jedes Preset beschreibt Basisverzeichnisse, Repository‑Pfade und Arbeitsordner, sowohl für Linux als auch für Windows (im Entwicklungsmodus) oder für OpenWrt‑Umgebungen (im Node‑Modus).  Dadurch kann der Installer das passende Layout wählen und ist in der Lage, Artefakte wie Tarball‑Archive oder IPK‑Pakete in die korrekten Verzeichnisse zu kopieren.  Das Dev‑Preset definiert zum Beispiel, dass sich der Workspace unter `~/Downloads` bzw. `%USERPROFILE%\Downloads` befindet und dass Archive in einen lokalen `_workspace/vrrp-repo` verschoben werden.  Das Node‑Preset legt fest, dass Installationen unter `/root/openwrt-ha-vrrp-current` stattfinden und Repositories nach `/root/openwrt-ha-vrrp-repo` kopiert werden.
- **Unterstützte OpenWrt‑Versionen**: Innerhalb derselben Datei werden als Referenz die aktuell unterstützten OpenWrt‑Versionen pro Gerät hinterlegt.  Für das Mango/GL‑MT300N‑V2 wird OpenWrt 22.03.4 als aktuelle Version ausgewiesen【92603978916730†L320-L322】.  Für Lamobo R1 gibt es keinen Migrationspfad von 19.07 auf 22.03【633554760445073†L148-L156】.  Für generische x86‑Geräte können Upgrades via sysupgrade von 21.02 über 22.03 auf 23.05 durchgeführt werden【878966515062870†L23-L27】.  Diese Angaben dienen dazu, im Installer optionale Upgrades vorzuschlagen oder kompatible Firmware zu ermitteln.
- **Arbeitsordner `current`**: Im Dev‑Preset ist der aktuelle Arbeitsordner immer das Verzeichnis, aus dem der Installer ausgeführt wird.  Im Node‑Preset wird hingegen in `/root/openwrt-ha-vrrp-current` gearbeitet; dort liegen auch die generierten Konfigurationsdateien und Symlinks.

## Workflow bei Versionssprüngen

- **Basisdateien aktualisieren**: Bei jedem Versionssprung wird das Helper‑Skript `helper_update_version_tags.sh` ausgeführt.  Es aktualisiert den Versions‑Header in zentralen Dateien (`README.md`, `CHANGELOG.md`, `ARCHITECTURE.md`, `CONCEPTS.md`, `FEATURES.md`, `KNOWN_ISSUES.md`) und entfernt alte Fix‑Suffixe.  Anschließend ruft `helper_sync_docs.sh` den Aggregator `gen-base-md.sh` auf, der anhand der Konfiguration in `config/doc_aggregation.json` die zentralen Dateien neu generiert (entweder werden Teilfassungen angehängt oder ausschließlich die neueste Fassung verwendet).
- **Pflege des Upgrade‑Pfads**: Für jede neue Version wird in `config/upgradepath.unified.json` ein neues Element ergänzt, das die Vorgängerversion, das zugehörige Archiv und optional ein Migrationsskript benennt.  Bei `a4` wird beispielsweise eine Zeile mit der Version `0.5.16-007_reviewfix17_a4` hinzugefügt, die auf `0.5.16-007_reviewfix17_a3` verweist.  Tools wie `run_migrations.sh` können damit die korrekte Reihenfolge der Migrationsskripte ermitteln.
- **Auswahl des Presets**: Der Installer liest `presets.json` und entscheidet anhand der Umgebung (OpenWrt vs. Desktop) und der Nutzereingaben, welches Preset zur Anwendung kommt.  Dadurch sind weitere Anpassungen – etwa andere Basispfade oder zusätzliche Pakete – zentral konfigurierbar und müssen nicht in den Shell‑Skripten selbst geändert werden.

Diese Erweiterungen sorgen dafür, dass das Add‑on sich sowohl in der Entwicklungsumgebung als auch im produktiven Einsatz flexibel anpassen lässt.  Der Versionssprung‑Workflow bleibt reproduzierbar und stellt sicher, dass neue Versionen korrekt integriert werden.
## 0.5.16-007_reviewfix17_a3.md

# Architektur‑Notizen reviewfix17_a3

Die Version **0.5.16‑007_reviewfix17_a3** bringt eine neue Ebene der Konfigurierbarkeit für die automatische Dokumentenaggregation.  Während in *reviewfix17_a2* die Grundlage für die Konsolidierung von Dateien gelegt wurde, ermöglicht diese Version über eine JSON‑Konfiguration feinere Einstellungen.

Wichtige Änderungen:

- **Konfigurierbare Aggregation**: Im Ordner `config/` liegt nun die Datei `doc_aggregation.json`.  Sie definiert für jede zentrale Markdown‑Datei (z. B. `architecture.md`, `concepts.md`, `features.md`, `readmes.md`, `known-issues.md`), ob neue Teilfassungen *angehängt* werden (`"append"`) oder ob die zentrale Datei ausschließlich aus der jeweils neuesten Teilfassung *erweitert* wird (`"extend"`).  Dadurch lässt sich das Verhalten des Helpers `gen-base-md.sh` ohne Codeänderungen anpassen.
- **Erweiterter Aggregator**: Das Skript `scripts/gen-base-md.sh` liest diese Konfiguration und generiert die zentralen Dateien entsprechend.  Im *Append*-Modus werden alle Versionen (neueste zuerst) in die zentrale Datei aufgenommen; im *Extend*-Modus besteht die zentrale Datei nur aus der aktuellsten Teilfassung.  Die überarbeiteten zentralen Dateien werden weiterhin bei jedem Aufruf von `helper_sync_docs.sh` und `helper_build_package.sh` erzeugt.
- **Dokumentation der Konfiguration**: Die Verfügbarkeit und Nutzung dieser Konfiguration ist sowohl in den Architektur‑ als auch in den Konzept‑Dokumentationen vermerkt.  Entwicklerinnen und Entwickler können durch Anpassen der JSON‑Datei steuern, welche Teile der Historie in den zentralen Dokumenten sichtbar sein sollen.

Diese Anpassungen erhöhen die Flexibilität beim Dokumenten‑Build‑Prozess und verbessern die Anpassbarkeit an projektinterne Präferenzen, ohne die Funktionsweise des Add‑ons zu beeinträchtigen.
## 0.5.16-007_reviewfix17_a2.md

# Architektur‑Notizen reviewfix17_a2

In der Version **0.5.16‑007_reviewfix17_a2** wurde die Dokumentations‑ und Build‑Infrastruktur des HA‑VRRP‑Add‑ons nochmals erweitert.  Diese Teilfassung dient dazu, den aktuellen Stand der Architekturänderungen für die automatische Zusammenführung in `ARCHITECTURE.md` festzuhalten.

Die wichtigsten Punkte dieser Version sind:

- **Neue Basisdokumente**: Neben den bisherigen Changelogs werden jetzt auch README‑, Known‑Issues‑ und Features‑Dateien versionsspezifisch gepflegt.  Sie wurden in die neuen Verzeichnisse `docs/readmes`, `docs/known-issues` und `docs/features` verschoben.  Die Dateinamen entsprechen ausschließlich der jeweiligen Version (z. B. `0.5.16-007_reviewfix17_a2.md`), sodass Skripte diese Dateien leichter erkennen und verarbeiten können.
- **Aggregation per Helper**: Ein neues Helper‑Skript (`gen-base-md.sh`) konsolidiert die Inhalte aller versionsspezifischen Dokumente (Changelogs, Konzepte, Architektur, Features, Known‑Issues und Readmes) in zentrale Markdown‑Dateien.  Dieses Skript wird nun automatisch von `helper_sync_docs.sh` und `helper_build_package.sh` aufgerufen, wodurch die aggregierten Übersichten (`architecture.md`, `concepts.md`, `changelogs.md`, `readmes.md`, `known-issues.md` und `features.md`) bei jedem Release zuverlässig aktualisiert werden.
- **Spezialisierte Architektur‑Dateien**: Zusätzlich zu den globalen Architekturdokumenten wurden für die Teilmodule Installer, Migration, UI und Uninstaller eigene Architekturdateien erstellt (z. B. `architecture_installer.md`).  Diese neuen Dateien beschreiben die Struktur und die Beziehungen der jeweiligen Teilmodule detailliert und erleichtern die Einarbeitung neuer Entwickelnder.

Diese Änderungen betreffen primär die Dokumentations‑ und Build‑Infrastruktur und haben keinen Einfluss auf die Kernlogik des Add‑ons.
## 0.5.16-007_reviewfix17_a1.md

# Architektur‑Notizen reviewfix17_a1

In der Version **0.5.16‑007_reviewfix17_a1** wurden die in *reviwefix17* eingeführten Architekturverbesserungen weiter konsolidiert und dokumentiert.  Diese Teilfassung dient dazu, den aktuellen Stand für die automatische Zusammenführung in `CONCEPTS.md`/`ARCHITECTURE.md` festzuhalten.

Die wichtigsten Punkte dieser Version sind:

- **Konsolidierung der Dokumente**: Alle Changelog‑Dateien wurden in das neue Verzeichnis `docs/changelogs` verschoben.  Die Namen der Teilfassungen folgen nun konsequent dem Muster `<VERSION>.md`, wodurch Skripte und Release‑Workflows die Dateien leichter erkennen können.
- **UI‑Build‑Workflow**: Ein dedizierter Prompt (`docs/release-workflow-prompt/ui-build-PROMPT.md`) beschreibt nun, wie die LuCI‑UI modular entwickelt, fehlertolerant gestaltet und mittels JSON‑Status‑API erweitert wird.
- **Helper‑Anpassungen**: `helper_build_package.sh` schließt das alte Verzeichnis `docs/changelog` aus, um doppelte Dateien im Release‑Archiv zu verhindern.  Die Migrations‑ und Release‑Skripte verweisen ausschließlich auf `docs/changelogs`.

Diese Änderungen betreffen primär die Dokumentations‑ und Build‑Infrastruktur und haben keinen Einfluss auf die Kernlogik des Add‑ons.
