# nix-config

Personal [NixOS](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager) configuration.

Working personal config, not a template — steal ideas freely. Details live in the Nix files; this README only covers what does not age well next to the code.

## Hosts

| Host | Role |
|------|------|
| **oakhill** | Desktop |
| **seyruun** | Laptop |

Flake outputs: `nixosConfigurations.{oakhill,seyruun}`, `homeConfigurations.nico`.

Layout: shared system modules in `nixos/common/`, per-host configs under `nixos/<host>/`, user config under `home/`. See `flake.nix` for inputs and outputs.

## Secrets

Secrets live **in this repo**, encrypted with [sops-nix](https://github.com/Mic92/sops-nix) + age (`secrets/`, `.sops.yaml`).

- Edit: `sops secrets/<file>.yaml` (needs private age key).
- Private age key is **not** in the repo: `~/.config/sops/age/keys.txt` on each machine that should decrypt (back this key up separately).
- SSH host keys, Tailscale enrollment, and similar machine bootstrap stay off-repo.

## Usage

Repo expected at `~/src/nix-config` (`NH_FLAKE` is set in home config). Prefer [nh](https://github.com/nix-community/nh):

```fish
nh os switch ~/src/nix-config              # system (this hostname)
nh os switch --update ~/src/nix-config     # update inputs, then switch
nh home switch ~/src/nix-config            # home-manager
./scripts/preflight                        # eval both hosts + build OS/home (no activate)
```

- `check-inputs` — poll flake inputs via `nix flake metadata` (default: both; `nix` / `lab` / paths; `-v` lists stale). No lock changes.
- `nupd` — `check-inputs -v`, then for each stale flake: update + activate (nix-config: `nh os/home switch --update`; homelab: lock only, remote switch separate) and `jj commit` `flake.lock` when it moved.

Agents: green preflight → land on `main`; **switch this host before push** (switch is the live proof). Details in portable Grok rules (`nix-config` / `automation`).

## Grok

Not on the global PATH. Project shell only (flake input `git+ssh://git@github.com/nicobonada/grok-config.git`):

```fish
cd ~/src/nix-config   # direnv loads the flake when enabled
grok
# or without direnv:
nix develop
```

Home-manager enables **direnv + nix-direnv** (`home/programs/direnv.nix`). After a home switch, once per clone: `direnv allow`. That GC-roots the shell so store cleans do not always re-fetch Grok.

General / scratch: `cd ~/chat` (same pattern).

## License

[MIT](./LICENSE) — use and adapt freely; no warranty.
