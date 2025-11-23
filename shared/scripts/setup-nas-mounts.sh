#!/usr/bin/env bash
# File: setup-nas-mounts.sh
# Drop this in your bootstrap repo – it replaces every previous script
# Usage from any machine's bootstrap profile:
#
#   ./setup-nas-mounts.sh nas.lan /homes/alice        /nethome  "Documents Downloads Projects"
#   ./setup-nas-mounts.sh nas.lan /volume1/media      /mnt/media
#   ./setup-nas-mounts.sh nas.lan /volume1/backups    /mnt/backups
#   ./setup-nas-mounts.sh nas.lan /homes/pi           /nethome  "Documents Music Videos"   # Raspberry Pi example

set -euo pipefail

NAS_HOST="$1"                  # e.g. nas.lan
REMOTE_PATH="$2"               # e.g. /homes/alice  or  /volume1/media
MOUNT_POINT="$3"               # e.g. /nethome      or  /mnt/media
BIND_FOLDERS="${4:-}"         # optional space-separated list, e.g. "Documents Projects Photos"

NFS_OPTS="defaults,noatime,vers=3,_netdev,rsize=1048576,wsize=1048576,hard,intr,timeo=600,retrans=2"

echo "Setting up NAS mount → $NAS_HOST:$REMOTE_PATH → $MOUNT_POINT"

# Create mount point
sudo mkdir -p "$MOUNT_POINT"

# ── Main NFS mount (uses printf + tab for perfect fstab formatting) ──
if ! grep -q "^$NAS_HOST:$REMOTE_PATH[[:space:]]" /etc/fstab; then
    printf '%s\t%s\t%s\t%s\t0 0\n' \
           "$NAS_HOST:$REMOTE_PATH" "$MOUNT_POINT" "nfs" "$NFS_OPTS" \
           | sudo tee -a /etc/fstab > /dev/null
    echo "Added NFS mount to fstab"
else
    echo "NFS line already exists"
fi

# ── Bind folders into real home ──
if [[ -n "$BIND_FOLDERS" ]]; then
    USER_HOME="/home/$(whoami)"
    for folder in $BIND_FOLDERS; do
        src="$MOUNT_POINT/$folder"
        dst="$USER_HOME/$folder"
        sudo mkdir -p "$src"
        mkdir -p "$dst"
        if ! grep -q "$(printf '%s\t%s' "$src" "$dst")" /etc/fstab; then
            printf '%s\t%s\tnone\tbind,defaults\t0 0\n' "$src" "$dst" \
                | sudo tee -a /etc/fstab > /dev/null
            echo "Bound ~/$folder"
        fi
    done
fi

# Mount everything now
sudo mount -a

echo "Done! Mounted $MOUNT_POINT"
[[ -n "$BIND_FOLDERS" ]] && echo "Bound folders: $BIND_FOLDERS"
df -h "$MOUNT_POINT"