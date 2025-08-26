# Features – v0.3.0a

- UCI-driven Keepalived (VRRP, unicast)
- Multi-instance, optional VLAN per instance
- Peer discovery (HEARTBEAT scan)
- Peer sync (SSH keys + push /etc/config/*)
- Dual-node LuCI status

Build in OpenWrt SDK:
  cp -a ha-vrrp <buildroot>/package/
  cp -a luci-app-ha-vrrp <buildroot>/package/
  make package/ha-vrrp/compile V=s
  make package/luci-app-ha-vrrp/compile V=s
