# Architektur: Installer

Das Installationssystem des HA‑VRRP‑Add‑ons ist modular aufgebaut und besteht aus einem Dispatcher (`scripts/installer.sh`), einer Sammlung versionsspezifischer Installationsskripte unter `scripts/installer/` und einem Satz von Hilfsfunktionen in `scripts/tools/common.sh`.

- **Dispatcher (`installer.sh`)**: Dieses Skript ermittelt mithilfe von `common.sh` das Repository‑Wurzelverzeichnis und die Zielversion (`VERSION` oder Umgebungsvariablen).  Anschließend sucht es im lokalen `scripts/installer`‑Verzeichnis nach einem spezialisierten Installer (`installer-v<version>.sh`).  Wird dieser gefunden, wird er direkt ausgeführt.
- **Remote‑Fetch**: Falls kein spezialisierter Installer vorhanden ist und der Installationsmodus auf `auto` steht, lädt der Dispatcher das Archiv der gewünschten Version von GitHub herunter (`tools/fetch_from_github.sh`) und extrahiert es temporär, um daraus den spezialisierten Installer auszuführen.
- **Generische Installation**: Wenn weder ein lokaler noch ein remote Installer verfügbar ist, führt das Skript eine generische Installation aus, bei der die Dateien aus `ha-vrrp/files` (oder einem Fallback) in das Zielsystem (`DESTROOT`, standardmäßig `/`) kopiert werden.  Anschließend werden LuCI‑Caches invalidiert.
- **Hilfsfunktionen**: `common.sh` stellt unter anderem `detect_root()`, `get_version()`, `normalize_version_for_filename()` sowie Log‑Funktionen bereit.  Dadurch bleibt der Dispatcher portabel und Shell‑kompatibel (BusyBox).

Diese Architektur ermöglicht es, die Installation für jede Version anzupassen, ohne den Dispatcher selbst zu verändern.  Neue Versionen können durch Hinzufügen eines passenden `installer-v*.sh` implementiert werden.