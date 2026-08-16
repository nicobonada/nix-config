# nix-config

Personal [NixOS](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager) configuration.

Working personal config, not a template — steal ideas freely. Details live in the Nix files; this README only covers what does not age well next to the code.

## Hosts

| Host | Role |
|------|------|
| **oakhill** | Desktop |
| **seyruun** | Laptop |

Flake outputs: `nixosConfigurations.{oakhill,seyruun}`, `homeConfigurations.nico`.

Layout: shared system modules in `nixos/common/`, per-host configs under `nixos/<host>/`, user config under `home/`, custom packages under `pkgs/`. See `flake.nix` for inputs and outputs. oakhill disks/ZFS: `nixos/oakhill/disks.nix`.

## Secrets

Secrets live **in this repo**, encrypted with [sops-nix](https://github.com/Mic92/sops-nix) + age (`secrets/`, `.sops.yaml`).

- Edit: `sops secrets/<file>.yaml` (needs private age key).
- Private age key is **not** in the repo: `~/.config/sops/age/keys.txt` on each machine that should decrypt (back this key up separately).
- SSH host keys, Tailscale enrollment, and similar machine bootstrap stay off-repo.

## Usage

Repo expected at `~/src/nix-config` (`NH_FLAKE` is set in home config for convenience).

**Interactive (optional):** [nh](https://github.com/nix-community/nh) for diffs / nicer build output.

```fish
nh os switch ~/src/nix-config
nh home switch ~/src/nix-config
```

**Agents / scripts** use `nixos-rebuild` and `home-manager` (passwordless OS switch is scoped to `nixos-rebuild` only):

```fish
sudo -n nixos-rebuild switch --flake ~/src/nix-config#$(hostname -s)
home-manager switch --flake ~/src/nix-config#nico
./scripts/preflight   # eval both hosts + build OS/home (no activate)
```


- `flake-status` — two-pane status dashboard for flakes under `~/src` (public: `nicobonada/flake-status`). Read-only.
- `scripts/update-determinate` — bump Determinate Nix to the latest GitHub **non-prerelease** (auto minor/patch pin).

Agents: keep work on `wip` (preflight + switch from that tip); **land `main` + push only when uploading** (switch is the live proof before publish). Details in portable Grok rules (`nix-config` / `automation`).

## License

[MIT](./LICENSE) — use and adapt freely; no warranty.
