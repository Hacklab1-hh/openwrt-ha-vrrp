# Konzepte: Uninstaller

Die Deinstallation des HA‑VRRP‑Add‑ons folgt dem Konzept der sicheren Entfernung: Sämtliche Dateien, die durch den Installer abgelegt wurden, können identifiziert und entfernt werden.  Das System berücksichtigt dabei unterschiedliche Versionen.

Wesentliche Konzepte:

- **Versionsspezifische Logik**: Für komplexe Änderungen zwischen Versionen können spezifische Uninstall‑Skripte bereitgestellt werden, die z. B. neue Pfade oder zusätzliche Dateien berücksichtigen.
- **Generisches Fallback**: Fehlt eine solche Datei, sorgt der generische Uninstaller dafür, dass zumindest alle bekannten Installationspfade bereinigt werden.  Dies stellt sicher, dass das Add‑on vollständig entfernt wird, auch wenn keine spezielle Logik vorhanden ist.
- **Portabilität**: Die Scripts sind POSIX‑sh‑kompatibel und laufen auf OpenWrt‑Systemen.  Es werden nur BusyBox‑Werkzeuge verwendet.

Dieses Konzept ermöglicht es, Installationen vollständig und sauber zurückzusetzen, ohne Spuren zu hinterlassen.