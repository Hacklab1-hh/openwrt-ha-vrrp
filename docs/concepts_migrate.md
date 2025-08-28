# Konzepte: Migration (Upgradepfad)

Die Migration verfolgt das Ziel, Installationen von älteren auf neuere Versionen des HA‑VRRP‑Add‑ons zu überführen, ohne Funktionalität zu verlieren oder Daten zu beschädigen.  Die Kernkonzepte sind:

- **Linearer Pfad**: Es wird definiert, welche Versionen direkt aufeinander folgen.  Ein Migrationslauf arbeitet alle Schritte vom aktuellen Stand bis zur Zielversion sequentiell ab.  Ab *reviewfix17_a4* sind außerdem Geräteprofile in `config/presets.json` hinterlegt, die den unterstützten OpenWrt‑Versionsstand pro Hardware dokumentieren (z. B. Mango GL‑MT300N‑V2, Lamobo R1, x86)【92603978916730†L320-L322】【633554760445073†L148-L156】【878966515062870†L23-L27】.  Migrationsskripte können diese Profile nutzen, um Anwender:innen vor Upgrades auf inkompatible Firmware zu warnen oder alternative Upgradepfade vorzuschlagen.
- **Atomare Änderungen**: Jede Migration führt nur die Schritte aus, die für den Übergang von einer Version zur nächsten notwendig sind.  Dadurch bleiben Migrationen klein und leicht überprüfbar.
- **Sicherungsmechanismen**: Vor jedem Schritt wird die bestehende Konfiguration gesichert.  Fehlgeschlagene Migrationen lassen sich so rückgängig machen.
- **Kompatibilität und BusyBox**: Alle Migrationsskripte sind in POSIX‑sh geschrieben und nutzen nur BusyBox‑Kommandos, um auf OpenWrt‑Systemen lauffähig zu sein.
- **Dokumentation**: Die Upgrade‑Pfad‑Dateien (`upgradepath.unified.json`, `update-path.json`) und die zugehörigen Changelogs dokumentieren, welche Änderungen in welcher Version vorgenommen werden.

Dieses Konzept ermöglicht es, das Add‑on über viele Versionen hinweg zu pflegen und dabei Abwärtskompatibilität und Stabilität zu gewährleisten.