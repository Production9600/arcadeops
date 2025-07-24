# Changelog

Alle signifikanten Änderungen an ArcadeOps werden hier dokumentiert.

## \[1.0.0] - 2025-07-21

### Hinzugefügt

* Initiale Veröffentlichung mit den folgenden Modulen:

  * `bin/arcadeops.sh` (Hauptskript mit Hauptmenü)
  * `lib/utils.sh` (Hilfsfunktionen für Farbausgabe, Logging, Package-Management)
  * `modules/bootstrap.sh` (Abhängigkeitsprüfung und Installation)
  * `modules/update.sh` (Selbst-Update via GitHub)
  * `modules/install/7dtd.sh` (Installer für 7 Days To Die)
  * `modules/install/rust.sh` (Installer für Rust)
  * `modules/install/valheim.sh` (Installer für Valheim)
  * `modules/install/csgo.sh` (Installer für CS\:GO)
  * `modules/management.sh` (Start/Stop/Restart/Status/Backup/Restore)
  * `modules/discord.sh` (Discord Webhook Integration)
  * `modules/bots.sh` (Bot-Management: Broadcast, RCON)
  * Konfigurationsdateien unter `config/`,`config/servers/`,`data/servers.list`
  * Dokumentation: `README.md`, `LICENSE`, `CHANGELOG.md`

### Geändert

* Projektstruktur etabliert und erste Konfigurationsvorlagen erstellt.

### Festgestellt

* Baseline-Funktionalität sowohl für Light- als auch Premium-Version definiert.

## \[1.1.0] - 2025-07-23
### Hinzugefügt
- Neues, einheitliches Menüsystem (whiptail/dialog-Fallback, `ui_menu`, `ui_input`, `ui_confirm`, `ui_box`)
- Funktion `delete_server()` im Server-Management
- Lokale SteamCMD-Installation in `modules/steamcmd` inkl. Wrapper & Initialisierung
- Fehlerbehebungen: CRLF-Konvertierung, `force_install_dir`-Reihenfolge in SteamCMD-Befehlen
- Dokumentationspaket für die Light-Version: Einzelne Markdown-Dateien je Funktion (für Homepage)

### Geändert
- Alle Installer verwenden nun strikt die lokale SteamCMD (`modules/steamcmd/steamcmd.sh`)
- Zentrales Installations-Menü in `bin/arcadeops.sh`; Modul-Menüs entfernt
- `servers.list` wird im Management gefiltert (keine Kommentar-/Leerzeilen im Menü)

### Behoben
- `confirm`/`pause` fehlten in utils: wieder integriert
- „Please use force_install_dir before logon!“ SteamCMD-Fehler behoben
