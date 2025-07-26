# Changelog

## [1.3.0] – 2025‑07‑26

### Hinzugefügt
- Text‑Fallback‑Menü für alle ohne `whiptail`‑Abhängigkeit (Nummerneingabe)
- Option zum Entpacken und Validieren aus lokalem Archiv (`install_from_archives.sh`)
- Unterstützung zusätzlicher Spiele: ARK, Project Zomboid, Satisfactory, Squad, TF2, L4D2, GMod, Unturned, Arma 3, Space Engineers, Tower Unite, Quake Live, Quake II, Starbound

### Geändert
- `arcadeops.sh` bereinigt (keine Verweise auf nicht vorhandenes Modul)
- Menü‑Logik vereinheitlicht, Fallback für reines Terminal‑Interface
- Alle Installer‑Module auf Unix‑EOL umgestellt

### Behoben
- Syntaxfehler in `bots.sh` korrigiert (fehlendes `done`)
- Hauptmenü wird nach Bootstrap jetzt zuverlässig angezeigt

---

## [1.2.1] – 2025‑07‑25

### Hinzugefügt
- Automatische Installation von `whiptail` im Bootstrapper, falls nicht vorhanden
- Sicherstellung, dass `ui_menu` mit `whiptail`/`dialog` funktioniert

### Geändert
- `bootstrap.sh` prüft und installiert nun `whiptail`

### Behoben
- Menüanzeige mit `ui_menu` nach Bootstrap wieder aktiv

---

## [1.2.0] – 2025‑07‑24

### Hinzugefügt
- Bootstrapper installiert automatisch alle erforderlichen 32‑Bit‑Libraries (`libc6:i386`, `libstdc++6:i386`, `libgcc-s1:i386`)
- Überarbeitete Fehlerbehandlung und Wrapper‑Erstellung in `bootstrap.sh`

### Geändert
- SteamCMD wird stets manuell per `wget` heruntergeladen und in `modules/steamcmd` entpackt
- Wrapper unter `/usr/bin/steamcmd` angelegt

### Behoben
- Fehler beim SteamCMD‑Test (fehlende 32‑Bit‑Abhängigkeiten) beseitigt

---

## [1.1.0] – 2025‑07‑23

### Hinzugefügt
- Einheitliches Menüsystem mit `whiptail`/`dialog` inklusive Fallback
- `delete_server()` im Management-Modul
- Lokale SteamCMD‑Installation plus globaler Wrapper `/usr/bin/steamcmd`
- Leichtgewichtige Dokumentationspakete (HTML, ZIP, Wiki‑Vorlagen)

### Geändert
- Installer nutzen ausschließlich lokale SteamCMD
- Zentrales Installations‑Menü in `arcadeops.sh`

### Behoben
- CRLF‑Probleme bei Shellskripten
- Reihenfolge von `+force_install_dir` korrigiert
- Fehlende `confirm()` und `pause()` ergänzt

---

## [1.0.0] – 2025‑07‑22

### Hinzugefügt
- Erste öffentliche Version (Light) von ArcadeOps
- Basis‑Bootstrapper: Abhängigkeiten prüfen, i386‑Arch aktivieren, SteamCMD‑Installation
- Text‑Menü‑Engine (Funktion `ui_menu`/`ui_box`/`ui_input`)
- Installer‑Module für 7DTD, Rust, Valheim, CS:GO
- Server‑Management: Start/Stop/Restart/Status, Backups erstellen, wiederherstellen, löschen, Server löschen
- Discord‑Webhook‑Integration
- Bot‑Steuerung (Broadcast‑ und RCON‑Bots)
- Update‑Funktion via GitHub (Download & Versionsvergleich)

### Geändert
- — (Initiale Version)

### Behoben
- — (Initiale Version)
