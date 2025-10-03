# linux-bootstrap

This repository manages full-system bootstrap and configuration for multiple machines (desktop + Raspberry Pi profiles).  
It combines **packages**, **dotfiles (GNU Stow)**, **scripts**, and **systemd services** into layered profiles.

## Profiles
- `desktop` — GUI desktop (Flatpak apps, Docker, VS Code)
- `microraptor` — Pi-hole
- `manbearpig` — Pi-hole
- `mammoth` — Docker host
- `common` — shared bits applied to every profile

## Fresh install
```bash
sudo apt update && sudo apt install -y git unzip stow
unzip bootstrap-profiles-v8-fixed2.zip
cd bootstrap
./install.sh            # prompts for PROFILE
# or:
PROFILE=desktop ./install.sh
```

## Apply updates later
```bash
cd ~/bootstrap
./apply.sh              # pulls latest + reapplies; shows a diff of changes
# or:
PROFILE=mammoth ./apply.sh
```

## Where to put changes
- Packages:
  - Desktop: `profiles/desktop/packages/apt.core.txt`, `apt.dev.txt`, `apt.gui.txt`, `flatpak.txt`
  - Pis: use `profiles/<pi>/packages.apt.txt` or add a `packages/` directory if you prefer grouping
- Dotfiles:
  - `profiles/common/stow/` for shared configs (e.g., git)
  - `profiles/<profile>/stow/` for profile-specific configs
- Scripts:
  - `profiles/<profile>/scripts/NN-name.sh` (`chmod +x`), runs in lexical order
- Services:
  - `profiles/<profile>/services/*.service` (copied to `/etc/systemd/system`, enabled+restarted)

## Notes
- Re-running is safe: package installs are idempotent; stow uses `-R`; services are reloaded/restarted.
- Git config is centralized in `profiles/common/stow/git/.gitconfig` and includes `~/.gitconfig.local` for per-machine overrides (desktop provides one).


## Shared scripts
Common installers live under `shared/scripts/` and profiles call them via tiny wrappers in `profiles/<profile>/scripts/`:
- `shared/scripts/flatpak-setup.sh`
- `shared/scripts/docker-install.sh`
- `shared/scripts/vscode-install.sh`
- `shared/scripts/pihole-install.sh`

This avoids duplication across profiles; edit the shared script once and re-run `apply.sh` on any machine.
