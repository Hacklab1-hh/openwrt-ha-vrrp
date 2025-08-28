# Konzepte: UI (LuCI)

Die Benutzeroberfläche des HA‑VRRP‑Add‑ons soll die Konfiguration und Überwachung des Clusters so einfach wie möglich machen und gleichzeitig robust bleiben.  Die wichtigsten Konzepte sind:

- **Modularität**: Jede Funktion (Übersicht, Status, Instanzen, Synchronisation, Einstellungen, Setup‑Wizard) wird als separater CBI‑Tab realisiert.  Fehler in einem Tab blockieren nicht die gesamte UI.
- **JSON‑API**: Die UI stellt Daten über mehrere JSON‑Endpunkte zur Verfügung.  Externe Tools (z. B. Home Assistant) können über `…/api/statusjson` den Zustand des Knotens abfragen und Aktionen wie `apply_cfg` oder `sync_push` auslösen.
- **Skriptintegration**: Komplexe Aufgaben (z. B. Schlüsselsynchronisation, Push‑Sync) werden an Shell‑Skripte delegiert.  Die UI ruft diese Skripte asynchron auf und zeigt lediglich den Erfolg an.
- **UCI‑Integration**: CBI‑Modelle interagieren mit der UCI‑Konfiguration (`/etc/config/ha_vrrp`) und übernehmen Änderungen direkt.  Damit bleibt das System konsistent mit den üblichen OpenWrt‑Mechanismen.
- **BusyBox‑Kompatibilität**: Sämtliche Shell‑Befehle, die in `ha_vrrp.lua` verwendet werden (ping, ip, pgrep, grep, awk), sind BusyBox‑kompatibel, damit die UI auf OpenWrt‑Geräten zuverlässig funktioniert.
- **Fehlertoleranz**: Die Anwendung prüft vor dem Anzeigen, ob die Konfigurationsdatei vorhanden ist, und liefert definierte JSON‑Antworten, auch wenn Befehle fehlschlagen.  So wird vermieden, dass die UI abstürzt.

Diese Konzepte stellen sicher, dass die Benutzeroberfläche stabil, erweiterbar und für Entwickler wie auch Endnutzer intuitiv bedienbar bleibt.