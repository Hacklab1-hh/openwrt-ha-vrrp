# Konzepte: Installer

Das Installationssystem verfolgt das Prinzip der Versionsspezifität: Jede Version des Add‑ons kann ihr eigenes Installationsskript besitzen.  Dadurch lassen sich notwendige Änderungen bei Dateipfaden, UCI‑Defaults oder Abhängigkeiten präzise anpassen, ohne alte Versionen zu beeinflussen.  Seit **reviewfix17_a4** wird dieses Konzept durch ein **Preset‑System** ergänzt:  In `config/presets.json` sind für die Modi *dev* und *node* die Arbeits‑ und Installationsverzeichnisse definiert.  Im Dev‑Modus ist der aktuelle Ordner des Workspace der Installationsort, während im Node‑Modus `/root/openwrt-ha-vrrp-current` verwendet wird.

Wesentliche Konzepte:

    - **Dispatcher mit Fallback**: Ein zentrales Script (`installer.sh`) entscheidet zur Laufzeit, ob ein spezialisierter Installer verfügbar ist, und greift andernfalls zu einem generischen Fallback.  Über das Preset‑System bestimmt es außerdem den korrekten Installationsort und die Pfade für Repositories.  Dies ermöglicht Installationen auch dann, wenn keine Versionierungsskripte vorhanden sind und sorgt für Konsistenz zwischen Entwicklungs‑ und Produktionssystemen.
    - **Automatisches Nachladen**: Fehlt der Installer lokal und ist `MODE=auto`, kann das Script die gewünschte Version aus dem GitHub‑Repository herunterladen.  So lassen sich Systeme ohne vollständiges Repository aktualisieren.  Auch hierbei orientiert sich das Skript am Preset, um Archive im richtigen Verzeichnis abzulegen.
- **BusyBox‑Kompatibilität**: Alle Scripts sind in POSIX‑sh geschrieben und funktionieren auf OpenWrt‑Systemen mit BusyBox.  Externe Abhängigkeiten werden vermieden.
    - **Konfigurationsintegration**: Spezialinstallers können UCI‑Standardwerte setzen, Dienste registrieren oder bestehende Konfigurationen migrieren.  Der generische Installer beschränkt sich auf das Kopieren der Dateien in die vom Preset definierten Zielpfade.

Dieses Konzept gewährleistet eine robuste Installation über viele Versionen hinweg und erleichtert die Pflege des Projekts.  Die Preset‑Logik stellt sicher, dass sowohl der Entwicklungs‑ als auch der Node‑Modus konsistent und nachvollziehbar ablaufen.