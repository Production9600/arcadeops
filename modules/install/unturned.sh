#!/usr/bin/env bash

#############
# unturned.sh
# Installer für Unturned Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_unturned() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="1110390"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Unturned Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD mit Login und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login your_steam_user your_password \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für Unturned fehlgeschlagen."
        return 1
    fi
    print_success "Unturned-Server-Dateien in ${BASE_DIR}."

    print_info "Erstelle commands.dat mit Platzhaltern..."
    cat > "${BASE_DIR}/Commands.dat" <<EOF
Name ${SERVER_NAME}
Port 27015
MaxPlayers 24
Map PEI
SaveFolder ${SERVER_NAME}
LoginToken YOUR_GSLT_TOKEN
EOF
    print_success "Stub-Konfiguration angelegt: Commands.dat"

    echo "${SERVER_NAME}:unturned:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Unturned-Server '${SERVER_NAME}' registriert."
}
