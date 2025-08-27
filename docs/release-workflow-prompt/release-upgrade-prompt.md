Titel: Release-Workflow für openwrt-ha-vrrp (reviewfix/featurefix, Docs & Migration)
Kontext:

Versionsschema: MAJOR.MINOR.PATCH-REV_reviewfix{N}[_featurefix{M}] (z. B. 0.5.16-007_reviewfix16_featurefix2).

Commit-Slices: kleine, fokussierte Commits mit Präfixen feat:, fix:, docs:, build:, refactor:, chore:.

Namenskonvention für Commits/PRs:

Subject: [reviewfix16][featurefix2] <bereich>: <kurzbeschreibung>

Body: enthält Version: <vollständige-version>, Scope: <ui|api|docs|scripts|migrate>, ggf. Breaking Changes.

UI greift ausschließlich über /usr/sbin/ha-vrrp-api auf Funktionen/uci/scripts zu; keine direkten Shell-Aufrufe aus Templates/CBI.

Versionierte Docs (Dateinamen mit reviewfix*/hotfix*/Version) liegen unter docs/changelogs/<version>.md bzw. docs/releases/<version>/….

Zentrale Übersichtsdateien sind dupliziert (root & docs):

./README.md, ./CHANGELOG.md, ./ARCHITECTURE.md, ./CONCEPTS.md

./docs/README.md, ./docs/CHANGELOG.md, ./docs/ARCHITECTURE.md, ./docs/CONCEPTS.md
Diese müssen synchron gehalten werden (Titel, „Current Version: …“, kurz Synopsis).

Aufgabe:
Für eine neue Version {NEXT_VERSION} auf Basis {PREV_VERSION}:

Version bump & Commit/Tag-Namen zusammensetzen:

Tag-Vorschlag: v{NEXT_VERSION}

Release-Branch: release/reviewfix{N}[_featurefix{M}]

Commit-Präfixe wie oben.

Docs konsistent halten:

In allen root- und docs-Hauptdateien (README/CHANGELOG/ARCHITECTURE/CONCEPTS) die Zeile Current Version: … aktualisieren/ergänzen.

docs/CHANGELOG.md um einen Abschnitt für {NEXT_VERSION} erweitern, inkl. Stichpunkte der Slices.

Versionierte Einzel-MDs aus docs/ erkennen (Dateiname enthält Version/reviewfix/hotfix) und nach docs/changelogs/ bzw. docs/releases/{NEXT_VERSION}/ verschieben/umbenennen.

Skripte aufräumen:

Direkt unter scripts/ liegende versionierte gen*, migrate*, installer*, uninstaller* entfernen (alles gehört in Unterordner).

Migration erzeugen:

Ein MIGRATE-Script scripts/migrate/migrate-to-{NEXT_VERSION}.sh, das 2 & 3 auf Bestandsbäumen anwendet (mit git mv fallback auf mv).

Installer/Uninstaller für {NEXT_VERSION} erzeugen (nur Wrapper; Leeren der LuCI-Caches).

Optional Packaging: Full-Tar(s) unter /tmp erzeugen:

openwrt-ha-vrrp-{NEXT_VERSION}_full.tar.gz

Git-Schritte:

Alle Änderungen committen (chore(release): bump to {NEXT_VERSION}) und Tag-Vorschlag ausgeben.

Output-Erwartung:

Diff/Änderungsliste (welche Dateien verändert, welche MDs verschoben/umbenannt, welche Scripts entfernt).

Neues MIGRATE-Script (voller Code, Pfad: scripts/migrate/migrate-to-{NEXT_VERSION}.sh).

Neue Installer/Uninstaller-Skripte (volle Codes, Pfade in scripts/installer/ & scripts/uninstaller/).

Konsistenz-Checkliste (welche zentralen MDs jetzt synchron sind).

Kommandos zum Bauen/Taggen.

Fehlerbehandlung: Der Prozess soll beim ersten Fehler klar abbrechen; schreib mir die Ursache plus Fix-Vorschlag.

Parameter, die du erhältst:
{NEXT_VERSION}, {PREV_VERSION}, Liste der Slice-Commits (als Stichpunkte), kurze Release-Synopsis.

Wichtig:

Keine UI-Änderungen ohne API-Helper-Pfad; nur JSON-Rückgaben.

Defensive Defaults; niemals die UI „kaputt“ rendern.

Shell-Skripte strikt: set -euo pipefail.