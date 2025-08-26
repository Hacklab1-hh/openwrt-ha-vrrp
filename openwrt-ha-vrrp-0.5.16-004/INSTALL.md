## v0.1.0

### Installer (Kerndefinition)
```
echo "[install] Checking dependencies (opkg, keepalived, ip-full, uci, uhttpd, luci)..."
if ! need opkg; then
echo "[install] ERROR: opkg not found. Are you on OpenWrt?"; exit 1
opkg update >/dev/null 2>&1 || true
for p in keepalived ip-full uci; do
opkg list-installed | grep -q "^$p " || opkg install "$p"
opkg list-installed | grep -q "^$p " || opkg install "$p" || true
mkdir -p /etc/config /etc/init.d /etc/uci-defaults /usr/libexec/ha-vrrp /usr/sbin /etc/hotplug.d/iface
cp "$SRC_DIR/etc/init.d/ha-vrrp" /etc/init.d/ha-vrrp
cp "$SRC_DIR/etc/uci-defaults/95_ha_vrrp_defaults" /etc/uci-defaults/95_ha_vrrp_defaults
chmod +x /etc/uci-defaults/95_ha_vrrp_defaults || true
if [ -x /etc/uci-defaults/95_ha_vrrp_defaults ]; then
/etc/uci-defaults/95_ha_vrrp_defaults || true
rm -f /etc/uci-defaults/95_ha_vrrp_defaults || true
```

### Uninstaller (Kerndefinition)
```
echo "[uninstall] Note: keepalived package is still installed. Remove via 'opkg remove keepalived' if desired."
```

### Makefile-Targets (erkannt)
- `PKG_LICENSE`
- `PKG_NAME`
- `PKG_RELEASE`
- `LUCI_DEPENDS`
- `LUCI_TITLE`
- `PKG_LICENSE`

---

## v0.2.0

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
- `PKG_MAINTAINER`
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

---

## v0.3.0

### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_NAME`
- `PKG_VERSION`
- `PKG_NAME`
- `PKG_VERSION`

---

## v0.4.0

### Installer (Kerndefinition)
```
(keine)
```

### Uninstaller (Kerndefinition)
```
(keine)
```

### Makefile-Targets (erkannt)
- `PKG_NAME`
- `PKG_VERSION`
- `PKG_NAME`
- `PKG_VERSION`

---

## v0.3.0a

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

---

## v0.4.0a

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

---

## v0.5.0

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.0
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.1

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.1
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.2

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.2
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.3

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.3
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.4

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.4
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.5

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.5
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.6

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.6
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.7

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.7
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.8

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.8
# (Keine konkreten Skripte im Archiv erkannt)
```

---

## v0.5.9

### Installation (generisch)
```sh
# Build/Install abhängig von Version 0.5.9
# (Keine konkreten Skripte im Archiv erkannt)
```
