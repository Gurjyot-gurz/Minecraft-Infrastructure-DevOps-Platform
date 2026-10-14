# Minecraft LAN Connectivity and Troubleshooting

## 1. Purpose

This document records the LAN configuration, connectivity tests, Minecraft authentication issues, whitelist troubleshooting, and
successful client connection for the Minecraft Infrastructure
& DevOps Platform project.

The objective is to understand and document the complete path
from a Windows Minecraft client to a Minecraft server running
on Ubuntu.

Project learning cycle:

Learn → Apply → Break → Fix → Document


## 2. Infrastructure Overview

### Minecraft Server

- Operating system: Ubuntu Linux
- Hostname: gurjyot-linux
- Server software: Minecraft Java Edition
- Minecraft version: 26.3
- Java runtime: Oracle Java 25.0.4.1 LTS
- Server directory: /opt/minecraft
- Server JAR: /opt/minecraft/server.jar
- Server configuration: /opt/minecraft/server.properties
- World directory: /opt/minecraft/world
- Service manager: systemd
- Service name: minecraft.service
- Server port: TCP 25565

### Windows Client

- Operating system: Windows 11
- Minecraft version: 26.3
- Launcher: TLauncher
- Client LAN IPv4 address: 192.168.1.3

### LAN Network

- Ubuntu server IPv4 address: 192.168.1.12
- Windows client IPv4 address: 192.168.1.3
- Router IPv4 address: 192.168.1.1
- Subnet mask: 255.255.255.0
- LAN subnet: 192.168.1.0/24

### Minecraft Server Address

192.168.1.12:25565


## 3. Architecture and Connection Flow

Windows Minecraft Client
        |
        | TCP connection to 192.168.1.12:25565
        |
        v
Ubuntu Firewall (UFW)
        |
        | Allow TCP 25565 from 192.168.1.0/24
        |
        v
Minecraft Java Server
        |
        | Managed by systemd
        |
        v
Minecraft World

The Windows client and Ubuntu server communicate over the
local network.

The router is not configured to forward Minecraft traffic
from the public Internet.


## 4. Firewall Configuration

UFW is enabled on the Ubuntu server.

The Minecraft firewall rule is restricted to the local LAN:

sudo ufw allow from 192.168.1.0/24 to any port 25565 proto tcp

The rule allows TCP connections to port 25565 from devices
within the configured LAN subnet.

### Connectivity Test

Command executed in Windows PowerShell:

Test-NetConnection 192.168.1.12 -Port 25565

Observed result:

- RemoteAddress: 192.168.1.12
- RemotePort: 25565
- InterfaceAlias: WiFi
- SourceAddress: 192.168.1.3
- TcpTestSucceeded: True

Result: TCP connectivity succeeded.

Important distinction:

A successful TCP test confirms network-level reachability.
It does not guarantee that Minecraft authentication,
whitelist checks, or gameplay will succeed.


## 5. Minecraft Server Configuration

Relevant settings in server.properties:

online-mode=false
white-list=true
enforce-whitelist=false
server-ip=
server-port=25565

### Configuration Explanation

#### online-mode=false

The server does not authenticate player identities through
the normal official Minecraft authentication process.

This configuration was used for private LAN testing with
the available launcher.

Security warning:

Offline mode permits username impersonation. A client may
attempt to connect using another player's username.

The server must remain restricted to trusted LAN devices.
Public router port forwarding must not be enabled.

#### white-list=true

The whitelist is enabled. New players must satisfy the
server's whitelist check.

#### enforce-whitelist=false

This setting controls whether players who are already online
are forcibly disconnected when whitelist enforcement is
reloaded or changed.

It does not disable the whitelist for new connections.

#### server-ip=

The value is intentionally blank so the server can bind
to its available network interfaces.

#### server-port=25565

The server listens for Minecraft Java Edition connections
on TCP port 25565.


## 6. Incident 1 — Authentication Failure

### Symptoms

The initial client attempted to connect using:

Gurz_Singh

The client displayed:

Failed to verify username!

The server log reported:

Username 'Gurz_Singh' tried to join with an invalid session

### Initial Configuration

online-mode=true

### Investigation

The server was configured to use normal online authentication.

The available TLauncher session did not provide a valid
authenticated Minecraft session to the server.

### Resolution

For private LAN testing, online-mode was changed to false.

The server subsequently logged:

SERVER IS RUNNING IN OFFLINE/INSECURE MODE!

This confirmed that online authentication was disabled.

### Security Impact

Offline mode does not verify player identities through
official Minecraft account authentication.

The configuration introduces username impersonation risk.

### Status

- [x] Initial authentication failure observed.
- [x] Invalid session message recorded.
- [x] Offline-mode configuration verified in server logs.
- [x] Server started successfully with offline mode.
- [x] Minecraft client subsequently connected successfully.


## 7. Incident 2 — Whitelist Rejection

### Symptoms

The Minecraft client displayed:

You are not white-listed on this server!

The server log reported:

Disconnecting Gurz_Singh (/192.168.1.3:55847):
You are not white-listed on this server!

The log also contained:

Gurz_Singh (/192.168.1.3:55847) lost connection:
You are not white-listed on this server!

### Understanding the Log Entry

Gurz_Singh
    Username presented by the client.

192.168.1.3
    Windows client's local IPv4 address.

55847
    Temporary TCP source port selected for that connection.

