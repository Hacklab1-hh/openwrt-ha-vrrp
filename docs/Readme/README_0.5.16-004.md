# openwrt-ha-vrrp v0.5.16-004

**Datum:** 2025-08-24 03:58:35

## Kurzbeschreibung
Bugfix für LuCI-Views (Overview 500-Fehler behoben), erweiterte Settings (SSH-Backend, CIDR neben Peer-Host),
Sync-Uploads (lokaler privater/öffentlicher Key, Peer-Pub), Versionsanzeige in Overview, Default-Config erweitert.

## Wichtige Änderungen
- Overview-Template nutzt `self.map.uci` statt `m` → behebt 500 Internal Server Error auf 19.07.
- Anzeige der Addon-Version und des SSH-Backends in der Übersicht.
- Settings: neue Felder `ssh_backend` (auto/openssh/dropbear) und `peer_netmask_cidr` (CIDR, z.B. 24).
- Sync: Upload von lokalem privaten Schlüssel, lokalem Pub und Peer-Pub (Trust).
- Instances: kleine Beschreibung (Stub).
- Default `/etc/config/ha_vrrp`: `ssh_backend`, `peer_netmask_cidr`, `cluster_version` ergänzt.

## Hinweise
- Für OpenWrt 19.07 bleibt das UI serverseitiges CBI ohne moderne `L.ui`-Widgets; vermeidet den `L.ui is undefined`-Fehler.
- Logs zu Sync-Aktionen: `/tmp/ha_vrrp_*`.
