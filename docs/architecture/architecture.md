# Minecraft Infrastructure & DevOps Platform

## 1. Project Objective

Build and operate a Minecraft Java Edition server on Ubuntu Linux while
practising Linux administration, networking, security, automation,
monitoring, troubleshooting, and deployment.

## 2. Initial Infrastructure

### Server Host

- Operating System: Ubuntu Linux
- Hostname: gurjyot-linux
- Administrator Account: gurjyot-linux
- Minecraft Service Account: minecraft
- Minecraft Directory: /opt/minecraft
- Java Runtime: Java 25
- Firewall: UFW
- Remote Administration: OpenSSH

### Client

- Operating System: Windows 11
- Device: Gaming desktop
- Purpose: Minecraft client and remote SSH administration

## 3. Initial Architecture

Windows Gaming Desktop
        |
        | SSH (TCP 22)
        v
Ubuntu Laptop
        |
        +-- OpenSSH Server
        |
        +-- UFW Firewall
        |
        +-- Java 25
        |
        +-- Minecraft Server
                |
                +-- Process Manager: systemd (active and running)
                +-- Server Version: 26.3
                +-- Java Runtime: 25.0.4.1 LTS
                +-- Server JAR: /opt/minecraft/server.jar
                +-- Working Directory: /opt/minecraft
                +-- World Data: /opt/minecraft/world
                +-- Configuration: /opt/minecraft/server.properties
                +-- Logs Directory: /opt/minecraft/logs
                +-- Backups Directory: /opt/minecraft/backups
                +-- Listening Port: TCP 25565 (configured by Minecraft)

## 4. Minecraft systemd Service

Service file:

`/etc/systemd/system/minecraft.service`

Configured service properties:

| Property | Value |
|---|---|
| Service name | `minecraft.service` |
| Service account | `minecraft` |
| Primary group | `minecraft` |
| Working directory | `/opt/minecraft` |
| Java executable | `/usr/bin/java` |
| Initial heap | 1 GB |
| Maximum heap | 3 GB |
| Restart policy | `on-failure` |
| Restart delay | 10 seconds |
| Stop timeout | 120 seconds |

The service configuration was checked using `systemd-analyze verify`.
The service has not yet been started or tested through systemd.

## 5. Security Principles

- Run Minecraft under a dedicated, non-root service account.
- Use SSH for remote administration.
- Keep incoming firewall access restricted to required services.
- Keep world data and sensitive configuration out of Git.
- Introduce additional network exposure only when necessary.

## 6. Planned Development Stages

1. Prepare Ubuntu and Linux service accounts.
2. Deploy the native Minecraft server.
3. Manage the server with systemd.
4. Configure and test network connectivity.
5. Implement backups and recovery procedures.
6. Automate routine operations with Bash.
7. Introduce monitoring and incident response.
8. Containerize the server with Docker.
9. Explore Kubernetes where useful.
10. Implement CI/CD with GitHub Actions.
11. Explore AWS deployment and infrastructure automation.

## Current Status

- [x] Ubuntu prepared with administration tools.
- [x] UFW enabled with SSH access allowed.
- [x] Dedicated Minecraft service account created.
- [x] Project directory structure created.
- [x] Architecture documentation created.
- [x] Java 25 verified under the Minecraft service account.
- [x] Minecraft Java Edition 26.3 downloaded.
- [x] EULA acceptance recorded.
- [x] Minecraft launched successfully in manual mode.
- [x] Initial world generated and saved during shutdown.
- [x] systemd service file created and verified.
- [x] Minecraft service started and verified through systemd.
- [ ] Automatic startup enabled and tested.
- [ ] LAN connectivity tested from the Windows desktop.
- [ ] Backups and recovery procedures tested.
- [ ] Monitoring and incident response configured.
