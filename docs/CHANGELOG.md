Current Version: 0.5.16-007_reviewfix16_featurefix4

# Changelog

## 0.5.16-006 (2025-08-24)
- LuCI: UI aus 0.5.16-002 zurückgeholt (Views & CBI) für volle Funktion.
- Controller: ergänzt um fehlende Endpoints, Apply ruft Migration auf.
- Migration: `migrate_0.5.16_002_to_006.sh` für interface→iface, vip→vip_cidr, setzt unicast_src_ip.
- Installer: Migration automatisch eingebunden.

## 0.5.16-007 (2025-08-24)
- LuCI Settings: neue Option 'ssh_backend' (auto/dropbear/openssh).
- Neues Hilfsskript: /usr/lib/ha-vrrp/lib/ssh_backend.sh (wählt SSH/SCP-Binaries).
- Neue backend-aware Beispiele: /usr/libexec/ha-vrrp/keysync.sh und syncpush.sh.
- Controller: Endpoints 'keysync' und 'syncpush' rufen die neuen Skripte auf.
- Migration: scripts/migrate_0.5.16_002_to_007.sh setzt Defaults und mappt legacy Keys.


## 0.5.16-007_reviewfix1 (2025-08-24)
- Added FEATURES.md (aggregiert aus docs/features/FEATURES_*.md)
- Overview-Template abgesichert (Guard auf self.map.uci)

### 2025-08-27 – 0.5.16-007_reviewfix15a4
- Neu: Dispatcher für installer/uninstaller + GitHub-Fetch + Upgrade-Runner.
- Reorg: Versionierte Docs in Unterordner 0.5.16-007/.
- Migration: 15a3 → 15a4 (Stub).

## 0.5.16-007_reviewfix16_featurefix3 — 2025-08-27
- Introduce `current.md` workflow under `docs/releases/current/`.
- Enhanced `scripts/tools/release-helper.sh` to materialize `current.md` into release docs, changelogs, and migrate script.
- Added git `commit-msg` hook to enforce updating `current.md` when code changes are staged.

- docs: relocate workflow prompt to `docs/release-workflow-prompt/development-change-PROMPT-WORKFLOW.md`

## 0.5.16-007_reviewfix16_featurefix4 — 2025-08-27
- Materialize current.md; add migration for workflow prompt path; sync central docs.
