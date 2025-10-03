#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
CACHE="$ROOT/.cache"
mkdir -p "$CACHE"

# BEFORE snapshots
if command -v apt >/dev/null 2>&1; then
  apt list --installed 2>/dev/null | awk '{print $1}' | sort > "$CACHE/apt.before" || true
fi
systemctl list-unit-files --state=enabled 2>/dev/null | awk '{print $1}' | sort > "$CACHE/services.before" || true
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app 2>/dev/null | awk '{print $1}' | sort > "$CACHE/flatpak.before" || true
fi

# Pull latest if git
if command -v git >/dev/null 2>&1 && [ -d "$ROOT/.git" ]; then
  git -C "$ROOT" pull --ff-only
fi

# Run installer
PROFILE="${PROFILE:-}"
if [[ -z "${PROFILE}" ]]; then
  "$ROOT/install.sh"
else
  PROFILE="$PROFILE" "$ROOT/install.sh"
fi

# AFTER snapshots
if command -v apt >/dev/null 2>&1; then
  apt list --installed 2>/dev/null | awk '{print $1}' | sort > "$CACHE/apt.after" || true
fi
systemctl list-unit-files --state=enabled 2>/dev/null | awk '{print $1}' | sort > "$CACHE/services.after" || true
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app 2>/dev/null | awk '{print $1}' | sort > "$CACHE/flatpak.after" || true
fi

echo ""
echo "===== Post-apply diff ====="
if [[ -f "$CACHE/apt.before" && -f "$CACHE/apt.after" ]]; then
  echo "--- APT packages ---"
  diff -u "$CACHE/apt.before" "$CACHE/apt.after" || true
fi
if [[ -f "$CACHE/services.before" && -f "$CACHE/services.after" ]]; then
  echo "--- Enabled services ---"
  diff -u "$CACHE/services.before" "$CACHE/services.after" || true
fi
if [[ -f "$CACHE/flatpak.before" && -f "$CACHE/flatpak.after" ]]; then
  echo "--- Flatpak apps ---"
  diff -u "$CACHE/flatpak.before" "$CACHE/flatpak.after" || true
fi

# Roll baselines
[[ -f "$CACHE/apt.after" ]] && mv -f "$CACHE/apt.after" "$CACHE/apt.before" || true
[[ -f "$CACHE/services.after" ]] && mv -f "$CACHE/services.after" "$CACHE/services.before" || true
[[ -f "$CACHE/flatpak.after" ]] && mv -f "$CACHE/flatpak.after" "$CACHE/flatpak.before" || true
echo "==========================="
