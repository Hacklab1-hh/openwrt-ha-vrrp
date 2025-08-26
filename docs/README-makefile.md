# README – Makefile

## Original-Pfad
`openwrt-ha-vrrp/Makefile`

## Kurzbeschreibung
Build/Copy/Package Hilfs-Targets aus dem Ur-Archiv. Für v0.5.3 empfehlen wir stattdessen die OpenWrt-Toolchain zu nutzen.

## Mögliche Targets (heuristisch erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`

## Empfohlene Nutzung (OpenWrt SDK)
```sh
cp -a ha-vrrp <buildroot>/package/
cp -a luci-app-ha-vrrp <buildroot>/package/
make package/ha-vrrp/compile V=s
make package/luci-app-ha-vrrp/compile V=s
```
