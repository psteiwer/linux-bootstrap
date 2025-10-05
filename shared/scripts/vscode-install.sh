#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PKG_DIR="$DIR/../packages"
[[ ! -f "$PKG_DIR/code.repo" ]] && exit 0

sudo apt-get update -y
sudo apt-get install -y wget gpg apt-transport-https

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

. /etc/os-release || true
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y code
