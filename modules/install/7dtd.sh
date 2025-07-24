#!/usr/bin/env bash

#############
# 7dtd.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

# Modul: Installation des 7 Days To Die Dedicated Server via SteamCMD
# Wird vom Hauptskript über das install_menu() aufgerufen.

# Abhängigkeiten: zip, unzip, wget, curl, tar, tmux oder screen, plus lokale SteamCMD

# Pfade ermitteln
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"        # zwei Ebenen hoch
CONFIG_DIR="${ROOT_DIR}/config"
DATA_DIR="${ROOT_DIR}/data"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_SH="${MODULES_DIR}/steamcmd/steamcmd.sh"

# Funktion: install_7dtd <Instanz-Name>
function install_7dtd() {
    local SERVER_NAME="$1"
    local BASE_DIR="${CONFIG_DIR}/servers/${SERVER_NAME}"
    local STEAM_APP_ID="294420"  # 7 Days to Die AppID

    # Prüf-Logik für SteamCMD
    if [[ ! -x "${STEAMCMD_SH}" ]]; then
        print_error "Lokale SteamCMD (${STEAMCMD_SH}) nicht gefunden oder nicht ausführbar."
        return 1
    fi

    # Installation
    print_header "Installiere 7 Days To Die Server: ${SERVER_NAME}"
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}" || { print_error "Wechsel in ${BASE_DIR} fehlgeschlagen."; return 1; }

    print_info "Starte SteamCMD und installiere AppID ${STEAM_APP_ID}..."
    "${STEAMCMD_SH}" +login anonymous \
                   +force_install_dir "${BASE_DIR}" \
                   +app_update ${STEAM_APP_ID} validate \
                   +quit
    if [[ $? -ne 0 ]]; then
        print_error "SteamCMD Installation für 7dtd fehlgeschlagen."
        return 1
    fi
    print_success "7 Days To Die Dateien heruntergeladen in ${BASE_DIR}."

    # Standard-Konfiguration anlegen
    local CONFIG_FILE="${BASE_DIR}/serverconfig.xml"
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        print_info "Erstelle Standard-Konfiguration..."
        cat <<EOF > "${CONFIG_FILE}"
<?xml version="1.0"?>
<ServerSettings>
    <ServerName value="${SERVER_NAME}" />
    <ServerPort value="26900" />
    <ServerMaxPlayer value="10" />
    <PublicPublic value="true" />
    <ServerPassword value="" />
    <BlockServer value="false" />
    <Secured value="false" />
    <RCONPort value="8081" />
    <RCONPassword value="changeme" />
</ServerSettings>
EOF
        print_success "Standard-Konfiguration erstellt: ${CONFIG_FILE}"
    else
        print_warning "Konfigurationsdatei existiert bereits: ${CONFIG_FILE}"
    fi

    # Registrierung in servers.list
    local LIST_FILE="${DATA_DIR}/servers.list"
    echo "${SERVER_NAME}:7dtd:${BASE_DIR}" >> "${LIST_FILE}"
    print_success "Server ${SERVER_NAME} in ${LIST_FILE} registriert."
}

# Installations-Menü für Module
function install_menu() {
    clear
    print_header "Server-Erstellung - Installations-Menü"
    echo "Verfügbare Installer:" 
    echo "1) 7 Days To Die"
    echo "2) Rust"
    echo "3) Valheim"
    echo "4) Abbrechen"
    read -rp "Auswahl: " opt
    case "${opt}" in
        1)
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_7dtd "${srvname}"
            ;;
        2)  # wie bisher
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_rust "${srvname}"
            ;;
        3)  # wie bisher
            read -rp "Gib einen eindeutigen Server-Namen ein: " srvname
            install_valheim "${srvname}"
            ;;
        *) echo "Abgebrochen." ;;
    esac
}
