#!/usr/bin/env bash

#############
# management.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.2
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

# ---- Helpers -------------------------------------------------
function get_servers() {
    local list_file="${DATA_DIR}/servers.list"
    [[ -f "${list_file}" ]] || touch "${list_file}"
    grep -vE '^\s*#' "${list_file}" | grep -vE '^\s*$' | awk -F ':' '{print $1}'
}

function load_server_entry() {
    local name="$1"
    grep -vE '^\s*#' "${DATA_DIR}/servers.list" | grep -E "^${name}:" | head -n1
}

# ---- Start/Stop/Status --------------------------------------
function start_server() {
    local name="$1"
    IFS=':' read -r srv_name srv_type srv_dir <<< "$(load_server_entry "$name")"
    if pgrep -f "${srv_dir}" &>/dev/null; then
        print_warning "Server '$srv_name' läuft bereits."
        return
    fi
    print_header "Starte Server: ${srv_name} (${srv_type})"
    local cmd
    case "$srv_type" in
        7dtd)    cmd="cd '${srv_dir}' && ./startserver.sh -configfile=serverconfig.xml" ;;
        rust)    cmd="cd '${srv_dir}' && ./RustDedicated -batchmode +server.ip 0.0.0.0 +server.port 28015 +server.seed 12345 +rcon.port 28016 +rcon.password changeme" ;;
        valheim) cmd="cd '${srv_dir}' && ./start_server.sh" ;;
        csgo)    cmd="cd '${srv_dir}/csgo' && ./srcds_run -game csgo -console -usercon +game_type 0 +game_mode 1 +map de_dust2 -tickrate 128 +sv_setsteamaccount <GSLT_TOKEN> +maxplayers_override 16" ;;
        *)       cmd="cd '${srv_dir}' && ./start.sh" ;;
    esac

    if command -v tmux &>/dev/null; then
        tmux new-session -d -s "arcade_${srv_name}" $cmd
    elif command -v screen &>/dev/null; then
        screen -dmS "arcade_${srv_name}" bash -c "$cmd"
    else
        nohup bash -c "$cmd" &>/dev/null
    fi
    print_success "Server '${srv_name}' gestartet."
}

function stop_server() {
    local name="$1"
    local srv_name srv_type srv_dir
    IFS=':' read -r srv_name srv_type srv_dir <<< "$(load_server_entry "$name")"
    print_header "Stoppe Server: ${srv_name}"
    if tmux has-session -t "arcade_${srv_name}" 2>/dev/null; then
        tmux send-keys -t "arcade_${srv_name}" "quit" Enter
        sleep 5
        tmux kill-session -t "arcade_${srv_name}"
    elif screen -list | grep -q "arcade_${srv_name}"; then
        screen -S "arcade_${srv_name}" -X stuff "quit$(printf '\r')"
        sleep 5
        screen -S "arcade_${srv_name}" -X quit
    else
        pkill -f "${srv_dir}" || true
    fi
    print_success "Server '${srv_name}' gestoppt."
}

function restart_server() { stop_server "$1"; sleep 2; start_server "$1"; }

function status_server() {
    local name="$1"
    local srv_name
    IFS=':' read -r srv_name _ <<< "$(load_server_entry "$name")"
    print_header "Status von Server: ${srv_name}"
    if pgrep -f "${srv_name}" &>/dev/null; then
        print_success "Server '${srv_name}' läuft."
    else
        print_warning "Server '${srv_name}' ist nicht aktiv."
    fi
}

# ---- Backup --------------------------------------------------
function backup_server() {
    local name="$1"
    local srv_name srv_type srv_dir timestamp backup_dir backup_file
    IFS=':' read -r srv_name srv_type srv_dir <<< "$(load_server_entry "$name")"
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_dir="${DATA_DIR}/backups/${srv_name}"
    mkdir -p "${backup_dir}"
    backup_file="${backup_dir}/${srv_name}_${timestamp}.zip"
    print_header "Erstelle Backup für: ${srv_name}"
    zip -r "${backup_file}" "${srv_dir}" >/dev/null
    print_success "Backup gespeichert: ${backup_file}"
}

