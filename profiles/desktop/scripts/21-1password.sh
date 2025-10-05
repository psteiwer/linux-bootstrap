#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Check if sudo is available and user has privileges
if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true 2>/dev/null; then
    echo "Error: This script requires sudo privileges for 1Password installation."
    exit 1
fi

# Install 1Password with sudo
echo "Installing 1Password (requires sudo)..."
sudo bash "$ROOT/shared/scripts/1password-install.sh"

# Add other non-root bootstrap tasks here
echo "Running non-root bootstrap tasks..."
# Your other commands