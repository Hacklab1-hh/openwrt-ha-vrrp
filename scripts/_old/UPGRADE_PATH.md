# UPGRADE_PATH (ohne Schnellmigrationen)

| Quelle-Version | Ziel-Version | Fix-Linie / Zusatz | Verfügbare Artefakte | Empfohlener Weg |
|---|---|---|---|---|
| 0.2.0 | 0.3.0 | — | .tar.gz, .zip | installer-v0.3.0.sh |
| 0.3.0 | 0.3.0_a | Hotfix | .tar.gz, .zip | scripts/migrations/migrate_0.3.0_to_0.3.0_a.sh → installer |
| 0.3.0_a | 0.4.0 | — | .tar.gz, .zip | installer-v0.4.0.sh |
| 0.4.0 | 0.4.0_a | Hotfix | .tar.gz, .zip | scripts/migrations/migrate_0.4.0_to_0.4.0_a.sh → installer |
| 0.4.0_a | 0.5.0 | — | .tar.gz, .zip | installer-v0.5.0.sh |
| 0.5.0 | 0.5.1 | Patch | .tar.gz, .zip | scripts/migrations/migrate_0.5.0_to_0.5.1.sh |
| 0.5.1 | 0.5.2 | Legacy / Scripts | .tar.gz, .zip | installer-v0.5.2.sh |
| 0.5.2 | 0.5.3 … 0.5.8 | Minor Releases | .tar.gz, .zip | jeweiliger Installer |
| 0.5.8 | 0.5.9 | — | .tar.gz, .zip | installer-v0.5.9.sh |
| 0.5.9 | 0.5.10 | — | .tar.gz, .zip | installer-v0.5.10.sh |
| 0.5.10 | 0.5.11 | — | .tar, .tar.gz, .zip | installer-v0.5.11.sh |
| 0.5.11 | 0.5.12 | — | .tar, .tar.gz, .zip | installer-v0.5.12.sh |
| 0.5.12 | 0.5.13 | — | .tar, .tar.gz, .zip | installer-v0.5.13.sh |
| 0.5.13 | 0.5.14 | — | .tar, .tar.gz, .zip | installer-v0.5.14.sh |
| 0.5.14 | 0.5.15_b | — | .tar, .tar.gz, .zip | installer-v0.5.15_b.sh |
| 0.5.15_b | 0.5.16 | Basis 0.5.16 | .tar, .tar.gz, .zip | installer-v0.5.16.sh |
| 0.5.16 | 0.5.16-002 | Subrelease | .tar, .tar.gz, .zip | installer-v0.5.16-002.sh |
| 0.5.16-002 | 0.5.16-004 | Patch | .tar, .tar.gz | scripts/migrations/migrate_002_to_004.sh → installer |
| 0.5.16-004 | 0.5.16-005 | — | .tar, .tar.gz, .zip | installer-v0.5.16-005.sh |
| 0.5.16-005 | 0.5.16-006 | +fixed | .tar, .tar.gz, .zip | installer-v0.5.16-006_fixed.sh |
| 0.5.16-006 | 0.5.16-007 | Stable UI | .tar, .tar.gz, .zip | installer-v0.5.16-007.sh |
| 0.5.16-007 | 0.5.16-007_infofix2_installerfix1_uninstallerfix1_managerfix1_installergrid1 | Fix-Linien vollständig | .tar, .tar.gz | installer-v0.5.16-007.sh + Manager(Grid) |
| 0.5.16-007_infofix2_installerfix1_uninstallerfix1_managerfix1_installergrid1 | 0.5.16-007_reviewfix3a | Docs konsolidiert (incl. erweiterte ARCHITECTURE.md) | .tar, .tar.gz, .zip | installer-v0.5.16-007_reviewfix3a.sh |
| 0.5.16-007_reviewfix3a | 0.5.16-008 | Migration auf CIDR/Discover | .tar, .tar.gz, .zip | scripts/migrations/migrate_0.5.16_007_to_008.sh → installer |
| 0.5.16-008 | 0.5.16-008_patched_fixed_infofix | Controller/UI-Fixes | .tar, .tar.gz, .zip | installer-v0.5.16-008_patched_fixed_infofix.sh |
| 0.5.16-008_patched_fixed_infofix | 0.5.16-009 | Letzter Stand (Overview-Fix) | .tar, .tar.gz, .zip | scripts/migrations/migrate_0.5.16_008_to_009.sh → installer |
| 0.5.16-009 | 0.5.16-009_reviewfix3 | Docs + Path integriert | .tar, .tar.gz, .zip | installer-v0.5.16-009_reviewfix3.sh |