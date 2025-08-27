# Prompt-Anweisung – UI‑Build‑Workflow

Dieser Prompt beschreibt die Schritte, um die Weboberfläche (LuCI) des HA‑VRRP‑Addons zu erweitern und zu bauen.  Ziel ist es, eine robuste, modulare und benutzerfreundliche UI zu schaffen, die Fehler abfängt, den Status über eine JSON‑API bereitstellt und sich konsistent in das OpenWrt‑Ökosystem einfügt.  Entwickler*innen können diesen Leitfaden verwenden, um UI‑Änderungen systematisch durchzuführen und dabei Konventionen für Versionierung, Tests und Dokumentation einzuhalten.

## Schritte

1. **Architektur verstehen und modular halten**: Verschaffe dir einen Überblick über die bestehende UI‑Struktur (`luci/controller/ha_vrrp.lua`, `model/cbi/ha_vrrp/*`, `view/ha_vrrp/*`) und identifiziere die Module (Allgemein/Status, Konfiguration, Sync, Backup, Advanced).  Neue Funktionen sollten als eigenständige Module mit klarer Trennung von Logik und Darstellung umgesetzt werden.  Vermeide direkte Shell‑Aufrufe aus Templates; verwende stattdessen die API‑Skripte unter `/usr/sbin/ha-vrrp-api` und UCI‑Befehle.

2. **Fehlertoleranz implementieren**: Sorge dafür, dass Fehler innerhalb eines Moduls nicht die gesamte UI zum Absturz bringen.  Prüfe Eingaben strikt (z. B. IP‑Adressen, Prioritäten) und gib aussagekräftige Fehlermeldungen aus, statt Lua‑Fehler ins Leere laufen zu lassen.  Definiere Standardwerte und Fallbacks, falls Abhängigkeiten (z. B. `keepalived`) nicht vorhanden sind.

3. **JSON‑Status‑API erweitern**: Prüfe die bestehende Status‑Implementierung (`/usr/lib/lua/ha_vrrp/status.lua` oder `cgi-bin/ha-vrrp-status`) und erweitere sie bei Bedarf um Felder wie Cluster‑Rolle (Master/Backup), Anzahl der Peers, letzte Fehler, Uptime, Versionsinfo von `keepalived` und Addon.  Die API sollte ohne LuCI erreichbar sein (CGI) und in der UI sowie von externen Systemen (z. B. Home Assistant) konsumiert werden können.

4. **UCI‑Integration sicherstellen**: Nutze für systemweite Einstellungen die UCI‑Schnittstelle (`luci.model.uci.cursor()`) statt `/etc/config` direkt zu parsen.  Beim Setzen von Optionen (z. B. VRRP‑Instanz‑Priorität) ist nach dem Schreiben ein Commit auszuführen (`uci:commit("ha_vrrp")`) und ggf. der Dienst neu zu starten.  Dies erhöht die Konsistenz und reduziert Race‑Conditions.

5. **Tests durchführen**: Baue die UI lokal (im SDK oder auf einem Entwicklungsrouter) und rufe alle Seiten auf, um Fehler abzufangen.  Nutze `scripts/helpers/helper_smoketests.sh` für Shell‑Syntax und führe UI‑Smoke‑Tests manuell durch (Navigation, Formulare absenden, Fehlerszenarien simulieren).  Achte darauf, dass die UI auch ohne aktive VRRP‑Instanz startet und dass Debug‑Logs über die UI abrufbar sind.

6. **Dokumentation aktualisieren**: Ergänze `docs/releases/current/current.md` oder spezifische Unterseiten (`docs/architecture/…`, `docs/concepts/…`) um Informationen zur neuen UI‑Funktionalität.  Beschreibe, welche Seiten hinzugekommen oder verändert wurden, wie die JSON‑API genutzt wird und welche Einstellungen verfügbar sind.  Aktualisiere `docs/CHANGELOG.md` und lege eine neue Datei unter `docs/changelogs/<VERSION>.md` an.

7. **Versionierung und Commit**: Bump die Versionsnummer in `VERSION` (z. B. auf `0.5.16-007_reviewfix17_a1`), führe den Release‑Helper aus und erstelle ein Migrationsskript, wenn sich die UI‑Konfigurationsdaten geändert haben.  Committe die Änderungen mit einem klaren Präfix (z. B. `feat(ui): …` oder `fix(ui): …`) und dokumentiere in der Commit‑Nachricht die neue UI‑Funktion.  Erstelle anschließend das Release‑Paket mit `scripts/helpers/helper_build_package.sh`.

## Hinweise

* Verwende in LuCI‑Views möglichst die vorhandenen CBI‑Elemente (z. B. `SimpleSection`, `TypedSection`, `Option`), um eine konsistente Benutzerführung zu gewährleisten.
* Halte die UI barrierefrei und übersetze UI‑Strings über `i18n`, damit internationale Nutzer*innen profitieren.
* Stelle sicher, dass die UI auch im Read‑only‑Modus (ohne Schreibrechte) geladen werden kann und aussagekräftige Hinweise gibt, falls Einstellungen nicht gespeichert werden dürfen.
* Dokumentiere die JSON‑Status‑API in `docs/API.md` oder einer ähnlichen Datei, damit Integrationen wie Home Assistant wissen, welche Felder verfügbar sind.
* Nutze `luci.dispatcher` nicht für Geschäftslogik; Ausführende Kommandos sollen in Shell‑Skripten unter `/usr/sbin/ha-vrrp-api` definiert sein und von der UI nur gerufen werden.