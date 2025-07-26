#!/usr/bin/env bash

#############
# project_zomboid.sh
# Installer für Project Zomboid Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_project_zomboid() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="380870"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Project Zomboid Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für PZ fehlgeschlagen."
        return 1
    fi
    print_success "Project Zomboid-Dateien in ${BASE_DIR}."

    print_info "Erstelle Beispiel-ServerOptions.ini..."
    mkdir -p "${BASE_DIR}/Zomboid/Server"
    cat > "${BASE_DIR}/Zomboid/Server/ServerOptions.ini" <<EOF
# Beispiel-Konfiguration
Options.ini = ServerOptions.ini
Version = 41

Public = True
PublicName = "${SERVER_NAME}"
MaxPlayers = 16
Port = 16261
QueryPort = 16262
EOF
    print_success "Stub-Konfiguration angelegt: ServerOptions.ini"

    echo "${SERVER_NAME}:project_zomboid:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Project Zomboid-Server '${SERVER_NAME}' registriert."
}
