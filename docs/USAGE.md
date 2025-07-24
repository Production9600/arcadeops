# ArcadeOps – Ausführliche Bedienungsanleitung

Diese Anleitung beschreibt alle wichtigen Schritte und Optionen zur Verwendung von **ArcadeOps**.

## 1. Installation

1. Repository klonen (Beispiel-Pfad `/opt/arcadeops`):

   ```bash
   sudo git clone https://github.com/gerhard-pfeiffer/arcadeops.git /opt/arcadeops
   ```
2. Zugriffsrechte setzen und ins Bin-Verzeichnis wechseln:

   ```bash
   cd /opt/arcadeops/bin
   sudo chmod +x arcadeops.sh
   ```
3. Bootstrapper ausführen (erfordert sudo, installiert Abhängigkeiten):

   ```bash
   sudo ./arcadeops.sh
   ```

   * Das Menü startet automatisch den Bootstrapper auf Position 1.
   * Alternativ manuell:

     ```bash
     ./arcadeops.sh
     # und Auswahl: 1
     ```

## 2. Erste Konfiguration

1. Öffne die globale Konfigurationsdatei:

   ```bash
   nano /opt/arcadeops/config/arcadeops.conf
   ```
2. Passe ggf. Pfade an:

   * `DEFAULT_INSTALL_DIR` – Basisverzeichnis für neue Server
   * `BACKUP_DIR` – Pfad für ZIP-Backups
   * `LOG_DIR` – System-Log-Verzeichnis
3. Lege Discord Webhook-URL fest (optional):

   * Menüpunkt: **Discord Webhook Integration → Webhook-URL setzen**

## 3. Server-Instanz anlegen

1. Starte das Hauptmenü:

   ```bash
   ./arcadeops.sh
   ```
2. Wähle **Server-Erstellung (Installation)**
3. Entscheide dich für ein Spiel (z. B. 7 Days To Die)
4. Gib einen eindeutigen **Instanznamen** ein (z. B. `meine7tdtd`)
5. Das Skript lädt über SteamCMD die Dateien ins Verzeichnis:

   ```
   /opt/arcadeops/servers/meine7tdtd
   ```
6. Konfigurationsdatei wird automatisch erstellt unter:

   ```
   /opt/arcadeops/config/servers/meine7tdtd_7dtd.conf
   ```

## 4. Server-Verwaltung

Im Menü **Server-Management** wählst du deine Instanz aus und hast folgende Optionen:

* **Starten** – startet den Server in einer tmux- oder screen-Session
* **Stoppen** – führt geordnetes Shutdown durch, killt notfalls
* **Neustarten** – Stop + Sleep + Start
* **Status** – prüft, ob der Prozess läuft
* **Backup erstellen** – sichert Spieldaten als ZIP
* **Backup wiederherstellen** – wählt ZIP und spielt es ein
* **Backup löschen** – entfernt ein vorhandenes Backup

## 5. Discord-Integration

* **Webhook-URL setzen**: Menüpunkt **Discord Webhook Integration → Webhook-URL setzen**
* **Testnachricht senden**: Erlaubt sofortiges Versenden einer Nachricht an Discord
* **Automatische Notifications** (Premium): Einstellung in `modules/discord.sh` erweitert, z. B. in `start_server()`-Funktionen `send_discord_message`-Aufrufe aktivieren

## 6. Bot-Management

Unter **Bot-Steuerung** kannst du:

1. **Bot erstellen** – wähle Typ (`broadcast` oder `rcon`), Instanz und Parameter
2. **Bot starten** – startet dauerhaft im Hintergrund
3. **Bot stoppen** – beendet alle Bot-Prozesse
4. **Liste aller Bots** – zeigt Namen und Konfiguration
5. **Bot löschen** – entfernt Konfigurationszeile

### Beispiel: Chat-Broadcast-Bot

```bash
# erstellt eine Datei bots.list mit Eintrag:
meine7tdtdBot:broadcast:meine7tdtd:message=ServerRestartIn5Min:interval=1800
```

## 7. Update des Skripts

1. Wähle im Hauptmenü **Update-Skript**
2. Das Skript vergleicht lokale Version mit GitHub
3. Bei Verfügbarkeit wirst du zum Update gefragt
4. Bestätigt → Übernimmt neue Version inkl. Backup der alten Datei
5. Skript startet automatisch neu

## 8. Light- vs. Premium-Version

* **Light-Version**: Vollständig offen, alle Basismodule. Keine Kompilierung, kein Lizenzcheck.
* **Premium-Version**: Geschützt via `shc`, Lizenzprüfung beim Start, erweiterte Bot- und Discord-Funktionen, ggf. Web-Panel.

## 9. Fehlersuche & Logs

* Prüfe Logfiles in `/var/log/arcadeops/` oder dem unter `LOG_DIR` in `arcadeops.conf` festgelegten Pfad
* Bei Paketproblemen: manuell per `sudo apt install <fehlendes-paket>` nachinstallieren
* Discord-Fehler: stelle sicher, dass Webhook-URL korrekt ist und Internetzugang besteht

---

*© 2025 Gerhard Pfeiffer*
