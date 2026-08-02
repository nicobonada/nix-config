# nix-config

Personal NixOS and home-manager configuration for my machines.

This repository manages multiple hosts with flakes and a modular layout:
shared system modules under `nixos/common/`, per-host configs, and a
standalone home-manager configuration for user `nico`.

## Hosts

| Host | Role |
|------|------|
| **oakhill** | Desktop |
| **seyruun** | Laptop |

Flake outputs: `nixosConfigurations.{oakhill,seyruun}` and
`homeConfigurations.nico`.

## Structure

```text
nix-config/
├── flake.nix                 # Flake entry point
├── flake.lock
├── patches/                  # Out-of-tree package patches
├── nixos/
│   ├── common/               # Shared system modules
│   ├── oakhill/              # Desktop host
│   └── seyruun/              # Laptop host
└── home/
    ├── nico.nix              # home-manager entry
    ├── programs/             # User programs and tools
    ├── services/             # User services
    ├── configs/              # Dotfiles and extra configs
    ├── fonts.nix
    └── stylix.nix
```

## Usage

Assumes the repo lives at `~/nix-config` (`NH_FLAKE` is set in home config).
Prefer [nh](https://github.com/nix-community/nh):

```fish
# System (uses this machine's hostname)
nh os switch ~/nix-config

# Update flake inputs, then switch system
nh os switch --update ~/nix-config

# Home environment
nh home switch ~/nix-config
```

Or use the fish function `nupd`: system switch with `--update`, then home
switch when network connectivity is full.

After edits, rebuild the part you changed (system modules vs `home/`).
