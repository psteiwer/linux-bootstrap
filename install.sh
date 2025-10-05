#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/util.sh"
source "$ROOT/lib/os.sh"

PROFILE="${PROFILE:-}"
if [[ -z "${PROFILE}" ]]; then
  echo "Available profiles:"
  ls "$ROOT/profiles" | sed 's/^/ - /'
  read -rp "Enter PROFILE: " PROFILE
fi

if [[ ! -d "$ROOT/profiles/$PROFILE" ]]; then
  echo "!! Unknown profile: $PROFILE"
  exit 1
fi

log "Using profile: $PROFILE"
L_COMMON="$ROOT/profiles/common"
L_PROFILE="$ROOT/profiles/$PROFILE"

apply_layer() {
  local L="$1"
  [[ ! -d "$L" ]] && return

  # 1) APT packages (supports grouped lists under packages/)
  if [[ "$OS_PKG" == "apt" ]]; then
    if [[ -d "$L/packages" ]]; then
      sudo apt-get update -y
      for f in core dev gui security; do
        LIST="$L/packages/apt.$f.txt"
        [[ -f "$LIST" ]] && grep -E '^[^#\s]+' "$LIST" | xargs -r sudo apt-get install -y --no-install-recommends
      done
    elif [[ -f "$L/packages.apt.txt" ]]; then
      sudo apt-get update -y
      grep -E '^[^#\s]+' "$L/packages.apt.txt" | xargs -r sudo apt-get install -y --no-install-recommends
    fi
  else
    warn "Non-APT distro detected ($OS_PKG). Extend lib/os.sh to support it."
  fi

  # 2) pip/pipx packages
  if [[ -f "$L/packages.pip.txt" ]]; then
    if command -v pipx >/dev/null 2>&1; then
      pipx install --requirement "$L/packages.pip.txt" || true
    else
      python3 -m pip install --user -r "$L/packages.pip.txt" || true
    fi
  fi

  # 3) scripts
  if [[ -d "$L/scripts" ]]; then
    for s in "$L/scripts"/*.sh; do
      [[ -x "$s" ]] && "$s"
    done
  fi

  # 4) dotfiles via GNU Stow
  if [[ -d "$L/stow" ]]; then
    "$ROOT/tools/stow_all.sh" "$L/stow"
  fi

  # 5) services
  if [[ -d "$L/services" ]]; then
    sudo mkdir -p /etc/systemd/system
    sudo cp -f "$L/services/"*.service /etc/systemd/system/ || true
    sudo systemctl daemon-reload
    for u in "$L/services/"*.service; do
      [[ -f "$u" ]] || continue
      SVC="$(basename "$u")"
      sudo systemctl enable --now "$SVC" || true
      if systemctl is-active --quiet "$SVC"; then
        sudo systemctl restart "$SVC" || true
      fi
    done
  fi
}

apply_layer "$L_COMMON"
apply_layer "$L_PROFILE"
log "✓ Bootstrap complete for profile: $PROFILE"
