## Generische Kettenmigration
Der Installer ermittelt anhand `scripts/upgradepath_unified.txt` die Kette `CUR → TARGET` und ruft pro Schritt `migrate_<from>_to_<to>.sh` mit `--migrate` bzw. `--rollback` auf.
