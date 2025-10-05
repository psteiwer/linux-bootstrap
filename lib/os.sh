#!/usr/bin/env bash
set -euo pipefail
if command -v apt-get >/dev/null 2>&1; then
  OS_PKG="apt"
elif command -v dnf >/dev/null 2>&1; then
  OS_PKG="dnf"
elif command -v pacman >/dev/null 2>&1; then
  OS_PKG="pacman"
else
  OS_PKG="unknown"
fi