function restore_backup() {
    local name="$1"
    local srv_name srv_type srv_dir backup_dir bf
    IFS=':' read -r srv_name srv_type srv_dir <<< "$(load_server_entry "$name")"
    backup_dir="${DATA_DIR}/backups/${srv_name}"
    [[ -d "${backup_dir}" ]] || { print_error "Keine Backups gefunden."; return; }

    print_header "Backups für ${srv_name}:"
    select bf in $(ls "${backup_dir}"/*.zip 2>/dev/null); do
        [[ -n "$bf" ]] || { print_error "Ungültige Auswahl."; return; }
        confirm "Backup '${bf}' einspielen?" || return
        stop_server "$name"
        unzip -o "$bf" -d "${srv_dir}" >/dev/null
        print_success "Backup wiederhergestellt."
        start_server "$name"
        break
    done
}

function delete_backup() {
    local name="$1"
    local srv_name backup_dir bf
    IFS=':' read -r srv_name _ <<< "$(load_server_entry "$name")"
    backup_dir="${DATA_DIR}/backups/${srv_name}"
    [[ -d "${backup_dir}" ]] || { print_error "Keine Backups gefunden."; return; }

    print_header "Lösche Backups für ${srv_name}:"
    select bf in $(ls "${backup_dir}"/*.zip 2>/dev/null) "Abbrechen"; do
        [[ "$bf" == "Abbrechen" ]] && return
        [[ -n "$bf" ]] || { print_error "Ungültige Auswahl."; return; }
        rm -f "$bf"
        print_success "Backup '$bf' gelöscht."
        break
    done
}

# ---- Server löschen ------------------------------------------
function delete_server() {
    local name="$1"
    local srv_name srv_type srv_dir
    print_header "Lösche Server: ${name}"
    confirm "Server '${name}' inkl. Daten löschen?" || return
    stop_server "$name"
    IFS=':' read -r srv_name srv_type srv_dir <<< "$(load_server_entry "$name")"
    rm -rf "${srv_dir}"
    print_info "Verzeichnis ${srv_dir} gelöscht."
    rm -rf "${DATA_DIR}/backups/${srv_name}"
    print_info "Backups entfernt."
    grep -vE "^${srv_name}:" "${DATA_DIR}/servers.list" > "${DATA_DIR}/servers.list.tmp"
    mv "${DATA_DIR}/servers.list.tmp" "${DATA_DIR}/servers.list"
    print_success "Eintrag '${srv_name}' entfernt."
}

# ---- Menü ----------------------------------------------------
function management_menu() {
    while true; do
        local servers=( $(get_servers) )
        [[ ${#servers[@]} -gt 0 ]] || { print_warning "Keine Server-Instanzen."; return; }

        local items=()
        for s in "${servers[@]}"; do items+=("$s:$s"); done

        ui_menu "Server-Management" "Wähle einen Server:" "${items[@]}"
        local srv="$MENU_RET"
        [[ -z "$srv" ]] && return

        while true; do
            ui_menu "Server: $srv" "Aktion auswählen:" \
                "start:Starten" \
                "stop:Stoppen" \
                "restart:Neustarten" \
                "status:Status" \
                "bkp:Backup erstellen" \
                "restore:Backup wiederherstellen" \
                "bkpdel:Backup löschen" \
                "delete:Server löschen" \
                "back:Zurück"
            case "$MENU_RET" in
                start)   start_server   "$srv" ;;
                stop)    stop_server    "$srv" ;;
                restart) restart_server "$srv" ;;
                status)  status_server  "$srv" ;;
                bkp)     backup_server  "$srv" ;;
                restore) restore_backup "$srv" ;;
                bkpdel)  delete_backup  "$srv" ;;
                delete)  delete_server  "$srv"; break ;;
                back|"") break ;;
                *) ;;
            esac
        done
    done
}
