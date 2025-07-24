# Datei: modules/install/valheim.sh
#!/usr/bin/env bash

#############
# valheim.sh
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

# Funktion: install_valheim <Instanz-Name>
function install_valheim() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="896660"  # Valheim Dedicated Server AppID

    # Prüfen, ob lokale SteamCMD vorhanden ist
    if [[ ! -x "${STEAMCMD_SH}" ]]; then
        print_error "Lokale SteamCMD nicht gefunden oder nicht ausführbar (${STEAMCMD_SH})."
        return 1
    fi

    print_header "Installiere Valheim Server: ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}" || { print_error "Wechsel in ${BASE_DIR} fehlgeschlagen."; return 1; }

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +login anonymous \
                   +force_install_dir "${BASE_DIR}" \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD Installation für Valheim fehlgeschlagen."
        return 1
    fi
    print_success "Valheim Server-Dateien heruntergeladen in ${BASE_DIR}."

    # Startskript
    local START_SCRIPT="${BASE_DIR}/start_server.sh"
    if [[ ! -f "${START_SCRIPT}" ]]; then
        print_info "Erstelle Startskript..."
        cat <<EOF > "${START_SCRIPT}"
#!/bin/bash
cd "\$(dirname "\$0")"
./valheim_server.x86_64 \\
    -nographics \\
    -batchmode \\
    -name "${SERVER_NAME}" \\
    -port 2456 \\
    -world "Dedicated" \\
    -password "changeme" \\
    -public 1
EOF
        chmod +x "${START_SCRIPT}"
        print_success "Startskript erstellt: ${START_SCRIPT}"
    else
        print_warning "Startskript existiert bereits: ${START_SCRIPT}"
    fi

    # Registrierung
    echo "${SERVER_NAME}:valheim:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
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
        3)
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_valheim "$srvname"
            ;;
        *) return ;;
    esac
}
