# Architektur: UI (LuCI)

Die grafische Oberfläche des HA‑VRRP‑Add‑ons basiert auf dem LuCI‑Framework von OpenWrt.  Sie folgt dem MVC‑Prinzip (Model–View–Controller) und delegiert die Geschäftslogik an Shell‑Skripte.

- **Controller (`luci-app-ha-vrrp/luasrc/controller/ha_vrrp.lua`)**: Der Controller registriert die Menüpunkte unter `admin/services/ha_vrrp` und definiert sowohl CBI‑Formularseiten (`overview`, `instances`, `sync`, `settings`, `wizard`) als auch Template‑basierte Seiten (`status`).  Zusätzlich stellt er mehrere JSON‑API‑Endpunkte bereit: `api/status`, `api/statusjson`, `api/apply`, `api/ifaces`, `api/peers`, `api/keysync` und `api/syncpush`.
- **Modelle (CBI)**: Die Formulare für Instanzen, Synchronisation, Einstellungen und den Setup‑Wizard liegen unter `luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/`.  Sie erzeugen automatisch UCI‑gestützte Eingabemasken und speichern Änderungen direkt in `/etc/config/ha_vrrp`.
- **Views (Templates)**: HTML‑Vorlagen befinden sich unter `luci-app-ha-vrrp/luasrc/view/ha_vrrp/`.  Die `status.html`‑Vorlage zeigt den Cluster‑Status in Tabellenform an.
- **Skriptabstraktion**: JSON‑APIs rufen Shell‑Skripte aus `/usr/lib/ha-vrrp/scripts` auf (z. B. `ssh_keys_sync.sh`, `sync_push.sh`) oder nutzen UCI, um Systeminformationen zu sammeln.  Die Funktion `read_cmd()` kapselt den Aufruf externer Befehle und verhindert, dass Fehler die UI zum Absturz bringen.
- **Fehlerrobustheit**: Die Controllerfunktionen überprüfen, ob Konfigurationsdateien vorhanden sind, und liefern definierte Standardwerte, wenn Shell‑Kommandos scheitern.  Dadurch bleibt die UI stabil.

Diese Architektur trennt Präsentation (CBI/Views), Steuerung (Controller/JSON‑API) und Geschäftslogik (Shell‑Skripte).  Sie ermöglicht eine modulare Erweiterung der UI und eine einfache Integration in andere Systeme via JSON‑API.