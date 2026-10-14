# Minecraft Service Account

## 1. Objective

Run the Minecraft server under a dedicated Linux service account instead
of running it as root or using the administrator's personal account.

This follows the principle of least privilege: the server should operate
with only the permissions it needs.

## 2. Account Details

| Property | Value |
|---|---|
| Username | minecraft |
| User ID (UID) | 112 |
| Primary Group | minecraft |
| Group ID (GID) | 115 |
| Home/Application Directory | /opt/minecraft |
| Login Shell | /usr/sbin/nologin |
| Account Type | System account |

Note: UID and GID values are specific to this machine and may differ
on another Linux installation.

## 3. Why Use a Dedicated Service Account?

- Isolation: Minecraft runs separately from the administrator's account.
- Least privilege: the server does not need root privileges to run.
- Reduced impact: a compromised server process has fewer permissions
  than a process running as root.
- Ownership: Minecraft files can be managed by the minecraft account.
- Service management: systemd can run the server under this account.

## 4. Account Creation

Command used:

```bash
sudo adduser --system --group --home /opt/minecraft \
  --shell /usr/sbin/nologin minecraft
```

Explanation:

- `sudo`: performs the administrative operation.
- `adduser`: creates a Linux user.
- `--system`: creates a system account for a service.
- `--group`: creates a group with the same name.
- `--home /opt/minecraft`: assigns the application directory as its home.
- `--shell /usr/sbin/nologin`: prevents normal interactive login.
- `minecraft`: the account name.

## 5. Directory Ownership and Permissions

Current directory permissions:

```text
drwxr-x--- minecraft minecraft /opt/minecraft
drwxr-xr-x minecraft minecraft /opt/minecraft/backups
drwxr-xr-x minecraft minecraft /opt/minecraft/logs
```

Interpretation of `/opt/minecraft` permissions:

- Owner (`minecraft`): read, write, and enter the directory.
- Group (`minecraft`): read and enter the directory.
- Others: no access.

The `logs` and `backups` directories currently have `755` permissions.
We will review whether these permissions should be tightened as the
project develops.

The administrator uses `sudo` to inspect or manage protected application
files when necessary. Do not use `chmod 777` to work around permissions.

## 6. Verification

### Account and Directory Verification

Commands used:

```bash
id minecraft
getent passwd minecraft
sudo ls -ld /opt/minecraft /opt/minecraft/logs /opt/minecraft/backups
sudo -u minecraft ls -la /opt/minecraft
```

Results:

- Dedicated `minecraft` system account exists.
- Application directory ownership was verified.
- Logs and backups directories were created.
- The service account can access its application directory.

### Java Verification

Commands used:

```bash
java -version
sudo -u minecraft java -version
```

Observed Java version:

```text
Java version: 25.0.4.1 LTS
Runtime: Java(TM) SE Runtime Environment
Architecture: 64-Bit Server VM
```

Both the administrator and the `minecraft` service account can run Java 25.

### Minecraft Server JAR Verification

Download command:

```bash
sudo -u minecraft wget -O /opt/minecraft/server.jar \
  https://piston-data.mojang.com/v1/objects/33680f5f2ac32864d6d7cf5e56a705fdb3e05f4c/server.jar
```

Verified properties:

- Download source: Mojang-hosted server JAR URL.
- File location: `/opt/minecraft/server.jar`.
- Downloaded size: approximately 59.41 MB.
- Owner and group: `minecraft:minecraft`.
- The JAR is readable by the `minecraft` service account.
- File identification: ZIP archive data, consistent with a Java archive container.

### Minecraft Version Verification

Command attempted:

```bash
sudo -u minecraft java -jar /opt/minecraft/server.jar --version
```

The JAR unpacked its libraries and identified its bundled server version as `26.3`.

The command then exited with:

```text
joptsimple.UnrecognizedOptionException:
version is not a recognized option
```

Interpretation:

- Minecraft 26.3 was identified from the JAR's unpacking output.
- The `--version` option is unsupported by this server.
- Java successfully executed the server launcher.
- This attempt does not count as a successful server startup.

## 7. Security Notes

- Do not run the Minecraft server as root.
- Do not grant broad permissions such as `777` to application files.
- Keep server configuration and world data out of public Git repositories.
- Review permissions before storing credentials or other sensitive data.
- Verify that the service account can read the server JAR and write the
  files it needs when the server is deployed.

## 8. Current Status

### Linux Service Account and Environment

- [x] Dedicated system account created.
- [x] Non-interactive shell configured.
- [x] Application directory ownership verified.
- [x] Logs and backups directories created.
- [x] Java 25 verified under the service account.

### Minecraft Server Deployment

- [x] Minecraft server JAR downloaded and readability verified.
- [x] Minecraft 26.3 identified from the JAR's output.
- [x] Minecraft EULA acceptance recorded.
- [x] Initial world generated.
- [x] Manual server launch completed successfully.
- [x] Manual server shutdown completed gracefully.
- [x] World data saved during shutdown.

### systemd Service Configuration

- [x] Service file created at `/etc/systemd/system/minecraft.service`.
- [x] Service configuration checked using `systemd-analyze verify`.
- [x] systemd service started successfully.
- [x] Service status verified.
- [x] Automatic startup enabled and verified.
