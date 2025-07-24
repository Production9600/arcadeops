# Datei: modules/install/rust.sh
#!/usr/bin/env bash

#############
# rust.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

# Pfad‑Ermittlung
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

# Funktion: install_rust <Instanz-Name>
function install_rust() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="258550"  # Rust Dedicated Server AppID

    # Prüfen, ob lokale SteamCMD vorhanden ist
    if [[ ! -x "${STEAMCMD_SH}" ]]; then
        print_error "Lokale SteamCMD nicht gefunden oder nicht ausführbar (${STEAMCMD_SH})."
        return 1
    fi

    print_header "Installiere Rust Server: ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}" || { print_error "Wechsel in ${BASE_DIR} fehlgeschlagen."; return 1; }

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +login anonymous \
                   +force_install_dir "${BASE_DIR}" \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD Installation für Rust fehlgeschlagen."
        return 1
    fi
    print_success "Rust Server-Dateien heruntergeladen in ${BASE_DIR}."

    # Standard-Konfiguration
    local CONFIG_FILE="${BASE_DIR}/server.cfg"
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        print_info "Erstelle Standard-Konfiguration..."
        cat <<EOF > "${CONFIG_FILE}"
server.tickrate 30
server.maxplayers 50
server.hostname "${SERVER_NAME}"
server.identity "${SERVER_NAME}"
server.seed 12345
server.worldsize 4000
server.url ""
server.saveinterval 600
rcon.password "changeme"
rcon.port 28016
server.description ""
server.headerimage ""
EOF
        print_success "Standard-Konfiguration erstellt: ${CONFIG_FILE}"
    else
        print_warning "Konfigurationsdatei existiert bereits: ${CONFIG_FILE}"
    fi

    # Registrierung
    echo "${SERVER_NAME}:rust:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Server ${SERVER_NAME} in ${DATA_DIR}/servers.list registriert."
}

# Menü
function install_menu() {
    clear
    print_header "Server-Erstellung - Installations-Menü"
    echo "Verfügbare Installer:"
    echo "1) 7 Days To Die"
    echo "2) Rust"
    echo "3) Valheim"
    echo "4) CS:GO"
    echo "5) Abbrechen"
    read -rp "Auswahl: " opt
    case "$opt" in
        2)
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_rust "$srvname"
            ;;
        *) return ;;
    esac
}
