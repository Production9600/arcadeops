#!/usr/bin/env bash

#############
# bootstrap.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.6
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_DIR="${ROOT_DIR}/lib"
MODULES_DIR="${ROOT_DIR}/modules"
STEAMCMD_DIR="${MODULES_DIR}/steamcmd"

source "${LIB_DIR}/utils.sh"

function run_bootstrap() {
    print_header "Starte Bootstrapper: Abhängigkeiten prüfen"
    detect_distro
    if [[ "${DISTRO}" =~ (ubuntu|debian) ]]; then
        print_info "Aktiviere i386-Architektur für 32‑Bit‑Libs..."
        sudo dpkg --add-architecture i386
        sudo apt update -qq
    fi
    for cmd in zip unzip curl wget tar tmux screen; do
        require_command "${cmd}"
    done
    if [[ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]]; then
        print_warning "Lokale SteamCMD-Kopie nicht gefunden – installiere in modules/steamcmd"
        install_steamcmd || { print_error "SteamCMD-Installation abgebrochen."; return 1; }
    else
        print_success "Lokale SteamCMD-Kopie gefunden."
    fi
    print_success "Bootstrap abgeschlossen."
}

function install_steamcmd() {
    local archive_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    local tmp_archive="${STEAMCMD_DIR}/steamcmd_linux.tar.gz"

    print_info "Lege Verzeichnis ${STEAMCMD_DIR} an..."
    mkdir -p "${STEAMCMD_DIR}"

    print_info "Lade SteamCMD von Valve..."
    wget -qO "${tmp_archive}" "${archive_url}"
    if [[ $? -ne 0 || ! -s "${tmp_archive}" ]]; then
        print_error "Download fehlgeschlagen oder Datei leer."
        return 1
    fi
    print_success "Archiv heruntergeladen."

    print_info "Entpacke Archiv..."
    tar -xzf "${tmp_archive}" -C "${STEAMCMD_DIR}"
    rm -f "${tmp_archive}"

    chmod +x "${STEAMCMD_DIR}/steamcmd.sh"
    chmod +x "${STEAMCMD_DIR}/linux32/steamcmd"

    print_info "Erstelle Wrapper /usr/bin/steamcmd..."
    sudo tee /usr/bin/steamcmd > /dev/null <<EOF
#!/usr/bin/env bash
exec "${STEAMCMD_DIR}/steamcmd.sh" "\$@"
EOF
    sudo chmod +x /usr/bin/steamcmd
    print_success "Wrapper angelegt."

    print_info "Teste SteamCMD (steamcmd +quit)..."
    "${STEAMCMD_DIR}/steamcmd.sh" +quit
    if [[ $? -ne 0 ]]; then
        print_error "Initialisierung schlug fehl."
        return 1
    fi
    print_success "SteamCMD initialisiert."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_bootstrap
fi
