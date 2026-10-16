#!/usr/bin/env bash

set -uo pipefail

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

main() {
    log "Starting error-handling demonstration."

    if ! command -v tar >/dev/null 2>&1; then
        log "ERROR: Required command 'tar' is unavailable."
        return 1
    fi

    log "PASS: Required command 'tar' is available."

    if [[ ! -d /opt/minecraft ]]; then
        log "ERROR: Minecraft directory /opt/minecraft does not exist."
        return 1
    fi

    log "PASS: Minecraft directory exists."
    log "Demonstration completed successfully."
    return 0
}

main
exit $?
