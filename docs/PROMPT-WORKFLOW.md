# Prompt-Anweisung – Arbeits- & Release-Workflow (current.md, Migrate, Changelog)

**Ziel:** Jede inhaltliche Änderung (Code/UI/API/Docs/Skripte) wird _sofort_ in `docs/releases/current/current.md`
vermerkt. Beim Versionssprung erzeugt der Release-Helper daraus die versionsspezifischen Dateien, Changelogs und Migrationsskripte.

## Grundprinzipien
- Alle UI-Aufrufe gehen über `/usr/sbin/ha-vrrp-api` (JSON). Keine direkten Shell-Aufrufe aus LuCI-Views/CBI.
- Defensive UIs: Fehler als JSON anzeigen, UI bleibt intakt.
- Versionierte Einzel-Dokus gehören unter `docs/releases/<version>/...`.
- Zentrale Übersichten bleiben konsistent (Root & docs): `README.md`, `CHANGELOG.md`, `ARCHITECTURE.md`, `CONCEPTS.md`.

## Bei jeder Änderung (Pflicht!)
1. **Beschreibe die Änderung** knapp in `docs/releases/current/current.md`:
   - Bereich (`ui|api|scripts|docs|migrate|build`), betroffene Dateien, motivierende Begründung.
   - Changelog-Bullet (`- feat/fix: ...`).
   - Falls Migrationsschritte nötig: unter **Migration** notieren oder Codeblock `migrate-sh` hinzufügen.
2. **Commit-Message**:
   - Subject: `[reviewfix16][featurefix3] <scope>: <kurzbeschreibung>`
   - Body: `Version: 0.5.16-007_reviewfix16_featurefix3` + kurze Details (max 5 Zeilen).

## Beim Versionssprung
Nutze den Release-Helper (siehe `scripts/tools/release-helper.sh`):
```bash
./scripts/tools/release-helper.sh all --next 0.5.16-007_reviewfix16_featurefix3 --prev <VORVERSION>
```
- Materialisiert `docs/releases/current/current.md` zu:
  - `docs/changelogs/0.5.16-007_reviewfix16_featurefix3.md` (Changelog-Auszug),
  - `docs/releases/0.5.16-007_reviewfix16_featurefix3/README.md|FEATURES.md|KNOWN-ISSUES.md` (aus Sektionen),
  - `scripts/migrate/migrate-to-0.5.16-007_reviewfix16_featurefix3.sh` (aus `migrate-sh` Codeblock oder Standard).
- Synchronisiert `./README.md`, `./CHANGELOG.md`, `./ARCHITECTURE.md`, `./CONCEPTS.md` und deren Pendants unter `./docs/`.
- Legt eine **leere** neue `docs/releases/current/current.md` für die nächste Iteration an.
