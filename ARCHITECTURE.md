# Architecture — OpenWRT HA VRRP (Serie 0.5.16)
**Stand:** 2025-08-24

Dieses Dokument beschreibt die technische Architektur.

## LuCI / UI
- **Controller:** `luci.controller.ha_vrrp` registriert Menüeinträge und API-Routen (z. B. `/api/status`).
- **CBI-Modelle:** `model/cbi/ha_vrrp/*.lua` — reine CBI-Widgets für Kompatibilität (auch 19.07).
- **Views:** `view/ha_vrrp/*.htm` — nutzen Guards wie `self.map.uci` anstelle globalem `m`.

## Core & Backends
- **Keepalived:** Generiert `vrrp_instance`-Konfigurationen je Service/Interface.
- **Firewall:** Adapter für `fw3/iptables` und `fw4/nft`.
- **DHCP/DNS:** `dnsmasq_legacy` vs. `dnsmasq_fw4` (Reload-Mechaniken beachten).
- **Netzwerk:** `swconfig` vs. `dsa` (Ports/VLANs unterscheiden sich).

## Verzeichnisstruktur (Zielsystem)
```
/etc/config/ha_vrrp
/etc/ha-vrrp/                  # Keys, Backups, Marker
/usr/libexec/ha-vrrp/          # ausführbare Actions (discover, sync, rpc, ...)
/usr/lib/ha-vrrp/lib/          # Libraries/Helper
/usr/lib/ha-vrrp/scripts/      # Migrations
/usr/lib/lua/luci/...          # LuCI App
/usr/lib/ha-vrrp/VERSION       # installierter Stand
/tmp/ha_vrrp_*.log             # Laufzeitprotokolle
```

## Update-/Migrationspfad
- **002 → 007:** Strukturangleichung (Keys/Paths); Script: `migrate_0.5.16_002_to_007.sh`
- **007 → 008:** Einführung CIDR/ssh_backend; Script: `migrate_0.5.16_007_to_008.sh`
- Weitere Migrationen werden als `migrate_<from>_to_<to>.sh` bereitgestellt.

## Sicherheit
- SSH-Schlüsselzugriffe restriktiv (`chmod 600` für private Keys).
- Kein Inline-Shell in Lua-Controllern; alle Systemaufrufe über geprüfte Wrapper.
