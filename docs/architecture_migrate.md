# Architektur: Migration (Upgradepfad)

Die Migration zwischen Versionen des HA‑VRRP‑Add‑ons basiert auf einem sequenziellen Migrationssystem.  Für jede Version können unter `scripts/migrate/` Skripte hinterlegt werden, die von einer Vorgängerversion auf die neue Version migrieren.

- **Upgrade‑Pfad**: Der Dateibaum `scripts/migrate` enthält Migrationsskripte im Format `migrate_<from>_to_<to>.sh` oder `migrate-to-<version>.sh`.  Diese Skripte werden in der Reihenfolge ihres Versionssprungs ausgeführt.  Die Datei `scripts/upgradepath.unified.json` (bzw. `update-path.json`) dokumentiert die Abhängigkeiten zwischen den Versionen.
- **Dispatcher**: Außerhalb des Upstreams wird ein Skript `run_migrations.sh` eingesetzt, das den aktuell installierten Versionsstand ermittelt, einen Migrationspfad berechnet und die zugehörigen Skripte nacheinander ausführt.  Vor jeder Migration wird die bestehende Keepalived‑Konfiguration gesichert.
- **Migrationsskripte**: Einzelne Skripte führen spezifische Änderungen durch, z. B. das Verschieben oder Umbenennen von Konfigurationsparametern, das Erzeugen neuer Dateien oder das Konvertieren alter Strukturen.  Alle Skripte sind POSIX‑sh‑kompatibel und können auf BusyBox‑Systemen ausgeführt werden.
- **Backup und Logging**: Vor jedem Migrationsschritt wird ein Backup der relevanten Konfigurationsdaten angelegt, um einen Rollback zu ermöglichen.  Migrationsskripte loggen ihren Fortschritt in eine Logdatei unter `/var/log/ha-vrrp`.

Diese Architektur stellt sicher, dass Upgrades reproduzierbar, nachvollziehbar und sicher durchgeführt werden können.