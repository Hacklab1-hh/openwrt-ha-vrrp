Kurz: Wizard nutzen → Peer, Keys, Sync, VRRP anlegen, Apply & Sync.

## v0.5.14 – Installation & Schnellaufrufe
```sh
# Installer (liest dependencies.conf & installiert fehlende Pakete):
cd openwrt-ha-vrrp-0.5.14/scripts
sh ./install_v0.5.14.sh

# optional OS erzwingen (statt Autodetect via /etc/openwrt_release):
OS_KEY=openwrt-19.07 sh ./install_v0.5.14.sh

# LuCI-Menüs fehlen? Cache leeren:
rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true
/etc/init.d/uhttpd restart
```
**Hinweis:** Abhängigkeiten stehen in `config/dependencies.conf` (sektionen-spezifisch).

