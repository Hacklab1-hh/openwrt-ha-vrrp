# Changelog

## 0.5.16-006 (2025-08-24)
- LuCI: UI aus 0.5.16-002 zurückgeholt (Views & CBI) für volle Funktion.
- Controller: ergänzt um fehlende Endpoints, Apply ruft Migration auf.
- Migration: `migrate_0.5.16_002_to_006.sh` für interface→iface, vip→vip_cidr, setzt unicast_src_ip.
- Installer: Migration automatisch eingebunden.
