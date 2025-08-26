# Upgrade Path (generated from upgradepath.unified.json)

| Version | Parent | Patch | Released | Stability | Tags | Fixline |
|---|---|---|---|---|---|---|
| `0.1.0` | `` | `` |  |  |  | { "version": "0.2.0",       "parent": "0.1.0",     "notes": "Übernahme der Ur-Version, Grundgerüst bereinigt/erweitert" }, |
| `0.2.0` | `` | `` |  |  |  | ("0.2.0","0.3.0","—",[".tar.gz",".zip"],"installer-v0.3.0.sh"), |
| `0.3.0` | `` | `` |  |  |  | ("0.3.0","0.3.0_a","Hotfix",[".tar.gz",".zip"],"migrate_0.3.0_to_0.3.0_a.sh → installer"), |
| `0.4.0` | `` | `` |  |  |  | ("0.4.0","0.4.0_a","Hotfix",[".tar.gz",".zip"],"migrate_0.4.0_to_0.4.0_a.sh → installer"), |
| `0.5.0` | `` | `` |  |  |  | ("0.5.0","0.5.1","Patch",[".tar.gz",".zip"],"migrate_0.5.0_to_0.5.1.sh"), |
| `0.5.1` | `0.5.0` | `` |  |  |  | ("0.5.1","0.5.2","Legacy / Scripts",[".tar.gz",".zip"],"installer-v0.5.2.sh"), |
| `0.5.2` | `0.5.1` | `` |  |  |  | ("0.5.2","0.5.3 … 0.5.8","Minor Releases",[".tar.gz",".zip"],"jeweiliger Installer"), |
| `0.5.3` | `0.5.2` | `` |  |  |  | ("0.5.2","0.5.3 … 0.5.8","Minor Releases",[".tar.gz",".zip"],"jeweiliger Installer"), |
| `0.5.4` | `0.5.3` | `` |  |  |  | { "version": "0.5.5",       "parent": "0.5.4",     "notes": "Ergänzungen/Refactorings" }, |
| `0.5.5` | `0.5.4` | `` |  |  |  | { "version": "0.5.6",       "parent": "0.5.5",     "notes": "Interfaces-/DHCP-Liste, VRRP-Segmente anlegbar" }, |
| `0.5.6` | `0.5.5` | `` |  |  |  | { "version": "0.5.9",       "parent": "0.5.6",     "notes": "Doku-/Changelog-/Featurelist-Chain je Version eingeführt" }, |
| `0.5.8` | `0.5.6` | `` |  |  |  | ("0.5.8","0.5.9","—",[".tar.gz",".zip"],"installer-v0.5.9.sh"), |
| `0.5.9` | `0.5.8` | `` |  |  |  | ("0.5.9","0.5.10","—",[".tar.gz",".zip"],"installer-v0.5.10.sh"), |
| `0.5.10` | `0.5.9` | `` |  |  |  | ("0.5.10","0.5.11","—",[".tar",".tar.gz",".zip"],"installer-v0.5.11.sh"), |
| `0.5.11` | `0.5.10` | `` |  |  |  | ("0.5.11","0.5.12","—",[".tar",".tar.gz",".zip"],"installer-v0.5.12.sh"), |
| `0.5.12` | `0.5.11` | `` |  |  |  | ("0.5.12","0.5.13","—",[".tar",".tar.gz",".zip"],"installer-v0.5.13.sh"), |
| `0.5.13` | `0.5.12` | `` |  |  |  | ("0.5.13","0.5.14","—",[".tar",".tar.gz",".zip"],"installer-v0.5.14.sh"), |
| `0.5.14` | `0.5.13` | `` |  |  |  | ("0.5.14","0.5.15_b","—",[".tar",".tar.gz",".zip"],"installer-v0.5.15_b.sh"), |
| `0.5.15` | `0.5.14` | `` |  |  |  | { "version": "0.5.16",      "parent": "0.5.15",    "notes": "CBI-only auf 19.07, Controller entschlackt, Templates nutzen self.map.uci" }, |
| `0.5.16` | `0.5.15` | `` |  |  |  | ("0.5.16-009","0.5.16-009_reviewfix3","Docs + Path integriert",[".tar",".tar.gz",".zip"],"installer-v0.5.16-009_reviewfix3.sh") |
| `0.5.16-001` | `0.5.16` | `001` |  |  |  | { "version": "0.5.16-002",  "parent": "0.5.16-001","notes": "Sync-/Key-Ansicht verbessert; Upload-Felder" }, |
| `0.5.16-002` | `0.5.16-001` | `002` |  |  |  | ("0.5.16-002","0.5.16-004","Patch",[".tar",".tar.gz"],"migrate_002_to_004.sh → installer"), |
| `0.5.16-003` | `0.5.16-002` | `003` |  |  |  | { "version": "0.5.16-004",  "parent": "0.5.16-003","notes": "Stabile CBI/Controller-Files + Doku (CONCEPTS/ARCHITECTURE); Overview-500 & L.ui-Fehler behoben" } |
| `0.5.16-004` | `0.5.16-003` | `004` |  |  |  | ("0.5.16-004","0.5.16-005","—",[".tar",".tar.gz",".zip"],"installer-v0.5.16-005.sh"), |
| `0.5.16-005` | `0.5.16-004` | `005` |  |  |  | ("0.5.16-005","0.5.16-006","+fixed",[".tar",".tar.gz",".zip"],"installer-v0.5.16-006_fixed.sh"), |
| `0.5.16-006` | `0.5.16-005` | `006` |  |  |  | ("0.5.16-006","0.5.16-007","Stable UI",[".tar",".tar.gz",".zip"],"installer-v0.5.16-007.sh"), |
| `0.5.16-007` | `0.5.16-006` | `007` |  |  |  | ("0.5.16-007","0.5.16-007_infofix2_installerfix1_uninstallerfix1_managerfix1_installergrid1","Fix-Linien vollständig",[".tar",".tar.gz"],"installer-v0.5.16-0… |
| `0.5.16-008` | `0.5.16-007` | `008` |  |  |  | ("0.5.16-008","0.5.16-008_patched_fixed_infofix","Controller/UI-Fixes",[".tar",".tar.gz",".zip"],"installer-v0.5.16-008_patched_fixed_infofix.sh"), |
| `0.5.16-009` | `0.5.16-008` | `009` |  |  |  | ("0.5.16-009","0.5.16-009_reviewfix3","Docs + Path integriert",[".tar",".tar.gz",".zip"],"installer-v0.5.16-009_reviewfix3.sh") |
