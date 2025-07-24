#!/usr/bin/env bash

#############
# utils.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.1
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

# -----------------------------------------------------------------------------
# Farben und Formatierungen
# -----------------------------------------------------------------------------
: "${RED:=\e[31m}"
: "${GREEN:=\e[32m}"
: "${YELLOW:=\e[33m}"
: "${BLUE:=\e[34m}"
: "${CYAN:=\e[36m}"
: "${BOLD:=\e[1m}"
: "${RESET:=\e[0m}"

# -----------------------------------------------------------------------------
# Ausgabefunktionen
# -----------------------------------------------------------------------------
function print_header() {
    echo -e "${BOLD}${CYAN}==> $1${RESET}"
}

function print_info() {
    echo -e "${BLUE}[INFO] ${RESET}$1"
}

function print_success() {
    echo -e "${GREEN}[OK] ${RESET}$1"
}

function print_warning() {
    echo -e "${YELLOW}[WARN] ${RESET}$1"
}

function print_error() {
    echo -e "${RED}[ERROR] ${RESET}$1" >&2
}

# -----------------------------------------------------------------------------
# Eingabe-Dialoge
# -----------------------------------------------------------------------------
function pause() {
    read -rp "Drücke Enter, um fortzufahren..." _
}

function confirm() {
    read -rp "$1 [j/N]: " reply
    case "$reply" in
        [jJ]*) return 0 ;;
        *)     return 1 ;;
    esac
}

# -----------------------------------------------------------------------------
# System-Funktionen
# -----------------------------------------------------------------------------
function detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="$ID"
    else
        DISTRO="$(uname -s)"
    fi
}

function require_command() {
    if ! command -v "$1" &>/dev/null; then
        print_warning "Installiere fehlendes Kommando: $1"
        install_package "$1"
        print_success "Kommando '$1' installiert."
    fi
}

function install_package() {
    local pkg="$1"
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y "$pkg"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$pkg"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$pkg"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg"
    else
        print_error "Kein unterstützter Paketmanager gefunden!"
        exit 1
    fi
}
# Zeichnet eine farbige Box mit Titel
function ui_box() {
    local title="$1"; shift
    local color="${CYAN}${BOLD}"
    local reset="${RESET}"
    local line_len=60
    printf "${color}%0.s=" $(seq 1 $line_len); echo -e "${reset}"
    printf "${color}==> %s${reset}\n" "$title"
    printf "${color}%0.s=${reset}" $(seq 1 $line_len); echo
    [[ $# -gt 0 ]] && echo -e "$*"
}

# Prüft ob whiptail/dialog verfügbar ist
function ui_has_dialog() {
    command -v whiptail &>/dev/null || command -v dialog &>/dev/null
}

# Menü mit whiptail/dialog oder Fallback-TUI
# Aufruf: ui_menu "Titel" "Prompt" "key1:Text1" "key2:Text2" ...
# Rückgabe: setzt globale Variable MENU_RET auf Key oder leer bei Abbruch
function ui_menu() {
    local title="$1"; shift
    local prompt="$1"; shift
    MENU_RET=""
    if ui_has_dialog; then
        local items=()
        local i=0
        for pair in "$@"; do
            local key="${pair%%:*}"
            local label="${pair#*:}"
            items+=("$key" "$label")
            ((i++))
        done
        if command -v whiptail &>/dev/null; then
            MENU_RET=$(whiptail --title "$title" --menu "$prompt" 20 70 12 "${items[@]}" 3>&1 1>&2 2>&3) || MENU_RET=""
        else
            MENU_RET=$(dialog --stdout --title "$title" --menu "$prompt" 20 70 12 "${items[@]}") || MENU_RET=""
        fi
    else
        ui_box "$title" "$prompt"
        local idx=1
        declare -A map
        for pair in "$@"; do
            local key="${pair%%:*}"
            local label="${pair#*:}"
            printf "  %2d) %s\n" "$idx" "$label"
            map[$idx]="$key"
            ((idx++))
        done
        printf "  %2d) %s\n" "0" "Abbrechen"
        read -rp "Auswahl: " sel
        [[ "$sel" =~ ^[0-9]+$ ]] || return
        [[ "$sel" == "0" ]] && return
        MENU_RET="${map[$sel]}"
    fi
}

# Eingabe-Dialog (mit whiptail/dialog Fallback)
# ui_input "Titel" "Prompt" "default"
# return via INPUT_RET
function ui_input() {
    local title="$1"; shift
    local prompt="$1"; shift
    local defval="$1"
    INPUT_RET=""
    if ui_has_dialog; then
        if command -v whiptail &>/dev/null; then
            INPUT_RET=$(whiptail --title "$title" --inputbox "$prompt" 10 70 "$defval" 3>&1 1>&2 2>&3) || INPUT_RET=""
        else
            INPUT_RET=$(dialog --stdout --title "$title" --inputbox "$prompt" 10 70 "$defval") || INPUT_RET=""
        fi
    else
        ui_box "$title" "$prompt"
        read -rp "> " INPUT_RET
        [[ -z "$INPUT_RET" ]] && INPUT_RET="$defval"
    fi
}

# Ja/Nein-Dialog (setzt CONFIRM_RET=0/1)
function ui_confirm() {
    local title="$1"; shift
    local question="$1"
    CONFIRM_RET=1
    if ui_has_dialog; then
        if command -v whiptail &>/dev/null; then
            whiptail --title "$title" --yesno "$question" 10 70
            CONFIRM_RET=$?
        else
            dialog --stdout --title "$title" --yesno "$question" 10 70
            CONFIRM_RET=$?
        fi
    else
        confirm "$question" && CONFIRM_RET=0 || CONFIRM_RET=1
    fi
}