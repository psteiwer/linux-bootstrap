#!/bin/bash

# Exit on any error
set -e

# Define variables for paths and URLs
KEYRING_PATH="/usr/share/keyrings/1password-archive-keyring.gpg"
REPO_FILE="/etc/apt/sources.list.d/1password.list"
REPO_LINE="deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main"
POLICY_DIR="/etc/debsig/policies/AC2D62742012EA22"
POLICY_FILE="$POLICY_DIR/1password.pol"
DEBSIG_KEYRING_DIR="/usr/share/debsig/keyrings/AC2D62742012EA22"
DEBSIG_KEYRING_FILE="$DEBSIG_KEYRING_DIR/debsig.gpg"
KEY_URL="https://downloads.1password.com/linux/keys/1password.asc"
POLICY_URL="https://downloads.1password.com/linux/debian/debsig/1password.pol"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
for cmd in curl gpg apt; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Check if running as root or with sudo
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run with sudo or as root."
    exit 1
fi

# Step 1: Import 1Password GPG key if not already present
if [ ! -f "$KEYRING_PATH" ]; then
    echo "Importing 1Password GPG key..."
    curl -sS "$KEY_URL" | gpg --dearmor --output "$KEYRING_PATH"
else
    echo "1Password GPG key already exists at $KEYRING_PATH"
fi

# Step 2: Add 1Password repository if not already present
if [ ! -f "$REPO_FILE" ] || ! grep -Fx "$REPO_LINE" "$REPO_FILE" >/dev/null; then
    echo "Adding 1Password repository..."
    echo "$REPO_LINE" | tee "$REPO_FILE"
else
    echo "1Password repository already configured in $REPO_FILE"
fi

# Step 3: Set up debsig-verify policy if not already present
if [ ! -f "$POLICY_FILE" ]; then
    echo "Setting up debsig-verify policy..."
    mkdir -p "$POLICY_DIR"
    curl -sS "$POLICY_URL" | tee "$POLICY_FILE"
else
    echo "debsig-verify policy already exists at $POLICY_FILE"
fi

# Step 4: Set up debsig-verify keyring if not already present
if [ ! -f "$DEBSIG_KEYRING_FILE" ]; then
    echo "Setting up debsig-verify keyring..."
    mkdir -p "$DEBSIG_KEYRING_DIR"
    curl -sS "$KEY_URL" | gpg --dearmor --output "$DEBSIG_KEYRING_FILE"
else
    echo "debsig-verify keyring already exists at $DEBSIG_KEYRING_FILE"
fi

# Step 5: Update apt and install 1Password
echo "Updating apt package lists..."
apt update

if dpkg -l | grep -q 1password; then
    echo "1Password is already installed, checking for updates..."
    apt install --only-upgrade 1password
else
    echo "Installing 1Password..."
    apt install 1password
fi

echo "1Password installation completed successfully!"