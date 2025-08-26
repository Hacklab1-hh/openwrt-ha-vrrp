# upgradepath.unified.json – Schema (angereichert)

Pro Eintrag:
- `version` (string) – z. B. `0.5.16-007`
- `parent` (string|null) – direkter Vorgänger
- `series` (string) – z. B. `0.5`
- `released` (string, optional) – ISO-Datum
- `stability` (string, optional) – `alpha|beta|rc|stable`
- `tags` (string[]) – freie Schlagworte
- `summary` (string) – kurzer Freitext
- `fixline` (string) – Einzeiler aus Summary/Notes/Changelog
- `patch_name` (string) – Suffix nach `A.B.C-`, z. B. `007_reviewfix10`
- `notes` (string) – längerer Freitext
- `changelog` (string) – aus CHANGELOG-Dateien extrahierter Abschnitt
- `changes` (object):
    - `file_moves` ({src,dst}[])
    - `uci_renames` ({pkgsec,old,new}[])
    - `uci_defaults_set` ({key,value}[])
    - `remove_paths` (string[])
    - `breaking` (bool)
    - `deprecations` (string[])
- `rollback` (object):
    - `file_moves` ({src,dst}[])
    - `uci_renames` ({pkgsec,old,new}[])
    - `uci_unset` (string[])
