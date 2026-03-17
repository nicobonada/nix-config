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

**No secrets in this repo** (no password hashes, private keys, Tailscale auth keys, or API tokens). SSH keys and enrollment stay on the machines. Git user identity and hostnames in config are intentional.

## Usage

Repo expected at `~/nix-config` (`NH_FLAKE` is set in home config). Prefer [nh](https://github.com/nix-community/nh):

```fish
nh os switch ~/nix-config              # system (this hostname)
nh os switch --update ~/nix-config     # update inputs, then switch
nh home switch ~/nix-config            # home-manager
```

Fish function `nupd` does system `--update` then home when the network is up.

## License

[MIT](./LICENSE) — use and adapt freely; no warranty.
