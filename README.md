# nix-config

Personal [NixOS](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager) configuration for my machines.

Flakes drive two hosts plus a standalone home-manager profile: shared system modules under `nixos/common/`, per-host configs, and user config under `home/` for `nico`.

This is a **working personal config**, not a template. Steal ideas freely; expect host-specific paths, packages, and habits.

## Hosts

| Host | Role | Notes |
|------|------|--------|
| **oakhill** | Desktop | AMD CPU/GPU, gaming module, tablet driver, Logitech wireless |
| **seyruun** | Laptop | AMD CPU, lid ignore / hybrid sleep quirks |

Flake outputs:

- `nixosConfigurations.{oakhill,seyruun}`
- `homeConfigurations.nico` (standalone HM; not nested only inside NixOS)

## Stack (high level)

| Area | Choice |
|------|--------|
| Channel | `nixpkgs` **unstable** |
| Nix distro | [Determinate](https://determinate.systems/) (`determinate` flake input) |
| Desktop | [Niri](https://github.com/YaLTeR/niri) + [UWSM](https://github.com/Vladimir-csp/uwsm) + [Noctalia](https://github.com/noctalia-dev/noctalia) |
| Theming | [Stylix](https://github.com/nix-community/stylix) |
| Editor | Neovim via [nvf](https://github.com/NotAShelf/nvf) |
| Mesh VPN | Tailscale (client routing; works with Mullvad exit nodes) |
| Shell | fish (+ `nh`, abbreviations, etc.) |
| Misc inputs | zen-browser, nix-index-database, ucodenix, auto-cpufreq, llm-agents, [grok-config](https://github.com/nicobonada/grok-config) |

## Structure

```text
nix-config/
├── flake.nix                 # Inputs + nixosConfigurations + homeConfigurations
├── flake.lock
├── patches/                  # Out-of-tree package patches
├── nixos/
│   ├── common/               # Shared system modules (optional features via *.enable)
│   ├── oakhill/              # Desktop host
│   └── seyruun/              # Laptop host
└── home/
    ├── nico.nix              # home-manager entry
    ├── programs/             # User programs (cli, gui, fish, git, nvim, …)
    ├── services/             # User services (e.g. mpd)
    ├── configs/              # Dotfiles and extra configs
    ├── fonts.nix
    └── stylix.nix
```

Host `configuration.nix` files stay thin: import `../common`, toggle modules (`amd-gpu`, `gaming`, …), and set hostname/timezone/hardware.

## Secrets and credentials

**No secrets are stored in this repository.** You should not find:

- Password hashes (`hashedPassword` / `initialHashedPassword`)
- SSH private keys or authorized key material
- Tailscale auth keys, API tokens, or cloud credentials
- Encrypted secret stores (sops/agenix) — not used here yet

Things that *are* public by design: git/jj user name and email in home config, hostnames, hardware UUIDs from `nixos-generate-config`, SSH *client* defaults (identity path, host aliases like `homelab` / `pve`), and binary-cache public keys.

SSH keys, Tailscale enrollment, and any passwords live **on the machines**, outside git. If secrets ever need to be managed in-repo, prefer something like [sops-nix](https://github.com/Mic92/sops-nix) or [agenix](https://github.com/ryantm/agenix) rather than plaintext.

## Usage

Assumes the repo lives at `~/nix-config` (`NH_FLAKE` is set in home config). Prefer [nh](https://github.com/nix-community/nh):

```fish
# System (uses this machine's hostname)
nh os switch ~/nix-config

# Update flake inputs, then switch system
nh os switch --update ~/nix-config

# Home environment
nh home switch ~/nix-config
```

Or use the fish function `nupd`: system switch with `--update`, then home switch when network connectivity is full.

After edits, rebuild the part you changed (system modules vs `home/`).

Without `nh`:

```fish
sudo nixos-rebuild switch --flake ~/nix-config#$(hostname)
home-manager switch --flake ~/nix-config#nico
```

## Adapting this flake

1. Fork or clone; keep `flake.lock` until you intentionally update.
2. Replace `hardware-configuration.nix` (and boot bits) per host from `nixos-generate-config`.
3. Rename hosts / user: flake attributes, `networking.hostName`, `home.username`, and paths under `home/`.
4. Drop or disable modules you do not need (`gaming`, `royal-kludge`, YubiKey, greeter, …).
5. Point or remove private-ish inputs (e.g. `grok-config`) if you do not use them.
6. Do **not** casually change `system.stateVersion` / `home.stateVersion` ([FAQ](https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion)).

## License

[MIT](./LICENSE) — use and adapt freely; no warranty.
