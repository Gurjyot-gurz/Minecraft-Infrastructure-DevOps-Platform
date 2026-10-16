#!/usr/bin/env bash

set -uo pipefail

cleanup() {
    local status=$?

    trap - EXIT
    trap '' TERM INT

    printf '[INFO] Cleanup executed. Original exit status: %s\n' "$status"
    exit "$status"
}

handle_signal() {
    local signal_name="$1"

    printf '[WARNING] Received %s; exiting safely.\n' "$signal_name"
    exit 128
}

trap cleanup EXIT
trap 'handle_signal SIGTERM' TERM
trap 'handle_signal SIGINT' INT

printf '[INFO] Test process started. PID: %s\n' "$$"
printf '[INFO] Waiting for a termination signal.\n'

while true; do
    sleep 1
done
