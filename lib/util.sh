#!/usr/bin/env bash
set -euo pipefail
log()  { printf "\033[1;32m[+] %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m[!] %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[x] %s\033[0m\n" "$*" >&2; }
