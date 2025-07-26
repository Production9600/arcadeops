#!/usr/bin/env bash
set -euo pipefail

#############
# bootstrap.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.2.1
# Zweck: Abhängigkeiten prüfen, 32‑Bit‑Libs, SteamCMD & Whiptail installieren
#############

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
STEAMCMD_DIR="${ROOT_DIR}/modules/steamcmd"

# Farben (bis utils geladen ist)
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; BLUE='\e[34m'; CYAN='\e[36m'
BOLD='\e[1m'; RESET='\e[0m'

function print_header()  { echo -e "${BOLD}${CYAN}==> $1${RESET}"; }
function print_info()    { echo -e "${BLUE}[INFO]  ${RESET}$1"; }
function print_success() { echo -e "${GREEN}[OK]    ${RESET}$1"; }
function print_warning() { echo -e "${YELLOW}[WARN]  ${RESET}$1"; }
function print_error()   { echo -e "${RED}[ERROR] ${RESET}$1" >&2; }

# ---------------------------------------------------------
function run_bootstrap() {
    print_header "Starte Bootstrapper: Abhängigkeiten prüfen"

    # 1) i386-Architektur & 32‑Bit‑Libs
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "${ID}" =~ (ubuntu|debian) ]]; then
            print_info "Aktiviere i386-Architektur & installiere 32‑Bit‑Libs..."
            sudo dpkg --add-architecture i386
            sudo apt update -qq
            sudo apt install -y libc6:i386 libstdc++6:i386 libgcc-s1:i386
            print_success "32‑Bit‑Libraries installiert."
        fi
    fi

    # 2) Benötigte Tools (inkl. whiptail)
    for cmd in wget tar unzip zip curl whiptail; do
        if ! command -v "$cmd" &>/dev/null; then
            print_info "Installiere fehlendes Kommando: $cmd"
            if command -v apt &>/dev/null; then
                sudo apt install -y "$cmd"
            elif command -v yum &>/dev/null; then
                sudo yum install -y "$cmd"
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y "$cmd"
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm "$cmd"
            else
                print_error "Kein unterstützter Paketmanager gefunden!"
                exit 1
            fi
            print_success "Kommando '$cmd' installiert."
        fi
    done

    # 3) SteamCMD installieren (immer manuell)
    if [[ ! -x "${STEAMCMD_DIR}/steamcmd.sh" ]] || [[ ! -x "${STEAMCMD_DIR}/linux32/steamcmd" ]]; then
        print_warning "Lokale SteamCMD nicht gefunden – installiere neu"
        install_steamcmd
    else
        print_success "SteamCMD bereits vorhanden in ${STEAMCMD_DIR}"
    fi

    # 4) Testlauf
    print_info "Teste SteamCMD-Initialisierung (steamcmd +quit)..."
    if ! "${STEAMCMD_DIR}/steamcmd.sh" +quit &>/dev/null; then
        print_error "Initialisierung schlug fehl."
        exit 1
    fi

    print_success "Bootstrap abgeschlossen."
}

# ---------------------------------------------------------
function install_steamcmd() {
    local archive_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    local tmp_archive="${STEAMCMD_DIR}/steamcmd_linux.tar.gz"

    print_info "Lege Verzeichnis ${STEAMCMD_DIR} an..."
    rm -rf "${STEAMCMD_DIR}"
    mkdir -p "${STEAMCMD_DIR}"

    print_info "Lade SteamCMD-Archiv von Valve..."
    if ! wget -qO "${tmp_archive}" "${archive_url}"; then
        print_error "Download fehlgeschlagen."
        exit 1
    fi
    print_success "Archiv heruntergeladen (${tmp_archive})"

    print_info "Entpacke SteamCMD..."
    if ! tar -xzf "${tmp_archive}" -C "${STEAMCMD_DIR}"; then
        print_error "Entpacken fehlgeschlagen."
        exit 1
    fi
    rm -f "${tmp_archive}"
    print_success "Entpackt nach ${STEAMCMD_DIR}"

    print_info "Setze Ausführungsrechte auf steamcmd-Skripte..."
    chmod +x "${STEAMCMD_DIR}/steamcmd.sh" "${STEAMCMD_DIR}/linux32/steamcmd"

    print_info "Erstelle Wrapper /usr/bin/steamcmd..."
    sudo tee /usr/bin/steamcmd > /dev/null <<EOF
#!/usr/bin/env bash
exec "${STEAMCMD_DIR}/steamcmd.sh" "\$@"
EOF
    sudo chmod +x /usr/bin/steamcmd
    print_success "Wrapper erstellt (/usr/bin/steamcmd)"

    print_success "SteamCMD manuell installiert."
}

# Direktaufruf
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_bootstrap
fi
