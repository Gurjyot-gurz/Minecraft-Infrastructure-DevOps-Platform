# Minecraft Storage, Backup and Restore Runbook

## 1. Objective

Document the initial Minecraft world backup, archive validation,
and isolated restore test.

## 2. Infrastructure

- Operating system: Ubuntu Linux
- Minecraft service: `minecraft.service`
- Server directory: `/opt/minecraft`
- World directory: `/opt/minecraft/world`
- Backup directory: `/opt/minecraft/backups`
- Restore test directory: `/tmp/minecraft-restore-test`

## 3. Backup Procedure

The Minecraft service was stopped before creating the backup.

```bash
sudo systemctl stop minecraft
sudo systemctl is-active minecraft

## 4. Backup Command
sudo tar -czf "/opt/minecraft/backups/minecraft-backup-$(date +%Y-%m-%d_%H-%M-%S).tar.gz" \
  -C /opt/minecraft \
  world server.properties whitelist.json ops.json \
  banned-players.json banned-ips.json eula.txt
```
## 4. Backup Artifact
- Archive: minecraft-backup-2026-10-14_12-15-23.tar.gz
- Location: /opt/minecraft/backups/
- Size: approximately 9.9 MB
- SHA-256:
  41bc05b97758363b623c5e116d35cac427dde5fba4691cd40338d29ed70ca4ad
```

## 5. Validation
```
The following checks were performed:
- Archive existence verified.
- Archive contents listed successfully.
- gzip -t completed without errors.
- SHA-256 checksum generated.
- Archive extracted into /tmp/minecraft-restore-test.
- Original and restored world directories both reported approximately 18 MB.
- Both world directories contained 39 files.

## 6. Restore Comparison
```bash
Command:
sudo diff -qr /opt/minecraft/world /tmp/minecraft-restore-test/world
```
Seven files differed:
- data/minecraft/weather.dat
- data/minecraft/world_clocks.dat
- dimensions/minecraft/overworld/data/minecraft/raids.dat
- dimensions/minecraft/the_end/data/minecraft/raids.dat
- dimensions/minecraft/the_nether/data/minecraft/raids.dat
- level.dat
- level.dat_old
The remaining 32 files compared without differences.
The exact cause and timing of the seven differences have not
been established. Therefore, exact equivalence of the complete
world backup has not been proven.

## 7. Service Recovery
After the comparison, the Minecraft service was started again.
sudo systemctl start minecraft
sudo systemctl is-active minecraft

Observed result: active

## 8. Limitations and Next Improvements
- The backup archive is stored on the same machine as the Minecraft server.
- Seven world-state files differed during the earlier comparison.
  The exact cause and timing of these differences have not been established.
- The isolated restore test verified that the restored world could start
  successfully, but gameplay and player-data validation remain incomplete.
- Automated local backups, seven-day local retention, and S3 off-device copies are configured in the backup script.
- An S3 off-device backup has been configured and validated; interrupted-backup recovery still requires testing.
- Automatic startup after a system reboot has not been tested.

## 9. Restore Validation (2026-10-16)
- Extracted the backup into `/opt/minecraft-restore-test`.
- Verified that the restored world contained `world/level.dat`.
- Configured the test server to use `127.0.0.1:25566`,
  keeping it separate from the live server on port `25565`.
- Started the restored world using Minecraft Java Edition 26.3.
- The server reached the `Done` state and loaded the restored world.
- Stopped the test server using the `stop` command.
- Confirmed that the test server shut down and saved its worlds.
- Verified that the live Minecraft service remained active
  and listening on port `25565`.
- Confirmed that port `25566` was no longer listening after shutdown.

### Restore Test Limitations
- Gameplay and player-data validation have not been completed.
- The seven differences found during the earlier comparison remain unexplained.
- Exact equivalence between the archived world and the live world
  has not been established.
- The backup remains on the same machine as the server.

## 10. Current Status
The initial backup archive passed gzip integrity verification and
was extracted successfully. The restored world started and shut down
cleanly in isolation. The live server remained active throughout the
final verification. Further work is required to investigate the
world-file differences, automate backups, configure retention,
establish an off-device copy, and test startup after reboot.

