#!/usr/bin/env bash

#############
# satisfactory.sh
# Installer für Satisfactory Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_satisfactory() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="1690800"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere Satisfactory Dedicated Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für Satisfactory fehlgeschlagen."
        return 1
    fi
    print_success "Satisfactory-Server-Dateien in ${BASE_DIR}."

    print_info "Hinweis: Passe Startparameter und Ports (7777 UDP, 8888 TCP) manuell an."
    # Optionale Stub-Datei schreiben
    echo "# Editiere Startparameter in Deinem Startskript" > "${BASE_DIR}/README.txt"
    print_success "README-Stubs angelegt."

    echo "${SERVER_NAME}:satisfactory:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "Satisfactory-Server '${SERVER_NAME}' registriert."
}
