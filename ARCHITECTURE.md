# architecture_md = textwrap.dedent
# ARCHITECTURE — openwrt-ha-vrrp (Serie 0.5.16)

**Ziel:** High Availability (HA) für OpenWrt-Router (ab 19.07) mit VRRP (keepalived) und einem schlanken, serverseitigen LuCI/CBI-Frontend. Ein aktiver Master trägt die VIP `.254` pro Segment; ein Standby übernimmt bei Ausfall. Heartbeat läuft über ein dediziertes Interface/VLAN (z. B. `HEARTBEAT`, VLAN 200).

## Leitprinzipien

- **Modularität über Backends:** Firewall (fw3/iptables, fw4/nft), DHCP/DNS (dnsmasq-Varianten), Netz (swconfig/DSA), SSH (dropbear/OpenSSH), Keepalived-Versionen – als austauschbare Adapter.
- **OS-Kompatibilität:** Kapselung, damit 19.07 / 21.02 / 22.03 / 23.05 funktionieren, ohne getrennte Pakete.
- **Konfig vor Code:** Defaults & Settings konsistent in `/etc/config/ha_vrrp`, gepflegt via LuCI-CBI (kein Hardcoding).
- **Sauberer Upgrade-Pfad:** Strukturelle Änderungen via **Migration-Skripte** vor der Dateikopie; keine Ad-hoc-Shell in Lua.
- **Robuste UI:** Reines CBI, keine `L.ui.*`-Abhängigkeit (kompatibel zu 19.07). Templates greifen über `self.map.uci` zu.

---

## Komponentenübersicht

### 1) LuCI-App (serverseitig, CBI)

- **Controller:** `luci.controller.ha_vrrp`  
  Registriert Menüs & API:
  - `/admin/services/ha_vrrp/overview` → CBI `model/cbi/ha_vrrp/overview.lua` + View `view/ha_vrrp/overview.htm`
  - `/admin/services/ha_vrrp/settings` → CBI `model/cbi/ha_vrrp/settings.lua`
  - `/admin/services/ha_vrrp/sync` → CBI `model/cbi/ha_vrrp/sync.lua` + View `view/ha_vrrp/sync.htm`
  - `/admin/services/ha_vrrp/instances` → CBI `model/cbi/ha_vrrp/instances.lua` (Platzhalter)
  - `/admin/services/ha_vrrp/api/status` → JSON (Ping/Peer/ts) – blockiert die UI nicht
- **CBI-Modelle:** lesen/schreiben UCI `ha_vrrp.core.*` (u. a. `cluster_name`, `peer_host`, `peer_netmask_cidr`, `ssh_backend`, `key_type`, `sync_method`, `fw_backend`, `ka_backend`, `dhcp_backend`, `net_backend`, `priority`, `cluster_version`).
- **Views/Templates:** Guard: `<% local data = self and self.map and self.map.uci or {} %>` statt globalem `m` → verhindert 500er auf 19.07.

### 2) Core & Backends

- **Exec-Layer:** `/usr/libexec/ha-vrrp/`
  - `discover.sh` (CIDR/IF-Scan, schreibt `/tmp/ha_vrrp_discover.json`)
  - `sync/` (`generate_keys.sh`, `setup_ssh_config.sh`, `push_keys.sh`)
  - `rpc/*.wrapper` (Remote-Testaufrufe)
- **Lib & Migrationen:** `/usr/lib/ha-vrrp/{lib, scripts}`
  - `scripts/migrate_*` – Version-Migrationen (idempotent)
- **Konfig & Marker:**
  - `/etc/config/ha_vrrp` – UCI-Quelle der Wahrheit
  - `/etc/ha-vrrp/` – Keys/Backups/SSH-Config
  - `/usr/lib/ha-vrrp/VERSION` – installierter Stand (vom Installer geschrieben)

---

## Konfigurationsmodell (UCI)

