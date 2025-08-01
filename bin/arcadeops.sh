#!/usr/bin/env bash

#############
# arcadeops.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Nutzungsbedingungen siehe LICENSE. Haftungsausschluss: Use at your own risk.
#############

# Pfade
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
DATA_DIR="${SCRIPT_DIR}/../data"
LIB_DIR="${SCRIPT_DIR}/../lib"
MODULES_DIR="${SCRIPT_DIR}/../modules"

VERSION="1.0.0"

# Farben fallback (werden in utils.sh überschrieben, falls vorhanden)
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; BLUE='\e[34m'; CYAN='\e[36m'
BOLD='\e[1m'; RESET='\e[0m'

# Utils & Module laden
source "${LIB_DIR}/utils.sh"
source "${MODULES_DIR}/bootstrap.sh"
source "${MODULES_DIR}/update.sh"
source "${MODULES_DIR}/management.sh"
source "${MODULES_DIR}/discord.sh"
source "${MODULES_DIR}/bots.sh"
for installer in "${MODULES_DIR}/install/"*.sh; do
    source "$installer"
done

# ---------------------------------------------------------
# Installations-Menü (zentral)
# ---------------------------------------------------------
function install_menu() {
    ui_menu "Server-Erstellung" "Wähle einen Installer:" \
		"7dtd:7 Days To Die" \
		"rust:Rust" \
		"valheim:Valheim" \
		"csgo:CS:GO" \
		"ark:ARK: Survival Evolved" \
		"project_zomboid:Project Zomboid" \
		"satisfactory:Satisfactory" \
		"squad:Squad" \
		"tf2:Team Fortress 2" \
		"l4d2:Left 4 Dead 2" \
		"gmod:Garry’s Mod" \
		"unturned:Unturned" \
		"arma3:Arma 3"

    case "$MENU_RET" in
        7dtd)
            ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
            install_7dtd "$INPUT_RET"
            ;;
        rust)
            ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
            install_rust "$INPUT_RET"
            ;;
        valheim)
            ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
            install_valheim "$INPUT_RET"
            ;;
        csgo)
            ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
            install_csgo "$INPUT_RET"
            ;;
		ark)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_ark "$INPUT_RET"
			;;
		project_zomboid
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_project_zomboid "$INPUT_RET"
			;;
		satisfactory)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_satisfactory "$INPUT_RET"
			;;
		squad)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_squad "$INPUT_RET"
			;;
		tf2)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_tf2 "$INPUT_RET"
			;;
		l4d2)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_l4d2 "$INPUT_RET"
			;;
		gmod)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_gmod "$INPUT_RET"
			;;
		unturned)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_unturned "$INPUT_RET"
			;;
		arma3)
			ui_input "Instanzname" "Bitte eindeutigen Server-Namen eingeben:" ""
            [[ -z "$INPUT_RET" ]] && return
			install_arma3 "$INPUT_RET"
			;;
        *) ;;
    esac
}

# ---------------------------------------------------------
# Hauptmenü
# ---------------------------------------------------------
function show_main_menu() {
    while true; do
        ui_menu "ArcadeOps v${VERSION}" "Hauptmenü" \
            "bootstrap:Bootstrap (Abhängigkeiten)" \
            "install:Server-Erstellung (Installation)" \
            "manage:Server-Management" \
            "discord:Discord Webhook" \
            "bots:Bot-Steuerung" \
            "update:Update-Skript" \
            "exit:Beenden"

        case "$MENU_RET" in
            bootstrap) run_bootstrap ;;
            install)   install_menu ;;
            manage)    management_menu ;;
            discord)   discord_menu ;;
            bots)      bots_menu ;;
            update)    update_script ;;
            exit|"")   exit 0 ;;
            *) ;;
        esac
    done
}

# ---------------------------------------------------------
# Start
# ---------------------------------------------------------
run_bootstrap
show_main_menu
