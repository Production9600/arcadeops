#!/usr/bin/env bash

#############
# ark.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Installer für ARK: Survival Evolved Dedicated Server
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../" && pwd)"
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

function install_ark() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="376030"

    [[ -x "${STEAMCMD_SH}" ]] || { print_error "SteamCMD fehlt (${STEAMCMD_SH})."; return 1; }

    print_header "Installiere ARK: Survival Evolved Server – ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}" && cd "${BASE_DIR}" || return 1

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +force_install_dir "${BASE_DIR}" \
                   +login anonymous \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD-Installation für ARK fehlgeschlagen."
        return 1
    fi
    print_success "ARK-Server-Dateien in ${BASE_DIR}."

    print_info "Hinweis: Passe ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini manuell an."
    mkdir -p "${BASE_DIR}/ShooterGame/Saved/Config/LinuxServer"
    cat > "${BASE_DIR}/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini" <<EOF
[ServerSettings]
ServerAdminPassword=changeme
MaxPlayers=10
ServerPassword=
EOF
    print_success "Stub-Konfiguration angelegt: GameUserSettings.ini"

    echo "${SERVER_NAME}:ark:${BASE_DIR}" >> "${DATA_DIR}/servers.list"
    print_success "ARK-Server '${SERVER_NAME}' registriert."
}
