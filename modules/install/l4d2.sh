#!/usr/bin/env bash

#############
# l4d2.sh
# Installer für Left 4 Dead 2 Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_l4d2() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="222860"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Left 4 Dead 2 Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für L4D2 fehlgeschlagen."
        return 1
    fi
    print_success "L4D2-Server-Dateien in ${BASE_DIR}."

    print_info "Erstelle Beispiel server.cfg..."
    mkdir -p "${BASE_DIR}/left4dead2/cfg"
    cat > "${BASE_DIR}/left4dead2/cfg/server.cfg" <<EOF
// Beispiel L4D2 server.cfg
hostname "${SERVER_NAME}"
sv_password ""
EOF
    print_success "Stub-Konfiguration angelegt: server.cfg"

    echo "${SERVER_NAME}:l4d2:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "L4D2-Server '${SERVER_NAME}' registriert."
}
