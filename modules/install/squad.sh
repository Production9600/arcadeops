#!/usr/bin/env bash

#############
# squad.sh
# Installer für Squad Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_squad() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="403240"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Squad Dedicated Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für Squad fehlgeschlagen."
        return 1
    fi
    print_success "Squad-Server-Dateien in ${BASE_DIR}."

    print_info "Stub: Erstelle ServerConfig-Verzeichnis..."
    mkdir -p "${BASE_DIR}/SquadGame/ServerConfig"
    cat > "${BASE_DIR}/SquadGame/ServerConfig/Server.cfg" <<EOF
// Beispiel-ServerConfig für Squad
[Server]
Port=7787
QueryPort=7788
EOF
    print_success "Stub-Konfiguration angelegt: Server.cfg"

    echo "${SERVER_NAME}:squad:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Squad-Server '${SERVER_NAME}' registriert."
}
