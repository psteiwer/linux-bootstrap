#!/usr/bin/env bash
set -euo pipefail

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y curl git cron || true
fi

if command -v pihole >/dev/null 2>&1; then
  echo "[pihole] Detected existing Pi-hole. Updating gravity..."
  sudo pihole -g || true
  exit 0
fi

echo "[pihole] Installing Pi-hole (unattended)..."
curl -sSL https://install.pi-hole.net | sudo bash /dev/stdin --unattended || {
  echo "[pihole] Install failed. Run interactive installer if needed:"
  echo "  curl -sSL https://install.pi-hole.net | bash"
  exit 1
}

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now pihole-FTL || true
fi