## 11. Automated Backup Script — Manual Test (2026-10-16)

### Script
- Script path: `/usr/local/bin/minecraft-backup.sh`
- The script requires root privileges.
- Uses `flock` to prevent overlapping backup runs.
- Gracefully stops Minecraft before archiving the world.
- Includes the world and available server configuration files.
- Verifies the archive with `gzip -t`.
- Generates and verifies a SHA-256 checksum.
- Attempts to restart Minecraft if it was active before the backup.
- Retention cleanup is intentionally disabled during initial testing.

### Test Results
- Executed the script manually on 2026-10-16.
- Minecraft stopped gracefully before backup creation.
- Archive integrity verification passed.
- SHA-256 checksum verification passed.
- The archive and checksum were published successfully.
- Minecraft service restarted successfully and returned to the active state.
- The script reported successful completion.

### Backup Created
`/opt/minecraft/backups/minecraft-backup-2026-10-16_15-35-24.tar.gz`

### Remaining Limitations
- The backup is stored on the same machine as the live server.
- Automatic scheduling has not been configured.
- Retention cleanup remains disabled.
- S3 backup and isolated restore have been validated; production recovery scenarios remain partially untested.
- Gameplay and player-data validation of the restored world remain incomplete.
- Automatic startup after a system reboot has not been tested.

## 12. Backup Retention Policy

### Purpose
The backup script applies a 7-day retention policy to prevent backup storage from growing indefinitely.

### Retention Configuration
- Retention period: 7 days.
- Backup directory: `/opt/minecraft/backups`.
- The script identifies backup archives older than 7 days.
- An archive is deleted only when its matching `.sha256` checksum file exists.
- The archive and its checksum file are removed together.
- Archives without a matching checksum file are preserved and logged as warnings.

### Validation
- The backup script passed the Bash syntax check.
- A new backup was created and its gzip integrity was verified.
- The SHA-256 checksum was generated and verified.
- The 7-day retention policy executed successfully.
- The Minecraft service restarted successfully after the backup.

### Important Notes
- Successful execution of the retention policy does not necessarily mean a backup was deleted.
- The script must be tested periodically to ensure backups remain recoverable.
- At least one verified, recoverable backup should be maintained before relying on automated cleanup.

## 13. Amazon S3 Off-Device Backup and Restore Validation

**Test date:** 2026-10-16
**Status:** Passed — S3 backup and isolated restore validated

### 13.1 Objective

Maintain an off-device copy of Minecraft world data in Amazon S3 so the backup can be recovered if local storage or the Ubuntu host becomes unavailable.

The S3 copy supplements the local backup. The local archive remains available under `/opt/minecraft/backups/`.

### 13.2 AWS Configuration

- **AWS Region:** `us-east-1`
- **S3 bucket:** `gurjyot-minecraft-backups-2026`
- **S3 prefix:** `minecraft-backups/`
- **IAM identity:** `minecraft-s3-backup`
- **Encryption:** S3 default server-side encryption (SSE-S3)
- **Public access:** Blocked
- **Access method:** AWS CLI using the `minecraft-backups` profile

The IAM policy grants bucket listing and object upload/download permissions for the configured bucket. AWS credentials are stored in the Linux user's AWS configuration files and are not committed to this repository.

### 13.3 Backup Script Integration

The script `/usr/local/bin/minecraft-backup.sh` performs these operations:

1. Validates required files, commands, AWS authentication, and bucket access before stopping Minecraft.
2. Stops the Minecraft service gracefully.
3. Creates a timestamped compressed archive of the world and required server configuration/player-management files.
4. Checks gzip archive integrity and generates a SHA-256 checksum.
5. Publishes the verified archive and checksum to local storage.
6. Uploads both objects to Amazon S3.
7. Downloads the remote archive to standard output and independently compares its SHA-256 checksum with the local checksum.
8. Applies the configured seven-day local retention policy.
9. Restarts Minecraft if it was active before the backup.

If the script fails, inspect its output and service state before retrying. A local archive may remain if the S3 upload or remote verification fails.

