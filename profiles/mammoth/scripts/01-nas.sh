#!/usr/bin/env bash
set -euo pipefail

mkdir -p /gitea/db
NAS_HOST="ds923.local"
REMOTE_PATH="/volume1/gitea/db"
MOUNT_POINT="/gitea/db"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-nfs-mounts.sh" "$NAS_HOST" "$REMOTE_PATH" "$MOUNT_POINT"


mkdir -p /gitea/data
NAS_HOST="ds923.local"
REMOTE_PATH="/volume1/gitea/db"
MOUNT_POINT="/gitea/db"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-nfs-mounts.sh" "$NAS_HOST" "$REMOTE_PATH" "$MOUNT_POINT"

mkdir -p /network/TransactionDataBackup
NAS_HOST="ds923.local"
REMOTE_PATH="/volume1/backups/Apps/TransactionData"
MOUNT_POINT="/network/TransactionDataBackup"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-nfs-mounts.sh" "$NAS_HOST" "$REMOTE_PATH" "$MOUNT_POINT"


# #//ds923.local/services/ddnsupdate/logs /services/ddnsupdate/logs cifs credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0600,dir_mode=0700 0 0