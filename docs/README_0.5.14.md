# README – v0.5.14

## Highlights
- **Zentrale Abhängigkeits-Konfiguration:** `config/dependencies.conf` mit OS-spezifischen Sektionen (z. B. `[openwrt-19.07]`).
- **Installer nutzt dependencies.conf:** fehlende Runtime-Pakete werden per `opkg` installiert (Overlay-Modus inklusive).
- **Doku-Verweise:** Quickstart & Known Bugs aktualisiert.

## Hinweise
- Passe `config/dependencies.conf` bei Bedarf an. Der Installer liest `runtime` aus der passenden Sektion.
- OS-Autodetektion über `/etc/openwrt_release` (override per `OS_KEY=<section>`).
