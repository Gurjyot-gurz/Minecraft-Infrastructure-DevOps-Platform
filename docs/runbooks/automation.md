# Automation Runbook

## Phase 5 — Automation

### Task 1: Minecraft Health Check

**Script:** `scripts/health-check.sh`

**Purpose:** Perform read-only health checks on the native Minecraft server.

#### Checks performed

1. **Systemd service:** Checks whether the `minecraft` service is active.
2. **TCP listener:** Checks whether port `25565` is listening.
3. **Disk usage:** Checks the filesystem containing `/opt/minecraft`.

#### Disk threshold

The script reports a failure when filesystem usage reaches or exceeds 80%.

This is a configurable lab threshold, not a universal Linux standard.

#### Exit codes

- `0`: All health checks passed.
- `1`: One or more checks failed.

#### Execution

Run from the repository root:

```bash
./scripts/health-check.sh

```

The script is read-only. It does not start, stop, restart, or modify the Minecraft server.

#### Initial test result

**Date:** 2026-10-16

- Minecraft service: PASS
- TCP port 25565: PASS
- Disk usage: PASS — 6% used, approximately 220 GB available
- Overall result: PASS

#### Limitations

A listening TCP port and an active systemd service do not guarantee that a Minecraft client can complete a connection or play successfully.

This script is a basic infrastructure health check, not a complete application-level availability test.
