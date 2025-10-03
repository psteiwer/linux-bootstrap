#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PKG_DIR="$DIR/../packages"
LIST="$PKG_DIR/flatpak.txt"

if ! command -v flatpak >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y flatpak
  sudo apt-get install -y gnome-software-plugin-flatpak || true
fi

if ! flatpak remote-list | grep -q '^flathub\b'; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if [[ -f "$LIST" ]]; then
  grep -E '^[^#\s]+' "$LIST" | xargs -r -n1 flatpak install -y flathub
fi

flatpak update -y || true