`
config core 'core'` – wichtige Optionen:
option cluster_name 'lab-ha'
option peer_host '192.168.254.2'
option peer_netmask_cidr '24' # Discover-/Scan-CIDR
option ssh_backend 'auto' # auto|openssh|dropbear
option key_type 'auto' # auto|ed25519|rsa
option sync_method 'auto' # auto|scp|rsync
option fw_backend 'auto' # auto|iptables|nft
option ka_backend 'auto' # auto|ka_2x|ka_2_2plus
option dhcp_backend 'auto' # auto|dnsmasq_legacy|dnsmasq_fw4
option net_backend 'auto' # auto|swconfig|dsa
option priority '150' # VRRP Priority (0–255)
option cluster_version '0.5.16-xxx'
`

---

## Datenfluss

1. **Settings (LuCI/CBI)** → schreibt UCI `ha_vrrp.core.*`.
2. **Discover (Script)** → scannt interface/CIDR, Ergebnis nach `/tmp/ha_vrrp_discover.json`.
3. **Sync/Keys (Scripts + UI)** → Key-Erzeugung, SSH-Config, Key-Push, RPC-Test.
4. **Overview (View)** → zeigt `cluster_version`, `peer_host`, Ping-Status, Backends, Priority, Quicklinks.

---

## Backend-Adapter

- **Firewall:** fw3/iptables **oder** fw4/nft (Adapter kapseln Unterschiede).
- **Keepalived:** Versionen (2.x/2.2+) beeinflussen erlaubte Optionen/Reload; Adapter generieren passende `vrrp_instance`-Snippets.
- **DHCP/DNS:** dnsmasq-Varianten (Legacy vs. fw4-Integration) mit unterschiedlichen Reload-Pfade.
- **Network:** swconfig vs. DSA – Ports/VLANs & Switch-Modell weichen ab.
- **SSH:** Auto-Erkennung OpenSSH/Dropbear; **ed25519 bevorzugt**, Fallback RSA; `~/.ssh/config` wird generiert.

---

## Discover & VIP-Konventionen

- **HEARTBEAT**: dediziertes Interface/VLAN (typ. VLAN 200, z. B. `192.168.254.1/24`) für Discover/Health/Sync.
- **VIP pro Segment:** `.254` ist Cluster-VIP des aktiven Masters; Node-Basis-IPs sind „untere“ Adressen (z. B. `.1`/`.2`).

---

## Update-Pfad (Installer/Uninstaller/Manager/Migrationen)

### Installer (versioniert)
- Skriptnamen: `scripts/installer-v<version>.sh` (z. B. `installer-v0.5.16-009.sh`)
- **Ablauf:**  
  **Backup** (`/etc/config/ha_vrrp`, `/etc/ha-vrrp` → `backup-<ts>.tgz`) →  
  **Pre-Migrationen** (z. B. `migrate_0.5.16_002_to_007.sh`, `migrate_0.5.16_007_to_008.sh`) →  
  **Dateikopie** (LuCI/Exec/Lib/Scripts) → **Rechte** → **VERSION** schreiben → **LuCI-Refresh** (rpcd/uhttpd, Cache)
- **Wrapper:**  
  `installer-v0.5.16.sh` → delegiert auf neuesten Patchlevel (zzt. `0.5.16-009`)  
  `installer.sh` → ruft Serien-Installer

### Uninstaller (versioniert)
- Skriptnamen: `scripts/uninstaller-v<version>.sh`
- Entfernen Controller/CBI/Views + `/usr/libexec/ha-vrrp` + `/usr/lib/ha-vrrp` (inkl. VERSION), dann LuCI-Refresh.
- Wrapper: `uninstaller-v0.5.16.sh`, `uninstaller.sh`.

### Manager
- `scripts/ha-vrrp-manage.sh` – Befehle:
  - `detect` → `/usr/lib/ha-vrrp/VERSION` bzw. `uci get ha_vrrp.core.cluster_version`
  - `install <ver|series>` → ruft passenden Installer
  - `uninstall [<ver|series|current>]`
  - `update [<target>]` → **Backup → Install (Ziel) → Migrationen → LuCI-Refresh**
- Shortcut: `scripts/update-to-latest.sh` → Update auf neuesten Serien-Patch.

### Migrationen
- Ort: `/usr/lib/ha-vrrp/scripts/`
- Namensschema: `migrate_<from>_to_<to>.sh` (idempotent)
- Aktuelle Stände:  
  `migrate_0.5.16_002_to_007.sh`, `migrate_0.5.16_007_to_008.sh` (Platzhalter – echte Logik je nach Umbau).

---

## Verzeichnisstruktur (empfohlen)

openwrt-ha-vrrp-<version>/
├─ luci-app-ha-vrrp/
│ └─ luasrc/
│ ├─ controller/ha_vrrp.lua
│ ├─ model/cbi/ha_vrrp/{overview.lua,settings.lua,sync.lua,instances.lua}
│ └─ view/ha_vrrp/{overview.htm,sync.htm,instances.htm}
├─ usr/
│ └─ lib/
│ └─ ha-vrrp/
│ ├─ lib/
│ ├─ scripts/ # Migrationen & Helper (versioniert)
│ └─ VERSION # vom Installer gesetzt
├─ usr/libexec/ha-vrrp/ # discover.sh, sync/.sh, rpc/.wrapper
├─ etc/config/ha_vrrp # UCI (ggf. im Paket als Template)
├─ etc/ha-vrrp/ # Keys, Backups (zur Laufzeit)
├─ scripts/ # Installer/Uninstaller/Manager (Wrapper + versioniert)
│ ├─ installer.sh
│ ├─ installer-v0.5.16.sh → installer-v0.5.16-009.sh
│ ├─ installer-v0.5.16-00X.sh (Raster bis -999; fehlende als Dummys)
│ ├─ uninstaller.sh
│ ├─ uninstaller-v0.5.16.sh → uninstaller-v0.5.16-009.sh
│ └─ uninstaller-v0.5.16-00X.sh
├─ docs/
│ ├─ README.md / CHANGELOG.md / KNOWN_ISSUES.md
│ ├─ README_.md / CHANGELOG_.md / KNOWN_ISSUES_.md
│ ├─ features/FEATURES_.md
│ └─ …
├─ CONCEPTS.md
├─ ARCHITECTURE.md
└─ FEATURES.md


---

## Diagnose & Support

- **Logs:** `/tmp/ha_vrrp_*`
- **LuCI neu laden:** `/tmp/luci-*` löschen, `rpcd`/`uhttpd` neustarten
- **Lua-Syntaxcheck:** `lua -e 'dofile("/pfad/zur/datei.lua")'`
- **Fehlerbilder:**  
  - 500er in `overview.htm` → prüfen, ob Template `self.map.uci`-Guard nutzt  
  - Controller-Parsefehler → sicherstellen, dass keine Shellfragmente in Lua stehen

---

## Sicherheit

- Privater Schlüssel `chmod 600`; Uploads validieren; keine Inline-Shell in Lua-Dateien.
- SSH-Backend automatisch erkennen, OpenSSH (ed25519) bevorzugen, Dropbear als Fallback.

---

## Roadmap (Auszug)

- rsync-Backend mit Excludes/Rate-Limits vervollständigen  
- Discover um ARP/NDP/LLDP erweitern  
- Instances-UI (CRUD, Inline-Bearbeitung)  
- OS-Matrix 21.02/22.03/23.05 validieren


