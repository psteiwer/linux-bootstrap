#!/usr/bin/env bash
set -euo pipefail
SRC="${1:-}"
[[ -z "$SRC" || ! -d "$SRC" ]] && exit 0

if ! command -v stow >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y && sudo apt-get install -y stow
  else
    echo "Please install GNU stow" >&2
    exit 1
  fi
fi

for pkg in "$SRC"/*; do
  [[ -d "$pkg" ]] && stow -R -d "$SRC" -t "$HOME" "$(basename "$pkg")"
done
