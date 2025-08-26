# openwrt-ha-vrrp v0.2.0 (OpenWrt 19.07+)

This repo contains two buildable OpenWrt packages:

- **ha-vrrp** – UCI-driven Keepalived (VRRP, unicast) with VLAN heartbeat + multi-instance support
- **luci-app-ha-vrrp** – LuCI UI (Services → HA VRRP)

## Build (OpenWrt SDK/Buildroot)

```sh
# inside your OpenWrt SDK or Buildroot tree
# copy both package dirs:
cp -a ha-vrrp <buildroot>/package/
cp -a luci-app-ha-vrrp <buildroot>/package/

# update feeds as needed, then build:
make package/ha-vrrp/compile V=s
make package/luci-app-ha-vrrp/compile V=s

# resulting .ipk files will be in bin/packages/<arch>/...
```

## Install on router
```sh
opkg install /tmp/ha-vrrp_0.2.0-1_*.ipk
opkg install /tmp/luci-app-ha-vrrp_0.2.0-1_*.ipk
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

## Multi-instance UCI example
See `ha-vrrp/README-uci-examples.md` for 2-instance setup (HB on VLAN200 + LAN VIP 192.168.1.254).
