#!/bin/sh
# help.sh – Kurzübersicht über die wichtigsten Helfer und Skripte

cat <<'HELP'
OpenWRT‑HA VRRP – Helferübersicht

Die folgenden Skripte stehen zur Verfügung, um die Entwicklung und Pflege des
Projekts zu erleichtern:

  manage_docs.sh   Fügt Einträge zu Teilfassungen hinzu und kann eine neue
                   Version finalisieren.  Aufruf:
                     scripts/helpers/manage_docs.sh --type <section> --entry "Text" [--new-version <version>]
                   Abschnitt: changelog|features|architecture|concepts|readme|known-issues
                   Beispiel – Kommentar in das README einfügen:
                     scripts/helpers/manage_docs.sh --type readme --entry "Dies ist ein Testcommit."

  readme.sh        Gibt die README‑Teilfassung der aktuellen oder einer
                   bestimmten Version aus.  Aufruf:
                     scripts/readme.sh [<version|package|commit>]
                   Ohne Argument wird die Version aus der Datei VERSION gelesen.
                   Beispiel – README für ein Tar‑Archiv anzeigen:
                     scripts/readme.sh openwrt-ha-vrrp-0.5.16-007_reviewfix17_a4_fix2.tar.gz

  copy_downloads (Alias) – Dieses Kommando ist weiterhin verfügbar und
                    ruft intern `dev-harvest` auf.  Es kopiert heruntergeladene
                    Archive (Tar, Zip) und IPK‑Pakete aus dem Download‑Verzeichnis in
                    den lokalen _workspace.  Beispiel:
                      ./script.sh copy_downloads

  upload_nodes (Alias) – Alias für `dev-sync-nodes`.  Überträgt alle
                    Archiv‑ und IPK‑Dateien aus dem lokalen _workspace auf
                    entfernte Knoten via scp.  Beispiel:
                      ./script.sh upload_nodes LamoboR1-1 LamoboR1-2

  helper_update_version_tags.sh
                   Aktualisiert die Versionsheader in zentralen Dateien und
                   entfernt Fix‑Suffixe.  Wird von helper_build_package.sh und
                   manage_docs.sh aufgerufen.

  helper_sync_docs.sh
                   Synchronisiert die aktuellen CONCEPTS und ARCHITECTURE mit
                   den History‑Dateien und ruft gen-base-md.sh zur Erstellung
                   der zentralen Übersichtsdateien auf.

  dev-harvest      Sammelt heruntergeladene Release‑Archive und IPK‑Pakete
                   aus dem Download‑Ordner in die lokalen Workspace‑
                   Verzeichnisse. Aufruf:
                     ./script.sh --type dev-harvest --action run

  dev-sync-nodes   Lädt die gesammelten Dateien per scp auf definierte
                   OpenWrt‑Nodes hoch. Optional kann mit --nodes 1|2|all
                   angegeben werden, welcher Node adressiert wird. Aufruf:
                     ./script.sh --type dev-sync-nodes --action run [--nodes all|1|2]

  gen-base-md.sh   Baut die aggregierten Dateien (CHANGELOG.md, FEATURES.md,
                   ARCHITECTURE.md, CONCEPTS.md, README.md, KNOWN_ISSUES.md)
                   anhand der Konfiguration in config/doc_aggregation.json.

Weitere Dokumentation findet sich in der zentralen README.md und den
versionsspezifischen Dateien unter docs/.
HELP