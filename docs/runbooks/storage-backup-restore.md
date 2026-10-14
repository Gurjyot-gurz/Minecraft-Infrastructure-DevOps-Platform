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
- The archive was stored on the same machine as the Minecraft server.
- A successful extraction does not prove that a Minecraft world
  can be loaded successfully from the restored copy.
- A full restoration test has not been performed.
- Automated backups and retention policies are not yet configured.
- An off-device backup has not been configured.
- Automatic startup after a system reboot has not been tested.

## 9. Current Status
Initial backup created, archive integrity checked, and isolated
extraction completed. Partial file comparison passed; seven
world-state files differed. Further recovery validation is required.
