#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$ROOT/shared/scripts/pihole-install.sh"
