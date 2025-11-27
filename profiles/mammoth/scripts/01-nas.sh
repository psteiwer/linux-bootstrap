#!/usr/bin/env bash
set -euo pipefail

mkdir -p /gitea/db
SERVER_SHARE="//ds923.local/gitea/db"
MOUNT_POINT="/gitea/db"
USER_OPTS="uid=999,gid=999,file_mode=0700,dir_mode=0700"        # everything after credentials=… (you can omit credentials if you put it here)
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-smb-mounts.sh" "$SERVER_SHARE" "$MOUNT_POINT" "$USER_OPTS"

mkdir -p /gitea/data
SERVER_SHARE="//ds923.local/gitea/data"
MOUNT_POINT="/gitea/data"
USER_OPTS="uid=1001,gid=1001,file_mode=0775,dir_mode=0775"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-smb-mounts.sh" "$SERVER_SHARE" "$MOUNT_POINT" "$USER_OPTS"

mkdir -p /network/TransactionDataBackup
SERVER_SHARE="//ds923.local/backups/Apps/TransactionData"
MOUNT_POINT="/network/TransactionDataBackup"
USER_OPTS="uid=999,file_mode=0700,dir_mode=0700"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-smb-mounts.sh" "$SERVER_SHARE" "$MOUNT_POINT" "$USER_OPTS"


# #//ds923.local/services/ddnsupdate/logs /services/ddnsupdate/logs cifs credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0600,dir_mode=0700 0 0