#!/usr/bin/env bash

set -uo pipefail

# Minecraft Health Check
# Read-only checks: this script does not modify the server.

SERVICE="minecraft"
SERVER_PORT=25565
DISK_PATH="/opt/minecraft"
DISK_WARNING_PERCENT=80

FAILURES=0

check_service() {
    if systemctl is-active --quiet "$SERVICE"; then
        echo "[PASS] Minecraft service is active."
    else
        echo "[FAIL] Minecraft service is not active."
        FAILURES=$((FAILURES + 1))
    fi
}

check_port() {
    if ss -ltnH "sport = :$SERVER_PORT" | grep -q .; then
        echo "[PASS] TCP port $SERVER_PORT is listening."
    else
        echo "[FAIL] TCP port $SERVER_PORT is not listening."
        FAILURES=$((FAILURES + 1))
    fi
}

check_disk() {
    if ! df -P "$DISK_PATH" >/dev/null 2>&1; then
        echo "[FAIL] Cannot inspect disk usage for $DISK_PATH."
        FAILURES=$((FAILURES + 1))
        return
    fi

    DISK_USAGE=$(df -P "$DISK_PATH" | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')
    DISK_AVAILABLE=$(df -hP "$DISK_PATH" | awk 'NR == 2 {print $4}')

    if [[ ! "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
        echo "[FAIL] Could not determine disk usage."
        FAILURES=$((FAILURES + 1))
    elif (( DISK_USAGE >= DISK_WARNING_PERCENT )); then
        echo "[FAIL] Disk usage is ${DISK_USAGE}% (${DISK_AVAILABLE} available). Threshold: ${DISK_WARNING_PERCENT}%."
        FAILURES=$((FAILURES + 1))
    else
        echo "[PASS] Disk usage is ${DISK_USAGE}% (${DISK_AVAILABLE} available)."
    fi
}

echo "=================================="
echo " Minecraft Health Check"
echo "=================================="

check_service
check_port
check_disk

echo "----------------------------------"

if (( FAILURES > 0 )); then
    echo "RESULT: FAIL ($FAILURES check(s) failed)"
    exit 1
fi

echo "RESULT: PASS (all checks passed)"
exit 0
