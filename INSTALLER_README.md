## Migration & Rollback (ab 0.5.9)

- Migrationsskripte enthalten **do_migrate** (Upgrade) und **do_rollback** (Downgrade).
- Aufruf:
  - `sh /usr/lib/ha-vrrp/scripts/migrate_0.5.10_to_0.5.11.sh --migrate [--dry-run]`
  - `sh /usr/lib/ha-vrrp/scripts/migrate_0.5.10_to_0.5.11.sh --rollback [--dry-run]`
- Snapshots unter `/etc/ha-vrrp/migrate-snapshots/`.
- Idempotent, BusyBox-kompatibel.
