#!/usr/bin/env bash

#############
# bots.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

BOTS_DIR="${CONFIG_DIR}/bots"
DATA_BOTS="${DATA_DIR}/bots.list"

function get_bots() {
    [[ -f "${DATA_BOTS}" ]] || touch "${DATA_BOTS}"
    awk -F ':' '{print $1}' "${DATA_BOTS}"
}

function load_bot_entry() {
    local botname="$1"
    grep -E "^${botname}:" "${DATA_BOTS}" | head -n1
}

function create_bot() {
    ui_input "Bot-Name" "Name für den Bot:" ""
    local botname="$INPUT_RET"
    [[ -z "$botname" ]] && return

    ui_menu "Bot-Typ" "Wähle Typ:" \
        "broadcast:Chat-Broadcast" \
        "rcon:RCON-Bot"
    local bottype="$MENU_RET"
    [[ -z "$bottype" ]] && return

    # Server auswählen
    local servers=( $(awk -F ':' '{print $1}' "${DATA_DIR}/servers.list") )
    local items=()
    for s in "${servers[@]}"; do items+=("$s:$s"); done
    ui_menu "Server wählen" "Instanz?" "${items[@]}"
    local server="$MENU_RET"
    [[ -z "$server" ]] && return

    mkdir -p "${BOTS_DIR}"
    case "$bottype" in
        broadcast)
            ui_input "Nachricht" "Broadcast-Text:" ""
            local message="$INPUT_RET"
            ui_input "Intervall" "Sekunden zwischen Nachrichten:" "1800"
            local interval="$INPUT_RET"
            echo "${botname}:${bottype}:${server}:message=${message}:interval=${interval}" >> "${DATA_BOTS}"
            ;;
        rcon)
            ui_input "RCON-Befehl" "Befehl, der ausgeführt werden soll:" ""
            local rcon_cmd="$INPUT_RET"
            echo "${botname}:${bottype}:${server}:rcon_cmd=${rcon_cmd}" >> "${DATA_BOTS}"
            ;;
    esac
    print_success "Bot '${botname}' erstellt."
}

function delete_bot() {
    local bots=( $(get_bots) )
    [[ ${#bots[@]} -gt 0 ]] || { print_warning "Keine Bots vorhanden."; return; }
    local items=()
    for b in "${bots[@]}"; do items+=("$b:$b"); done
    ui_menu "Bot löschen" "Wähle Bot:" "${items[@]}"
    local bot="$MENU_RET"
    [[ -z "$bot" ]] && return
    grep -v -E "^${bot}:" "${DATA_BOTS}" > "${DATA_BOTS}.tmp" && mv "${DATA_BOTS}.tmp" "${DATA_BOTS}"
    print_success "Bot '$bot' gelöscht."
}

function start_bot() {
    local bots=( $(get_bots) )
    [[ ${#bots[@]} -gt 0 ]] || { print_warning "Keine Bots vorhanden."; return; }
    local items=()
    for b in "${bots[@]}"; do items+=("$b:$b"); end
    ui_menu "Bot starten" "Wähle Bot:" "${items[@]}"
    local bot="$MENU_RET"
    [[ -z "$bot" ]] && return

    local entry; entry=$(load_bot_entry "$bot")
    IFS=':' read -r name type server params <<< "$entry"
    print_header "Starte Bot: $bot"
    if [[ "$type" == "broadcast" ]]; then
        local message interval
        message=$(echo "$entry" | sed -n 's/.*message=\([^:]*\).*/\1/p')
        interval=$(echo "$entry" | sed -n 's/.*interval=\([0-9]*\).*/\1/p')
        nohup bash -c "while true; do tmux send-keys -t arcade_${server} 'say ${message}' Enter; sleep ${interval}; done" >/dev/null 2>&1 &
    else
        local rcon_cmd
        rcon_cmd=$(echo "$entry" | sed -n 's/.*rcon_cmd=\([^:]*\).*/\1/p')
        nohup bash -c "while true; do mcrcon -H 127.0.0.1 -P 28016 -p changeme '${rcon_cmd}'; sleep 60; done" >/dev/null 2>&1 &
    fi
    print_success "Bot '$bot' gestartet."
}

function stop_bot() {
    local bots=( $(get_bots) )
    [[ ${#bots[@]} -gt 0 ]] || { print_warning "Keine Bots vorhanden."; return; }
    local items=()
    for b in "${bots[@]}"; do items+=("$b:$b"); done
    ui_menu "Bot stoppen" "Wähle Bot:" "${items[@]}"
    local bot="$MENU_RET"
    [[ -z "$bot" ]] && return
    pkill -f "$bot" || print_warning "Kein laufender Prozess gefunden."
    print_success "Bot '$bot' gestoppt."
}

function list_bots() {
    ui_box "Bots" "$(cat "${DATA_BOTS}")"
}

function bots_menu() {
    while true; do
        ui_menu "Bot-Steuerung" "Aktion wählen:" \
            "create:Bot erstellen" \
            "delete:Bot löschen" \
            "start:Bot starten" \
            "stop:Bot stoppen" \
            "list:Liste aller Bots" \
            "back:Zurück"
        case "$MENU_RET" in
            create) create_bot ;;
            delete) delete_bot ;;
            start)  start_bot ;;
            stop)   stop_bot ;;
            list)   list_bots ;;
            back|"") return ;;
        esac
    done
}
