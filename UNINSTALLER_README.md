## Rollback-Richtlinien

- Zuerst `--rollback` ausführen, dann die ältere Version installieren.
- Beispiel: `sh /usr/lib/ha-vrrp/scripts/migrate_0.5.10_to_0.5.11.sh --rollback`
- Snapshots werden automatisch erstellt.
- `--dry-run` unterstützt risikolose Tests.
