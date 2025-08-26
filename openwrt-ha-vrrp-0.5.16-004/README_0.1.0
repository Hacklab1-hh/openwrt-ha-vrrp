# openwrt-ha-vrrp (OpenWrt 19.07)

High-availability via **Keepalived + VRRP (unicast)** with **optional VLAN heartbeat** and a minimal LuCI UI.
This is a *drop-in* package: copy to your router and run `./install.sh` to install dependencies and deploy files.

## Key features
- VRRP (unicast) with Keepalived
- Optional dedicated VLAN subinterface (`iface.vlan_id`) for VRRP + VIP
- UCI-driven config at `/etc/config/ha_vrrp`
- Renderer to `/etc/keepalived/keepalived.conf`
- LuCI app: *Services → HA VRRP*
- Notify hooks for MASTER/BACKUP transitions

## Quick start (per node)
```sh
# Upload to router (example)
scp -r openwrt-ha-vrrp root@192.0.2.10:/tmp/

# Install on the router
cd /tmp/openwrt-ha-vrrp
sh ./install.sh

# Edit config
uci set ha_vrrp.core.vrid='42'
uci set ha_vrrp.core.vip_cidr='192.0.2.200/24'
uci set ha_vrrp.core.iface='wan'
uci set ha_vrrp.core.use_vlan='1'         # 1 to use VLAN heartbeat, 0 otherwise
uci set ha_vrrp.core.vlan_id='100'        # required if use_vlan=1

# Node A specifics:
uci set ha_vrrp.core.unicast_src_ip='192.0.2.10'
uci -q del_list ha_vrrp.core.unicast_peer
uci add_list ha_vrrp.core.unicast_peer='192.0.2.11'
uci set ha_vrrp.core.priority='150'
uci set ha_vrrp.core.state='MASTER'

# Node B specifics:
# uci set ha_vrrp.core.unicast_src_ip='192.0.2.11'
# uci -q del_list ha_vrrp.core.unicast_peer
# uci add_list ha_vrrp.core.unicast_peer='192.0.2.10'
# uci set ha_vrrp.core.priority='100'
# uci set ha_vrrp.core.state='BACKUP'

uci commit ha_vrrp
/etc/init.d/ha-vrrp restart
```

After that, visit **LuCI → Services → HA VRRP** for status/config.

## Uninstall
```sh
cd /tmp/openwrt-ha-vrrp
sh ./uninstall.sh
```
