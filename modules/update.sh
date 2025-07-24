#!/usr/bin/env bash

#############
# update.sh
# Copyright (c) Gerhard Pfeiffer 2025
# Versionsnummer: 1.0.0
# Disclaimer: Use at your own risk. Siehe LICENSE für Details.
#############

# Modul: Selbst-Update-Logik für ArcadeOps
# Ermöglicht das einfache Aktualisieren des Skripts aus einem GitHub-Repository.

# Konfiguration
GITHUB_USER="gerhard-pfeiffer"
GITHUB_REPO="arcadeops"
GITHUB_BRANCH="main"
SCRIPT_NAME="arcadeops.sh"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/bin/${SCRIPT_NAME}"

function update_script() {
    print_header "Prüfe auf neue Version von ArcadeOps..."
    # Aktuelle Version aus dem Skript auslesen
    local CURRENT_VER="${VERSION}"

    # Temp-Datei für den Download
    local TMP_FILE
    TMP_FILE=$(mktemp)

    # Herunterladen der neuesten Skript-Version
    print_info "Lade ${RAW_URL} herunter..."
    if ! curl -sSfL "${RAW_URL}" -o "${TMP_FILE}"; then
        print_error "Fehler beim Herunterladen der neuen Version."
        return 1
    fi

    # Versionsnummer aus der Temp-Datei extrahieren
    local NEW_VER
    NEW_VER=$(grep -E "^# Versionsnummer:" "${TMP_FILE}" | head -n1 | cut -d ':' -f2 | tr -d '[:space:]')

    if [[ -z "${NEW_VER}" ]]; then
        print_error "Konnte Versionsnummer der neuen Version nicht ermitteln."
        rm -f "${TMP_FILE}"
        return 1
    fi

    print_info "Aktuelle Version: ${CURRENT_VER}, Neue Version: ${NEW_VER}"
    if [[ "${NEW_VER}" == "${CURRENT_VER}" ]]; then
        print_success "Du hast bereits die neueste Version (v${CURRENT_VER})."
        rm -f "${TMP_FILE}"
        return 0
    fi

    # Update verfügbar
    if confirm "Version ${NEW_VER} verfügbar. Möchtest du updaten?"; then
        # Backup aktuelles Skript
        cp "${SCRIPT_DIR}/../bin/${SCRIPT_NAME}" "${SCRIPT_DIR}/../bin/${SCRIPT_NAME}.bak.OLD"
        # Übernehmen der neuen Version
        mv "${TMP_FILE}" "${SCRIPT_DIR}/../bin/${SCRIPT_NAME}"
        chmod +x "${SCRIPT_DIR}/../bin/${SCRIPT_NAME}"
        print_success "Update auf Version ${NEW_VER} erfolgreich."
        print_info "Backup der alten Version: ${SCRIPT_NAME}.bak.OLD"
        # Skript neu starten
        exec "${SCRIPT_DIR}/../bin/${SCRIPT_NAME}"
    else
        print_info "Update abgebrochen."
        rm -f "${TMP_FILE}"
    fi
}
