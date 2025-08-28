# Architektur: Uninstaller

Das Deinstallationssystem besteht aus dem Dispatcher `scripts/uninstaller.sh` und optional versionsspezifischen Uninstallern (`uninstaller-v<version>.sh`).

- **Dispatcher (`uninstaller.sh`)**: Ermittelt die aktuelle Version über die in `common.sh` bereitgestellten Funktionen und sucht im Verzeichnis `scripts/uninstaller` nach einem passgenauen Uninstaller.  Wird dieser gefunden, wird er ausgeführt, wodurch versionsspezifische Bereinigungen ermöglicht werden.
- **Generischer Uninstaller**: Wenn kein spezialisierter Uninstaller vorhanden ist, entfernt das generische Script alle installierten Dateien und Verzeichnisse (`/usr/lib/lua/luci/controller/ha_vrrp.lua`, die LuCI‑Modelle, Binärdateien, Init‑Scripts und Konfigurationen) und löscht eventuell angelegte LuCI‑Caches.
- **Hilfsfunktionen**: Wie beim Installer stellt `common.sh` Funktionen zur Root‑Erkennung, Versionsbestimmung und zum Logging bereit.  Dadurch bleibt der Dispatcher einfach und portabel.

Durch diese Architektur können versionsspezifische Bereinigungen einfach ergänzt werden, während die generische Variante alle verbleibenden Dateien zuverlässig entfernt.