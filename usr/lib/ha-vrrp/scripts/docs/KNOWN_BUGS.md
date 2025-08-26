# Known Bugs / Notes
- **v0.5.12**: LuCI-UI crash bei Start (fehlerhafte Quotes im Controller) → Fix in 0.5.12+, bitte updaten.
- **v0.5.13**: Overlay-Installer installiert keine Dependencies → Menüpunkt unter Services evtl. unsichtbar. Workaround: `opkg install keepalived luci-compat ...` oder Upgrade auf 0.5.14 (Installer zieht Abhängigkeiten automatisch).

