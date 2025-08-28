# openwrt-ha-vrrp – Release Notes – v0.3.0a

**Datum:** 2025-08-23

## Features
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

## Changelog
- (keine Änderungen erfasst)

## Installation / Uninstallation / Build
### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`
- `LUCI_DEPENDS`
- `LUCI_PKGARCH`
- `LUCI_TITLE`
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `PKG_VERSION`
