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

## CI

GitHub Actions runs `./scripts/preflight --eval` on pull requests and on
`main` (eval both NixOS hosts + `homeConfigurations.nico`). That is the
merge gate, not a switch. The runner installs Determinate Nix but does not
log in to FlakeHub Cache. Local `./scripts/preflight` builds this host
before activate, not before merge.

Dependabot opens a weekly grouped PR for `flake.lock` inputs. Merge still
waits on the preflight check; that is not a host switch.

- `flake-status` — two-pane status dashboard for flakes under `~/src` (public: `nicobonada/flake-status`). Read-only.

## License

[MIT](./LICENSE) — use and adapt freely; no warranty.
