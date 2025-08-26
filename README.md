# openwrt-ha-vrrp v0.5.1

Built from base **0.2.0** and extended through 0.3.0–0.5.0:
- Peer discovery (configurable), Peer sync (SSH keys + push)
- VLAN heartbeat, multi-instance
- WAN/IPv6 health checks (dynamic DHCP gateway)
- Multi-VIP per instance (`vip_list`), legacy `core`-instance fallback kept
- Optional Auto-Sync daemon (procd)

**Build**
```sh
cp -a ha-vrrp <buildroot>/package/
cp -a luci-app-ha-vrrp <buildroot>/package/
make package/ha-vrrp/compile V=s
make package/luci-app-ha-vrrp/compile V=s
```
