#!/usr/bin/env bash
set -euo pipefail
. /etc/os-release || true

sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${ID:-debian}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID:-debian} ${VERSION_CODENAME:-stable} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if getent group docker >/dev/null; then
  sudo usermod -aG docker "$USER" || true
fi

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now docker || true
fi