### 13.4 Successful S3 Backup Test

The following backup was created and uploaded successfully:

- **Archive:** `minecraft-backup-2026-10-16_18-04-51.tar.gz`
- **Local archive:** `/opt/minecraft/backups/minecraft-backup-2026-10-16_18-04-51.tar.gz`
- **S3 archive:** `s3://gurjyot-minecraft-backups-2026/minecraft-backups/minecraft-backup-2026-10-16_18-04-51.tar.gz`
- **S3 checksum:** `s3://gurjyot-minecraft-backups-2026/minecraft-backups/minecraft-backup-2026-10-16_18-04-51.tar.gz.sha256`

The script reported:

- Local gzip integrity check passed.
- Local SHA-256 verification passed.
- Archive and checksum uploads succeeded.
- SHA-256 of the archive downloaded from S3 matched the local archive checksum.
- Minecraft service restarted and returned to the active state.
- Backup process completed successfully.

### 13.5 Independent Download and Restore Test

The S3 archive and checksum were downloaded to:

`~/minecraft-s3-restore-test/`

The archive was saved locally as `minecraft-backup.tar.gz`. Because the downloaded archive used a different filename from the filename embedded in the checksum file, the checksum entry was adjusted for verification without changing the archive or its checksum value.

The checksum command returned:

`minecraft-backup.tar.gz: OK`

The archive was inspected and extracted into an isolated directory, then copied to:

`/opt/minecraft-s3-restore-test/`

The restored directory contained the expected world and configuration files, including:

- `world/`
- `server.properties`
- `eula.txt`
- `whitelist.json`
- `ops.json`
- `banned-players.json`
- `banned-ips.json`

The restored server was configured to bind to `127.0.0.1` on port `25566`, separate from the live server on port `25565`. The restored server started successfully using the existing Minecraft server JAR.

The test server was stopped, and no listener remained on port `25566`. The original Minecraft service was confirmed active during the test.

### 13.6 Result and Limitations

**Result: Passed.** The off-device backup was uploaded, downloaded, checksum-verified, extracted, and successfully started in an isolated test environment.

This validates the backup's integrity and demonstrates that the restored world can start. It does not prove that every possible recovery scenario has been tested.

A reboot-based startup test has not yet been performed. AWS access keys must remain outside Git, and the S3 bucket should remain private.

### 13.7 Recovery Procedure Summary

1. Prepare a trusted Linux host with a compatible Java runtime and Minecraft server version.
2. Download the required archive and checksum from the private S3 bucket using authorized AWS credentials.
3. Verify the downloaded archive's SHA-256 checksum before extraction.
4. Inspect and extract the archive into a separate recovery directory.
5. Verify configuration, ownership, and permissions.
6. Test startup in an isolated environment using a separate port.
7. Only after validation, plan any production recovery into the live server directory.
8. Confirm service health and retain the original backup until recovery is verified.

Never extract a recovery archive directly over a running live world.

## 14. Phase 5 Task 3 — Backup Automation Integration

### Objective

Validate the existing Minecraft backup workflow without unnecessarily
interrupting the live Minecraft service.

### Existing implementation

The backup script at `/usr/local/bin/minecraft-backup.sh`:

- Checks AWS authentication and S3 bucket access before stopping Minecraft.
- Uses a lock to prevent overlapping backup executions.
- Stops the Minecraft service gracefully before archiving the world.
- Creates and validates a compressed backup archive.
- Generates and verifies a SHA-256 checksum.
- Uploads the archive and checksum to Amazon S3.
- Independently verifies the uploaded archive checksum.
- Applies a seven-day local retention policy.
- Attempts to restart Minecraft if it was active before backup execution.

### Previously completed validation

- Local backup archive integrity verified.
- Local SHA-256 checksum verified.
- S3 backup uploaded successfully.
- Remote archive checksum matched the local archive.
- S3 archive downloaded, checksum-verified, and extracted.
- Isolated restored server started successfully on port 25566.

### Remaining limitations

- Production backup interruption and service recovery remain unverified.
- Scheduled backup execution is not yet configured.
- A successful backup does not guarantee every possible recovery scenario.
