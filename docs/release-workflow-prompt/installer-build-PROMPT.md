# Prompt-Anweisung – Installer-Build-Workflow

Dieser Prompt beschreibt die Schritte, um Installations‑ und Deinstallations‑Skripte sowie IPK‑Pakete für eine neue Version des HA‑VRRP‑Addons zu erzeugen.  Er dient als Leitfaden für Entwickler*innen, die den Build‑Prozess reproduzierbar gestalten und sicherstellen wollen, dass Installationen und Updates stabil ablaufen.

## Schritte

1. **Versionsbump vorbereiten**: Aktualisiere die Datei `VERSION` im Repository auf die neue Versionsnummer (z. B. `0.5.16-007_reviewfix17_a1`).  Führe anschließend den Release‑Helper aus, um aus der aktuellen Arbeitsversion die neue Version abzuleiten und Migrationsskripte zu generieren:

   ```bash
   ./scripts/tools/release-helper.sh all --next <NEW_VERSION> --prev <PREV_VERSION>
   ```

2. **Installer und Uninstaller generieren**: Erzeuge die Skripte `scripts/installer/installer-<NEW_VERSION>.sh` und `scripts/uninstaller/uninstaller-<NEW_VERSION>.sh`.  Diese Skripte sollten alle notwendigen Konfigurations- und Programmbestandteile nach `/etc/ha-vrrp` bzw. in die Systempfade kopieren, bestehende Backups respektieren und bei der Deinstallation alle Änderungen wieder entfernen.  Als Vorlage dienen die Installer/Uninstaller der vorherigen Version.

3. **Build‑Umgebung vorbereiten**: Stelle sicher, dass alle Abhängigkeiten in den Konfigurationsdateien (`config/dependencies.conf`, `config/features.conf`) korrekt gesetzt sind.  Passe gegebenenfalls Ziele im `Makefile` an, damit die Paket‑Builds erfolgreich durchlaufen.

4. **Pakete bauen**: Baue die IPK‑Pakete für das Add‑on und die LuCI‑App innerhalb einer OpenWrt‑SDK‑Umgebung, zum Beispiel mit:

   ```bash
   make package/ha-vrrp/compile V=s
   make package/luci-app-ha-vrrp/compile V=s
   ```

   Teste anschließend die Installation der erzeugten `.ipk`‑Pakete auf einem Testrouter.  Achte darauf, dass die Services starten und die UI erreichbar ist.

5. **Dokumentation aktualisieren**: Ergänze `docs/releases/current/current.md` um einen Abschnitt `install`, in dem die Installations‑ und Deinstallationsschritte beschrieben werden.  Aktualisiere `docs/INSTALLER_README.md` oder `docs/INSTALL.md`, falls sich Parameter oder Befehle geändert haben.

6. **Migration und Rollback testen**: Führe `scripts/migrate/run_migrations.sh` in einer Testumgebung aus, um sicherzustellen, dass bestehende Konfigurationen korrekt in die neue Version migriert werden.  Überprüfe auch, dass der Uninstaller eine definierte Rückabwicklung durchführt und Backups korrekt wiederherstellt.

7. **Release‑Paket bauen**: Nutze `scripts/helpers/helper_build_package.sh`, um das vollständige Release‑Archiv (`openwrt-ha-vrrp-<NEW_VERSION>.tar.gz` sowie `<NEW_VERSION>_full.tar.gz`) zu erzeugen.  Vergewissere dich vor dem Packen, dass `README.md`, `CHANGELOG.md`, `ARCHITECTURE.md` und `CONCEPTS.md` in root und `docs/` die aktuelle Versionsnummer tragen (dies geschieht über die Helper‑Skripte).

8. **Commit und Tag**: Committe alle Änderungen mit einer aussagekräftigen Commit‑Message (z. B. `chore(release): bump to <NEW_VERSION>`) und erstelle einen Git‑Tag `v<NEW_VERSION>`.  Dokumentiere in der Commit‑Nachricht die relevanten Änderungen (Installer, Pakete, Migration).

## Hinweise

* Alle Shell‑Skripte sollten mit `set -euo pipefail` beginnen und klare Logausgaben produzieren, damit Fehler früh erkannt werden können.
* Beim Erstellen der IPK‑Pakete dürfen nur die ausführbaren Dateien und Konfigurationen aus dem `files/`‑Verzeichnis in das Paket aufgenommen werden, keine Entwicklerartefakte.
* Wenn beim Bau oder der Migration Fehler auftreten, muss der Installer einen definierten Rollback durchführen können (z. B. Einspielen des zuletzt angelegten Backups).
* Nutze für systemweite Einstellungen wann immer möglich die UCI‑Schnittstelle statt Shell‑Kommandos, um die Konsistenz der Konfiguration sicherzustellen.