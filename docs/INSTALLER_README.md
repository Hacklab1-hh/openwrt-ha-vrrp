## Generische Kettenmigration
Der Installer ermittelt anhand `scripts/upgradepath_unified.txt` die Kette `CUR → TARGET` und ruft pro Schritt `migrate_<from>_to_<to>.sh` mit `--migrate` bzw. `--rollback` auf.

### Vollständige Migrationsleiter 0.5.9→0.5.16-007_reviewfix5
Alle Zwischenschritte sind als `migrate_<from>_to_<to>.sh` (mit `--migrate` & `--rollback`) vorhanden.
