# Changelog v0.5.16-004

- Fix: Overview 500 wegen `m` nil → Template greift nun auf `self.map.uci` zu.
- Neu: Version-/Backend-Anzeige in Overview.
- Neu: Settings um `ssh_backend`, `peer_netmask_cidr` und Hilfetexte erweitert.
- Neu: Sync-Seite unterstützt Upload von privatem Schlüssel (lokal), lokalem Pub und Peer-Pub (Trust).
- Neu: Instances-View mit Kurzbeschreibung (Platzhalter).
- Config: Standardwerte `ssh_backend=auto`, `peer_netmask_cidr=24`, `cluster_version=0.5.16-004`.
