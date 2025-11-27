#!/usr/bin/env bash
# File: setup-smb-mounts.sh
# Dedicated script for Synology (or any) CIFS/SMB mounts – perfect for Raspberry Pi
# Usage examples:
#   ./setup-smb-mounts.sh //ds923.local/gitea/db   /gitea/db   "uid=999,gid=999,file_mode=0700,dir_mode=0700"
#   ./setup-smb-mounts.sh //ds923.local/gitea/data /gitea/data "uid=1001,gid=1001,file_mode=0775,dir_mode=0775"

set -euo pipefail

SERVER_SHARE="$1"     # e.g. //ds923.local/gitea/db
MOUNT_POINT="$2"      # e.g. /gitea/db
USER_OPTS="$3"        # everything after credentials=… (you can omit credentials if you put it here)

# Default options most people want on Synology ↔ Raspberry Pi
[ -f /root/.smbcredentials ] || { read -p "SMB Username: " u; read -s -p "SMB Password: " p; echo; sudo bash -c "echo -e \"username=$u\npassword=$p\" > /root/.smbcredentials && chmod 600 /root/.smbcredentials"; echo "Created /root/.smbcredentials"; }
DEFAULT_OPTS="credentials=/root/.smbcredentials,iocharset=utf8,nounix,vers=3.0,noexec,nodev"

# Combine defaults + user overrides
if [[ -n "${USER_OPTS:-}" ]]; then
    FINAL_OPTS="${DEFAULT_OPTS},${USER_OPTS}"
else
    FINAL_OPTS="${DEFAULT_OPTS}"
fi

echo "Setting up SMB mount: $SERVER_SHARE → $MOUNT_POINT"
echo "Options: $FINAL_OPTS"

# Install cifs-utils if missing (works on Raspberry Pi OS, Ubuntu, Debian…)
if ! command -v mount.cifs >/dev/null 2>&1; then
    echo "Installing cifs-utils…"
    sudo apt-get update && sudo apt-get install -y cifs-utils
fi

# Create mount point
sudo mkdir -p "$MOUNT_POINT"

# Remove any old identical line (idempotency)
sudo sed -i "\|^$SERVER_SHARE[[:space:]]\+$MOUNT_POINT[[:space:]]\+cifs[[:space:]]|d" /etc/fstab 2>/dev/null || true

# Add new line
printf '%s\t%s\tcifs\t%s\t0 0\n' "$SERVER_SHARE" "$MOUNT_POINT" "$FINAL_OPTS" \
    | sudo tee -a /etc/fstab > /dev/null

echo "Added/updated fstab entry"

# Reload systemd and mount
sudo systemctl daemon-reload
sudo mount -a

echo "Done!"
df -hT "$MOUNT_POINT"
mount | grep "$MOUNT_POINT"