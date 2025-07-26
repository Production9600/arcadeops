#!/usr/bin/env bash

#############
# arma3.sh
# Installer für Arma 3 Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_arma3() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="233780"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Arma 3 Dedicated Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für Arma 3 fehlgeschlagen."
        return 1
    fi
    print_success "Arma 3-Server-Dateien in ${BASE_DIR}."

    print_info "Erstelle Beispiel server.cfg..."
    cat > "${BASE_DIR}/server.cfg" <<EOF
// Beispiel Arma 3 server.cfg
hostname = "${SERVER_NAME}";
maxPlayers = 64;
password = "";
template = "empty";
EOF
    print_success "Stub-Konfiguration angelegt: server.cfg"

    echo "${SERVER_NAME}:arma3:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Arma 3-Server '${SERVER_NAME}' registriert."
}
