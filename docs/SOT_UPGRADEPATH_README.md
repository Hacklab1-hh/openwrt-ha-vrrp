# Single Source of Truth for Upgrade Path

Run once after unpacking this overlay:

```sh
sh scripts/tools/upgradepath-migrate.sh
```

This will:
- move legacy `upgradepath*/updatepath*` files into `scripts/_old/`,
- create `scripts/upgradepath.unified.json` (from old JSON or TXT),
- generate `scripts/upgradepath_unified.txt` and `.md`,
- create compatibility symlinks:
  - `updatepath.txt` → `upgradepath_unified.txt`
  - `upgrade_path.txt` → `upgradepath_unified.txt`
  - `updatepath.json` → `upgradepath.unified.json`
  - `upgrade_path.json` → `upgradepath.unified.json`
  - `updatepath.md` → `upgradepath_unified.md`
  - `upgrade_path.md` → `upgradepath_unified.md`
