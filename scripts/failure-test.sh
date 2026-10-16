#!/usr/bin/env bash

set -uo pipefail

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

TEST_PATH="/tmp/minecraft-devops-path-that-should-not-exist"

if [[ -d "$TEST_PATH" ]]; then
    log "ERROR: Test path unexpectedly exists: $TEST_PATH"
    exit 1
fi

log "ERROR: Required test directory is missing: $TEST_PATH"
log "Returning failure exit code 1."
exit 1
