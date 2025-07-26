#!/usr/bin/env bash

#############
# gmod.sh
# Installer für Garry's Mod Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_gmod() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="4020"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Garry's Mod Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für GMod fehlgeschlagen."
        return 1
    fi
    print_success "GMod-Server-Dateien in ${BASE_DIR}."

    print_info "Erstelle Beispiel server.cfg..."
    mkdir -p "${BASE_DIR}/garrysmod/cfg"
    cat > "${BASE_DIR}/garrysmod/cfg/server.cfg" <<EOF
// Beispiel GMod server.cfg
hostname "${SERVER_NAME}"
sv_password ""
host_workshop_collection "0"
EOF
    print_success "Stub-Konfiguration angelegt: server.cfg"

    echo "${SERVER_NAME}:gmod:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "GMod-Server '${SERVER_NAME}' registriert."
}
