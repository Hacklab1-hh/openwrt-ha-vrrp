
# Legacy-kompatibler Installer (v0.5.5)

**Ziel:** Verhalten des ursprünglichen `install.sh` ohne Flags nachbilden (OpenWrt 19.07).
- Bricht ab, wenn `opkg` fehlt (wie Original).
- Installiert Basis-Pakete: `keepalived ip-full uci uhttpd luci-compat luci-base` (falls nicht vorhanden).
- Kopiert Service-Dateien aus `ha-vrrp/files` nach `/`.
- Installiert LuCI-Controller/Views/Models in `/usr/lib/lua/luci/...`.
- Aktiviert/Startet `ha-vrrp`, refresht `rpcd`, `uhttpd`.

## Aufruf
```sh
sh scripts/install_legacy_compatible.sh
```