The source port is not the Minecraft server port.

### Initial Whitelist State

The whitelist was enabled:

white-list=true

The whitelist file initially contained:

[]

This meant that no players were listed.

### First Whitelist Entry

The command entered in the Minecraft server console was:

whitelist add Gurz_Singh

The server confirmed:

Added gurz_singh to the whitelist

The resulting entry was:

{
  "uuid": "61430ecb-7119-339d-bad0-8cc3d0cba6fd",
  "name": "gurz_singh"
}

The same username and UUID were observed in usercache.json.

### Second Whitelist Entry

A new TLauncher username was created:

gamerzskinggurz

The command entered in the temporary server console was:

whitelist add gamerzskinggurz

The server logged a profile lookup warning:

Couldn't find profile with name: gamerzskinggurz

The official profile lookup returned HTTP 404.

The server subsequently reported:

Added gamerzskinggurz to the whitelist

The saved entry was:

{
  "uuid": "8d00d145-45f6-337d-844a-4b19d759914c",
  "name": "gamerzskinggurz"
}

The same username and UUID were observed in usercache.json.

### Interpretation

The profile lookup warning showed that the official profile
service could not find the new username.

Minecraft nevertheless generated and saved an offline-mode
UUID and added the username to the whitelist.

The warning alone did not prove that the whitelist entry
was invalid.

### Server Restart

The temporary interactive server was stopped gracefully.

The normal systemd service was then started using:

sudo systemctl start minecraft

The server logs showed successful startup.

### Final Result

The client successfully joined the Minecraft world using
the new lowercase TLauncher username.

This confirms that the client was able to connect and play
after the configuration and whitelist changes.

The successful connection is the final verification for
this incident.


## 8. Whitelist and Player Identity Files

### whitelist.json

Location:

/opt/minecraft/whitelist.json

Purpose:

Stores player identities allowed by the whitelist.

### usercache.json

Location:

/opt/minecraft/usercache.json

Purpose:

Caches username-to-UUID mappings.

### banned-players.json

Location:

/opt/minecraft/banned-players.json

Purpose:

Stores banned player profiles.

Observed during troubleshooting:

[]

### banned-ips.json

Location:

/opt/minecraft/banned-ips.json

Purpose:

Stores banned IP addresses.

Observed during troubleshooting:

[]

### Important Distinction

The whitelist and user cache contained both usernames.

The successful client connection confirms that the final
configuration allowed the tested client to join.

No further JSON modifications are required at this time.


## 9. Verification Commands

### Check the systemd service

sudo systemctl status minecraft --no-pager

Expected result when running:

Active: active (running)

### Check the Java process

pgrep -a -u minecraft java

This verifies whether Java is running under the dedicated
minecraft service account.

### Check the listening port

sudo ss -ltnp | grep ':25565'

This checks whether a process is listening on TCP port 25565.

### Inspect recent server logs

sudo journalctl -u minecraft -n 50 --no-pager

### Inspect logs from recent activity

sudo journalctl -u minecraft --since "10 minutes ago" --no-pager

### Check the whitelist

sudo cat /opt/minecraft/whitelist.json

### Check the server configuration

sudo grep -E '^(online-mode|white-list|enforce-whitelist|server-port)=' /opt/minecraft/server.properties

### Check the firewall

sudo ufw status numbered


## 10. Final Verification Checklist

- [x] Ubuntu Minecraft server deployed.
- [x] Server managed by systemd.
- [x] Minecraft server version 26.3 started successfully.
- [x] TCP port 25565 listening.
- [x] UFW firewall enabled.
- [x] Minecraft access restricted to the trusted LAN subnet.
- [x] Windows-to-Ubuntu TCP connectivity test passed.
- [x] Initial online authentication failure documented.
- [x] Whitelist rejection documented.
- [x] Whitelist entries saved.
- [x] Official profile lookup warning documented.
- [x] Server restarted through systemd.
- [x] Windows Minecraft client successfully joined the world.
- [ ] Automatic startup after an actual system reboot tested.
- [ ] Backup and restore procedure tested.
- [ ] Monitoring and alerting implemented.


## 11. Lessons Learned

1. TCP connectivity and Minecraft application-level connectivity
   are different tests.

2. A server can be running correctly while rejecting clients
   during authentication or whitelist checks.

3. Online authentication and whitelist enforcement are separate
   mechanisms.

4. The username and UUID saved by the server are important
   when troubleshooting player identity.

5. Offline mode introduces username impersonation risk.

6. A profile lookup warning must be interpreted alongside
   the saved files and the actual connection result.

7. Graceful shutdown allows Minecraft to save world data
   before configuration-related maintenance.

8. systemd provides a consistent way to start, stop, and
   inspect the server.

9. Incident reports should distinguish observed errors,
   attempted fixes, verified results, and outstanding work.

10. Every significant configuration change and troubleshooting
    incident should be documented.


## 12. Current Project Status

Minecraft Java Edition 26.3 is deployed on Ubuntu and
managed through systemd.

The Windows client has successfully joined the server over
the local network.

The current configuration uses offline mode and a whitelist.
The firewall restricts Minecraft TCP access to the trusted
LAN subnet.

The next project stages are:

1. Test automatic startup after reboot.
2. Design and test world backups.
3. Test world restoration.
4. Implement health checks and monitoring.
5. Document operational runbooks.
