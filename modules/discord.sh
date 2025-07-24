#!/usr/bin/env bash

#############
# discord.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

CONF_FILE="${CONFIG_DIR}/arcadeops.conf"

function load_webhook_url() {
    [[ -f "$CONF_FILE" ]] || return 1
    WEBHOOK_URL=$(grep -E '^WEBHOOK_URL=' "$CONF_FILE" | cut -d'=' -f2-)
    [[ -n "$WEBHOOK_URL" ]]
}

function save_webhook_url() {
    local url="$1"
    mkdir -p "${CONFIG_DIR}"
    grep -v -E '^WEBHOOK_URL=' "$CONF_FILE" 2>/dev/null > "${CONF_FILE}.tmp" || true
    echo "WEBHOOK_URL=${url}" >> "${CONF_FILE}.tmp"
    mv "${CONF_FILE}.tmp" "$CONF_FILE"
    print_success "Webhook-URL gespeichert."
}

function send_discord_message() {
    if ! load_webhook_url; then
        print_error "Keine Webhook-URL konfiguriert."
        return 1
    fi
    local payload
    if [[ "$1" =~ ^\{ ]]; then
        payload="$1"
    else
        payload="{\"content\":\"$1\"}"
    fi
    curl -sS -H "Content-Type: application/json" -X POST -d "$payload" "$WEBHOOK_URL" >/dev/null
    [[ $? -eq 0 ]] && print_success "Nachricht an Discord gesendet." || print_error "Fehler beim Senden."
}

function discord_menu() {
    while true; do
        ui_menu "Discord Webhook" "Aktion wählen:" \
            "set:Webhook-URL setzen" \
            "show:Webhook-URL anzeigen" \
            "test:Testnachricht senden" \
            "back:Zurück"
        case "$MENU_RET" in
            set)
                ui_input "Webhook URL" "Bitte komplette Discord Webhook-URL eingeben:" ""
                [[ -z "$INPUT_RET" ]] && continue
                save_webhook_url "$INPUT_RET"
                ;;
            show)
                if load_webhook_url; then
                    ui_box "Webhook" "Aktuelle URL:\n$WEBHOOK_URL"
                else
                    print_warning "Keine Webhook-URL konfiguriert."
                fi
                ;;
            test)
                ui_input "Nachricht" "Testnachricht an Discord:" "ArcadeOps Test"
                [[ -n "$INPUT_RET" ]] && send_discord_message "$INPUT_RET"
                ;;
            back|"") return ;;
        esac
    done
}
