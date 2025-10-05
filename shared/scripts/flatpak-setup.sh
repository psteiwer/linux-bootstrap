#!/usr/bin/env bash
set -euo pipefail

# Check if PKG_DIR parameter is provided
if [ $# -ne 1 ]; then
  echo "Error: Please provide the PKG_DIR parameter."
  echo "Usage: $0 <PKG_DIR>"
  exit 1
fi

PKG_DIR="$1"
LIST="$PKG_DIR/flatpak.txt"
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Verify PKG_DIR exists and is a directory
if [ ! -d "$PKG_DIR" ]; then
  echo "Error: Directory '$PKG_DIR' does not exist."
  exit 1
fi

# Install Flatpak if not already installed
if ! command -v flatpak >/dev/null 2>&1; then
  echo "Installing Flatpak..."
  sudo apt-get update -y
  sudo apt-get install -y flatpak
  sudo apt-get install -y gnome-software-plugin-flatpak || true
fi

# Add Flathub repository if not already added
if ! flatpak remote-list | grep -q '^flathub\b'; then
  echo "Adding Flathub repository..."
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install packages listed in flatpak.txt, ignoring comments and empty lines
if [ -f "$LIST" ]; then
  echo "Installing packages from $LIST..."
  grep -E '^[^#\s]+' "$LIST" | xargs -r -n1 flatpak install -y flathub
else
  echo "Warning: Package list '$LIST' not found. Skipping package installation."
fi

# Update Flatpak packages
echo "Updating Flatpak packages..."
flatpak update -y || true
echo "Flatpak done"