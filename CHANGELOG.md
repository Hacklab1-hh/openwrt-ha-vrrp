# Changelog

## 0.5.16-005 (2025-08-24)
- LuCI: fehlende Controller-Endpoints ergänzt (`statusjson`, `apply`, `interfaces`, `discover`, `keysync`, `syncpush`, `createinst`).
- LuCI: `instances.lua` auf `iface`, `vip_cidr`, `unicast_src_ip`, `unicast_peer` angepasst (kompatibel zu `ha-vrrp-apply`).
- Migration: `scripts/migrate_0.5.16_004_to_005.sh` fügt Alt-Schlüssel (`interface`,`vip`) zusammen und setzt best-effort `unicast_src_ip`.
- Installer: führt Migration automatisch aus.
