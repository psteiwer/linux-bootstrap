#!/usr/bin/env bash
set -euo pipefail
NAS_HOST="ds923.local"
REMOTE_PATH="/volume1/homes/peter"
MOUNT_POINT="/nethome/peter"
BIND_FOLDERS="Documents Pictures Videos Photos Music"
bash "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../shared/scripts/setup-nas-mounts.sh" "$NAS_HOST" "$REMOTE_PATH" "$MOUNT_POINT" "$BIND_FOLDERS"
