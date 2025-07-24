# Datei: modules/install/csgo.sh
#!/usr/bin/env bash

#############
# csgo.sh
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

# Funktion: install_csgo <Instanz-Name>
function install_csgo() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="740"  # CS:GO Dedicated Server AppID

    # Prüfen, ob lokale SteamCMD vorhanden ist
    if [[ ! -x "${STEAMCMD_SH}" ]]; then
        print_error "Lokale SteamCMD nicht gefunden oder nicht ausführbar (${STEAMCMD_SH})."
        return 1
    fi

    print_header "Installiere CS:GO Server: ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}" || { print_error "Wechsel in ${BASE_DIR} fehlgeschlagen."; return 1; }

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +login anonymous \
                   +force_install_dir "${BASE_DIR}" \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD Installation für CS:GO fehlgeschlagen."
        return 1
    fi
    print_success "CS:GO Server-Dateien heruntergeladen in ${BASE_DIR}."

    # Startskript
    local START_SCRIPT="${BASE_DIR}/start_csgo.sh"
    if [[ ! -f "${START_SCRIPT}" ]]; then
        print_info "Erstelle Startskript..."
        cat <<EOF > "${START_SCRIPT}"
#!/bin/bash
cd "\$(dirname "\$0")/csgo"
./srcds_run \\
    -game csgo \\
    -console \\
    -usercon \\
    +game_type 0 +game_mode 1 +map de_dust2 \\
    -tickrate 128 \\
    +sv_setsteamaccount "<DEIN_GSLT_TOKEN>" \\
    +maxplayers_override 16
EOF
        chmod +x "${START_SCRIPT}"
        print_success "Startskript erstellt: ${START_SCRIPT}"
    else
        print_warning "Startskript existiert bereits: ${START_SCRIPT}"
    fi

    # Registrierung
    echo "${SERVER_NAME}:csgo:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
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
        4)
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_csgo "$srvname"
            ;;
        *) return ;;
    esac
}
