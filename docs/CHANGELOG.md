Current Version: 0.5.16-007_reviewfix17_a1


## 0.5.16-007_reviewfix16_featurefix5 — 2025-08-27
- Rebased featurefix5 and featurefix5 onto featurefix4.
- Cleanup: scripts root de-versioned; docs normalized to releases/changelogs.
- Ensured workflow prompt path + helpers present.

## 0.5.16-007_reviewfix17_a1 — 2025-08-27

### Added

- **Installer‑Build‑Prompt**: Added a new workflow prompt `installer-build-PROMPT.md` describing how to build installer and uninstaller scripts as well as IPK packages for each release.
- **Extended workflow documentation**: Updated the UI build prompt and documentation to reference both the development and installer build workflows in `docs/README.md`.
- **Cross‑platform sync scripts**: Provided cross‑platform sync scripts (`sync-full-repo.sh` and `sync-full-repo.ps1`) to mirror the repository without requiring `git` (carried forward from previous release).

### Fixed

- None.

### Changed

- Migrated all versioned changelog files from `docs/changelog` to `docs/changelogs` and normalised their names (e.g. `CHANGELOG_0.4.0.md` → `0.4.0.md`).  Updated scripts to reference `docs/changelogs` instead of the old path.
- Updated the `VERSION` file to `0.5.16-007_reviewfix17_a1` and propagated the new version into all top‑level and documentation files via the helper scripts.
- Updated `docs/README.md` and `README.md` to reference the new workflow prompts (development, UI build and installer build) and the new version.
