# ArcadeOps

**ArcadeOps** ist ein professionelles Bash-Skript zur Verwaltung von dedizierten SteamCMD-Game-Servern unter Linux. Es bietet:

* **Server-Erstellung** für beliebte Spiele (7 Days To Die, Rust, Valheim, CS\:GO u.v.m.)
* **Server-Management** (Start, Stop, Restart, Statusabfrage)
* **Backup & Restore** per ZIP
* **Discord-Integration** via Webhooks (Statusnachrichten, Testnachrichten)
* **Bot-Steuerung** (Chat-Broadcasts, RCON-Bots)
* **Auto-Update** über GitHub
* **Light-** und **Premium-Version**: Quellcode-geschützt mittels `shc` in Premium

## Schnellstart

1. **Klonen** des Repositories:

   ```bash
   git clone https://github.com/gerhard-pfeiffer/arcadeops.git /opt/arcadeops
   ```
2. **Berechtigungen** setzen:

   ```bash
   cd /opt/arcadeops/bin
   chmod +x arcadeops.sh
   ```
3. **Bootstrapper** ausführen (benötigt sudo):

   ```bash
   sudo ./arcadeops.sh
   ```

   Dadurch werden alle Abhängigkeiten installiert.
4. **Hauptmenü** bedienen:

   ```bash
   ./arcadeops.sh
   ```

   Wähle im Menü `Server-Erstellung` und lege deine erste Instanz an.

## Verzeichnisstruktur

```
arcadeops/
├── bin/arcadeops.sh        # Einstiegspunkt
├── modules/                # Module für Bootstrap, Install, Management, etc.
├── config/arcadeops.conf   # Globale Einstellungen
├── config/servers/         # Spielerspezifische Configs
├── data/servers.list       # Registrierte Serverinstanzen
├── data/backups/           # Backup-Archiv
├── lib/utils.sh            # Hilfsfunktionen
├── assets/                 # ASCII-Art, shc, Dritt-Tools
├── docs/README.md          # Diese Datei
├── LICENSE                 # MIT License
└── CHANGELOG.md            # Versionshistorie
```

## Konfiguration

Spiele-spezifische Configs liegen unter `config/servers/`. Erstelle dort Dateien nach dem Muster `meineInstanz_<game>.conf` und passe Parameter an.

Global kannst du in `config/arcadeops.conf` Pfade und die Discord Webhook-URL festlegen.

## Update

Im Hauptmenü unter `Update-Skript` prüft ArcadeOps automatisch die neueste Version auf GitHub und aktualisiert sich selbst.

## Mitwirken & Lizenz

ArcadeOps steht unter der **MIT License**. Beiträge und Feature-Wünsche sind auf GitHub willkommen.

---

*© 2025 Gerhard Pfeiffer*
