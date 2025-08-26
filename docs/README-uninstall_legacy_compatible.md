
# Legacy-kompatibler Uninstaller (v0.5.4)

**Ziel:** Verhalten des ursprünglichen `uninstall.sh` nachempfinden.
- Stoppt Dienste und entfernt die vom Installer kopierten Dateien.
- Lässt `/etc/config/ha_vrrp` standardmäßig bestehen (wie Original).
- Entfernt LuCI-Dateien (falls per Overlay kopiert).

## Aufruf
```sh
sh scripts/uninstall_legacy_compatible.sh
```
