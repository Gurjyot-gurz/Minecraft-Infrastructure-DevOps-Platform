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

## 4. Backup Artifact
- Archive: minecraft-backup-2026-10-14_12-15-23.tar.gz
- Location: /opt/minecraft/backups/
- Size: approximately 9.9 MB
- SHA-256:
  41bc05b97758363b623c5e116d35cac427dde5fba4691cd40338d29ed70ca4ad

## 5. Validation
The following checks were performed:
- Archive existence verified.
- Archive contents listed successfully.
- gzip -t completed without errors.
- SHA-256 checksum generated.
- Archive extracted into /tmp/minecraft-restore-test.
- Original and restored world directories both reported approximately 18 MB.
- Both world directories contained 39 files.

## 6. Restore Comparison
Command:
sudo diff -qr /opt/minecraft/world /tmp/minecraft-restore-test/world

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
- Automated backups and retention policies are not yet configured.
- An off-device backup has not been configured.
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
