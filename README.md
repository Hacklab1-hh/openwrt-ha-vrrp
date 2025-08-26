# openwrt-ha-vrrp v0.5.0

**What’s new vs 0.4.0**
- IPv6 WAN-Gateway Health (`health_wan6_if`), ICMPv6 to dynamic default gw
- Multi-VIP per Instanz: `list vip_list` (zusätzlich/alternativ zu `vip_cidr`)
- Peer-Discovery konfigurierbar: `discover_cidr` (z. B. `192.168.254.0/24`), `discover_min`, `discover_max`
- Optional **Auto-Sync-Dienst** (`ha-vrrp-syncd`, procd): überwacht definierte Dateien und pusht Änderungen automatisch
- Kleinere Robustheits-Fixes im Renderer (GARP, nopreempt-Flag, Logging)

**Build (SDK/Buildroot)**
```sh
cp -a ha-vrrp <buildroot>/package/
cp -a luci-app-ha-vrrp <buildroot>/package/
make package/ha-vrrp/compile V=s
make package/luci-app-ha-vrrp/compile V=s
```
