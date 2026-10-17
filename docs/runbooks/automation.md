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

### Task 2: Bash Error Handling and Reliability

#### Concepts Practiced

- `set -Eeuo pipefail` enables stricter Bash error handling.
- `set -u` detects references to unset variables.
- `set -e` helps terminate execution after many unhandled command failures.
- `set -o pipefail` propagates failures from commands in pipelines.
- Explicit exit codes communicate success or failure to calling automation.
- Functions organize reusable logging and error-handling logic.

#### Minecraft Backup Script

The backup script at `/usr/local/bin/minecraft-backup.sh` includes:

- Root privilege validation.
- A `flock` lock to prevent overlapping backup runs.
- Pre-flight checks before Minecraft downtime.
- An EXIT trap for cleanup and service recovery.
- Local archive integrity and SHA-256 verification.
- S3 upload and remote checksum verification.
- Local backup retention.

#### Failure Handling Limitations

The EXIT trap can attempt cleanup and service recovery when the shell exits normally or handles a catchable termination signal.

It cannot guarantee recovery after `SIGKILL`, a kernel failure, or sudden power loss.

The script's actual recovery behaviour must be validated separately from a successful backup run.

#### Testing Status

- Error-handling demo: PASS.
- Missing-directory failure simulation: PASS; exit code 1 returned as expected.
- Backup script review: Source code inspected.
- Backup failure injection: NOT PERFORMED.
- Crash and reboot recovery: NOT TESTED.

### Signal Handling and Backup Script Reliability

**Production backup script improvements:**
- Created a timestamped backup of the original backup script before editing.
- Added explicit SIGTERM and SIGINT handlers.
- SIGTERM requests exit status 143; SIGINT requests exit status 130.
- The EXIT trap invokes the existing cleanup function.
- Cleanup ignores additional SIGTERM and SIGINT signals while recovery runs.
- Existing cleanup logic attempts to restart Minecraft if the service was active before the backup.

**Validation:**
- `scripts/error-handling-demo.sh`: passed.
- `scripts/failure-test.sh`: expected failure confirmed with exit code 1.
- `scripts/signal-handling-test.sh`: SIGTERM handling and EXIT cleanup passed; exit status 143 verified.
- `sudo bash -n /usr/local/bin/minecraft-backup.sh`: passed after editing.

**Limitations:**
- Production backup script signal handling has not been runtime-tested.
- Minecraft service recovery under interrupted backup conditions remains unverified.
- Bash syntax validation does not guarantee runtime correctness.
