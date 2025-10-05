#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PKG_DIR="$(dirname "$0")/../packages"
bash "$ROOT/shared/scripts/flatpak-setup.sh" "$PKG_DIR"
