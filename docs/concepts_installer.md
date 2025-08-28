# Konzepte: Installer

Das Installationssystem verfolgt das Prinzip der Versionsspezifität: Jede Version des Add‑ons kann ihr eigenes Installationsskript besitzen.  Dadurch lassen sich notwendige Änderungen bei Dateipfaden, UCI‑Defaults oder Abhängigkeiten präzise anpassen, ohne alte Versionen zu beeinflussen.

Wesentliche Konzepte:

- **Dispatcher mit Fallback**: Ein zentrales Script (`installer.sh`) entscheidet zur Laufzeit, ob ein spezialisierter Installer verfügbar ist, und greift andernfalls zu einem generischen Fallback.  Dies ermöglicht Installationen auch dann, wenn keine Versionierungsskripte vorhanden sind.
- **Automatisches Nachladen**: Fehlt der Installer lokal und ist `MODE=auto`, kann das Script die gewünschte Version aus dem GitHub‑Repository herunterladen.  So lassen sich Systeme ohne vollständiges Repository aktualisieren.
- **BusyBox‑Kompatibilität**: Alle Scripts sind in POSIX‑sh geschrieben und funktionieren auf OpenWrt‑Systemen mit BusyBox.  Externe Abhängigkeiten werden vermieden.
- **Konfigurationsintegration**: Spezialinstallers können UCI‑Standardwerte setzen, Dienste registrieren oder bestehende Konfigurationen migrieren.  Der generische Installer beschränkt sich auf das Kopieren der Dateien.

Dieses Konzept gewährleistet eine robuste Installation über viele Versionen hinweg und erleichtert die Pflege des Projekts.