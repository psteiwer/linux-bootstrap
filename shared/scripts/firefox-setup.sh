#!/bin/bash

# Script to uninstall Snap Firefox and install Firefox via APT PPA

# Exit on any error
set -e

# Function to check if command executed successfully
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Check if script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Step 1: Check if Firefox Snap is installed
echo "Checking for Snap Firefox installation..."
if snap list | grep -q firefox; then
    echo "Snap Firefox found. Removing..."
    sudo snap remove firefox
    check_status "Failed to remove Snap Firefox"
    echo "Snap Firefox removed successfully."
else
    echo "Snap Firefox is not installed. Proceeding..."
fi

# Step 2: Remove residual Snap Firefox data
echo "Removing residual Firefox Snap data..."
rm -rf ~/snap/firefox
check_status "Failed to remove Snap Firefox data"

# Step 3: Add Mozilla Team PPA
echo "Adding Mozilla Team PPA..."
sudo add-apt-repository ppa:mozillateam/ppa -y
check_status "Failed to add Mozilla Team PPA"
echo "Mozilla Team PPA added successfully."

# Step 4: Create APT preferences file for Mozilla Firefox
echo "Setting APT preferences for Mozilla Firefox..."
cat << EOF | sudo tee /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
check_status "Failed to create Mozilla Firefox preferences file"
echo "APT preferences file created successfully."

# Step 5: Update APT package lists
echo "Updating APT package lists..."
sudo apt update
check_status "Failed to update APT package lists"
echo "APT package lists updated successfully."

# Step 6: Install Firefox via APT
echo "Installing Firefox via APT..."
sudo apt install firefox -y
check_status "Failed to install Firefox"
echo "Firefox installed successfully."

# Step 7: Configure AppArmor profile for Firefox to allow YubiKey access
echo "Configuring AppArmor profile for Firefox YubiKey support..."
APPARMOR_LOCAL="/etc/apparmor.d/local/usr.bin.firefox"
cat << EOF | sudo tee -a "$APPARMOR_LOCAL"
# Allow Firefox to access YubiKey USB devices
/dev/hidraw* rw,
/sys/devices/**/hidraw* r,
/run/udev/data/c204: r,
/run/udev/data/+hid:busnum-* r,
EOF
check_status "Failed to update AppArmor profile for Firefox"

# Step 8: Reload AppArmor profile
echo "Reloading AppArmor profile..."
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.firefox
check_status "Failed to reload AppArmor profile"
sudo systemctl reload apparmor
check_status "Failed to reload AppArmor service"
echo "AppArmor profile reloaded successfully."

# Step 9: Verify Firefox installation
echo "Verifying Firefox installation..."
FIREFOX_PATH=$(which firefox)
if [ -z "$FIREFOX_PATH" ]; then
    echo "Error: Firefox executable not found."
    exit 1
fi
echo "Firefox is installed at: $FIREFOX_PATH"

# Step 10: Check Firefox version
FIREFOX_VERSION=$(firefox --version)
check_status "Failed to retrieve Firefox version"
echo "Firefox version: $FIREFOX_VERSION"

echo "Script completed successfully! Firefox is now installed from the Mozilla Team PPA."