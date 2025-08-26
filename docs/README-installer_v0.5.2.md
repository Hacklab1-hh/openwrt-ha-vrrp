# Installer (v0.5.2)

## Aufruf
```sh
sh scripts/install_v0.5.2.sh
```

## Verhalten
- Versucht zuerst IPK-Installation aus `/tmp/ha-vrrp_0.5.2-1_*.ipk` und `/tmp/luci-app-ha-vrrp_0.5.2-1_*.ipk`.
- Falls nicht vorhanden oder `opkg` fehlt, wird im **Overlay-Modus** direkt nach `/` kopiert.
- Startet/aktiviert `ha-vrrp` und refresht LuCI-Dienste (`rpcd`, `uhttpd`).

## Abhängigkeiten
- OpenWrt Runtime (für opkg-Modus)
- `keepalived`, `ip-full`, `ubus`, `jsonfilter` werden als runtime-Depends durch IPK abgedeckt.
