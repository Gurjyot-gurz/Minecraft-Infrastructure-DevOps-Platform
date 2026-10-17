# Minecraft Infrastructure & DevOps Platform

A hands-on infrastructure and operations project built around a native Minecraft Java server on Ubuntu Linux. The goal is to practice the real work behind running an application: Linux administration, service management, LAN networking, backups, recovery, and operational automation.

> **Current progress:** Phases 1–5 are documented as in progress/completed according to the work performed so far. Production backup interruption-and-recovery testing remains a known follow-up. Monitoring, containers, CI/CD, Kubernetes, and cloud infrastructure expansion are future phases—not claimed as completed here.

## Project highlights

- Deployed a native Minecraft Java Edition server on Ubuntu Linux.
- Runs the server as a dedicated, unprivileged `minecraft` Linux account under `systemd`.
- Configured SSH access and LAN-only Minecraft access through TCP port `25565` using UFW.
- Created a backup workflow that stops the service gracefully, archives world/configuration data, validates the archive, uploads it to private Amazon S3, and verifies the remote checksum.
- Performed an isolated restore test from an S3 backup.
- Built Bash health checks for service status, TCP port availability, and disk usage.
- Scheduled the health check with a `systemd` timer and verified successful scheduled execution.
- Added error-handling and signal-handling test scripts.

## Architecture

```text
                     LAN client
                         |
                  TCP 25565 / Java
                         |
                 Ubuntu Linux host
                         |
                  UFW firewall rules
                         |
                systemd: minecraft.service
                         |
                Minecraft Java server
                         |
                  World + configuration
                         |
              Backup script / validation
                         |
                 Private Amazon S3
```

The Minecraft port is intended for the local network only. This project does not require exposing the server publicly.

<!--
After adding your own architecture image, replace the diagram above or add:
![Project architecture](docs/screenshots/architecture/project-architecture.png)
-->

## Technology stack

| Area | Technologies |
|---|---|
| Operating system | Ubuntu Linux |
| Application | Minecraft Java Edition server |
| Runtime | Java |
| Service management | systemd, journalctl |
| Networking and security | TCP/IP, SSH, UFW, LAN-only access |
| Scripting and automation | Bash, shell exit codes, signal/exit cleanup |
| Health checks | Service status, TCP port check, disk usage threshold |
| Backup and recovery | tar archive, SHA-256 checksums, isolated restore test |
| Cloud storage | Amazon S3, AWS CLI, IAM least-privilege policy |
| Scheduling | systemd service and timer |
| Version control | Git, GitHub |

## Progress by phase

| Phase | Focus | Current status |
|---|---|---|
| 1 | Linux administration, users, groups, permissions, processes, SSH and service basics | Completed for the current lab scope |
| 2 | Native Minecraft deployment and systemd service | Deployed and running |
| 3 | LAN connectivity, TCP port `25565`, routing basics and UFW firewall rules | Configured and tested on the LAN |
| 4 | Local/S3 backups, archive and checksum validation, isolated restore | Backup and isolated restore test completed; interruption/recovery testing remains |
| 5 | Bash health checks, error handling, signal cleanup and scheduled health checks | Core checks and scheduled execution validated |
| 6 | Monitoring and observability | Planned |
| 7 | Incident simulation and response runbooks | Planned |
| 8 | Docker containerization | Planned |
| 9 | Kubernetes experiments | Planned |
| 10 | CI/CD | Planned |
| 11 | AWS infrastructure expansion and Infrastructure as Code | Planned |

Only the work listed as completed or validated above should be treated as implemented. Future phases will be updated as they are built and tested.

## Health checks and automation

The health-check script checks:

1. Whether the Minecraft systemd service is active.
2. Whether TCP port `25565` is listening.
3. Whether disk usage remains below the configured threshold.

The script returns a successful exit code when all checks pass and a non-zero exit code when a check fails. A `systemd` oneshot service and timer run the installed health-check script automatically.

Project scripts currently include:

- `scripts/health-check.sh`
- `scripts/error-handling-demo.sh`
- `scripts/failure-test.sh`
- `scripts/signal-handling-test.sh`

The production backup script is installed at `/usr/local/bin/minecraft-backup.sh`; it is not stored in the repository by default. Do not commit AWS credentials, secret values, or private configuration files.

## Backup and recovery

The backup workflow is designed to:

- Check AWS access before stopping the Minecraft service.
- Stop the server gracefully before archiving data.
- Include the world and relevant server configuration/administration files.
- Validate the archive and generate a SHA-256 checksum.
- Upload the archive and checksum to a private S3 bucket.
- Verify the remote archive checksum independently.
- Apply local backup retention and restore the Minecraft service during cleanup.

An isolated restore test from S3 was completed. **Production backup interruption/recovery has not yet been fully tested**, so that remains a follow-up before relying on scheduled production backups.

## Repository structure

```text
.
├── docs/
│   ├── architecture/
│   ├── networking/
│   ├── runbooks/
│   └── screenshots/
│       ├── phase-1-linux/
│       ├── phase-2-minecraft-deployment/
│       ├── phase-3-networking/
│       ├── phase-4-storage-backup-restore/
│       └── phase-5-automation/
├── scripts/
│   ├── health-check.sh
│   ├── error-handling-demo.sh
│   ├── failure-test.sh
│   └── signal-handling-test.sh
└── README.md
```

This is the intended documentation layout; keep paths aligned with the files that actually exist in the repository.

## Screenshots and evidence

Keep the README focused on a few high-value images:

1. Overall project architecture.
2. Minecraft service active or a successful client connection.
3. Passing automated health check.
4. S3 backup/restore checksum verification.

Put detailed step-by-step screenshots in `docs/screenshots/`, grouped by phase. Before committing screenshots, inspect them for credentials, access keys, tokens, secret values, personal information, and unnecessary AWS account details. Redact sensitive values rather than relying on the repository being obscure.

<!-- Uncomment each image only after adding the matching screenshot file.
![Project architecture](docs/screenshots/architecture/project-architecture.png)
![Minecraft service active](docs/screenshots/phase-2-minecraft-deployment/minecraft-service-active.png)
![Health check passing](docs/screenshots/phase-5-automation/health-check-pass.png)
![S3 backup and restore verified](docs/screenshots/phase-4-storage-backup-restore/s3-backup-restore-verified.png)
-->

## Security notes

- Keep AWS credentials outside the repository.
- Do not commit `.aws/credentials`, private keys, tokens, or secrets.
- Keep the S3 bucket private and use least-privilege IAM permissions.
- Keep Minecraft access restricted to the intended LAN unless a separately reviewed secure public-access design is implemented.
- The current server configuration uses `online-mode=false`. This is not appropriate for an exposed public server because usernames can be impersonated; do not expose it to the internet in this configuration.

## Next steps

- Complete and document production backup interruption/recovery tests.
- Review and consolidate the runbooks so they match the current implementation.
- Continue to Phase 6: monitoring and observability.
- Add new screenshots and update the phase table as each task is implemented and verified.

---

This is a learning project focused on building and documenting practical infrastructure and DevOps skills through a real, stateful application.
