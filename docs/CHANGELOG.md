Current Version: 0.5.16-007_reviwefix17


## 0.5.16-007_reviewfix16_featurefix5 — 2025-08-27
- Rebased featurefix5 and featurefix5 onto featurefix4.
- Cleanup: scripts root de-versioned; docs normalized to releases/changelogs.
- Ensured workflow prompt path + helpers present.

## 0.5.16-007_reviwefix17 — 2025-08-27

### Added

- **Improved UI stability and modularity**: The LuCI-based UI for the HA VRRP add‑on was refactored into isolated modules.  Errors in one module now fall back gracefully instead of crashing the entire page.
- **Cross‑platform sync scripts**: Added `sync-full-repo.sh` for BusyBox/POSIX shells and `sync-full-repo.ps1` for PowerShell.  These scripts mirror GitHub branches/tags without requiring `git`, unpack them into versioned directories and update a `current` symlink.
- **JSON status API**: Added a new `/status_json` endpoint to the LuCI controller and a standalone CGI script to return the add‑on’s status as JSON (including installed version, Keepalived state and last migration step).  This allows external monitoring systems such as Home Assistant to integrate the cluster status.
- **Helper scripts**: Introduced helper scripts for normalising version tags (`helper_update_version_tags.sh`), syncing concept/architecture docs and history (`helper_sync_docs.sh`), running smoke tests (`helper_smoketests.sh`) and building release packages (`helper_build_package.sh`).  These helpers ensure that the `docs/CONCEPTS.md` and `docs/ARCHITECTURE.md` files always reflect the current version while maintaining per‑version partials.
- **Migration framework update**: Added a migration script for this version that performs no system changes but records the update in the state file.  The unified upgrade path JSON was extended to include this version with its parent.

### Fixed

- None.

### Changed

- Updated `VERSION` to `0.5.16-007_reviwefix17` and propagated the new version into all top‑level and documentation files.
