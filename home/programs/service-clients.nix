{ pkgs, ... }:
let
  # Upstream uses argcomplete (no static completion file in the package).
  # Same stub as `backblaze-b2 install-autocomplete --shell fish`, managed in
  # ~/.config/fish/completions so we don't mutate config.fish.
  # Dynamic: on Tab, re-invokes the CLI with _ARGCOMPLETE=1.
  b2FishCompletion =
    cmd:
    # cmd: executable name on PATH (backblaze-b2, b2v4, b2v3)
    let
      # fish function names cannot contain '-'
      fn = "__fish_${pkgs.lib.replaceStrings [ "-" ] [ "_" ] cmd}_complete";
    in
    ''
      function ${fn}
          set -lx _ARGCOMPLETE 1
          set -lx _ARGCOMPLETE_DFS \t
          set -lx _ARGCOMPLETE_IFS \n
          set -lx _ARGCOMPLETE_SUPPRESS_SPACE 1
          set -lx _ARGCOMPLETE_SHELL fish
          set -lx COMP_LINE (commandline -p)
          set -lx COMP_POINT (string length (commandline -cp))
          set -lx COMP_TYPE
          if set -q _ARC_DEBUG
              ${cmd} 8>&1 9>&2 1>&9 2>&1
          else
              ${cmd} 8>&1 9>&2 1>/dev/null 2>&1
          end
      end
      complete --command ${cmd} -f -a '(${fn})'
    '';
in
{
  # Interactive CLIs for hosted / external services (object storage, backups,
  # task APIs). Inject secrets with `with-secrets` (Grok capability registry).
  # 1Password op/GUI/MCP stay on NixOS (nixos/common/onepassword.nix), not here.
  #
  # B2 (read-only app key grok-read via capability b2-read):
  #   with-secrets b2-read -- backblaze-b2 bucket list
  #   with-secrets b2-read -- backblaze-b2 ls nico-homelab-proxmox-backup/dump
  # Env names match the official CLI: B2_APPLICATION_KEY_ID, B2_APPLICATION_KEY
  # (fish must not expand $B2_* on the outer command line — the CLI reads env).
  home.packages = with pkgs; [
    backblaze-b2
    restic
    # Official Doist CLI (`td`) — human terminal use; agents keep Todoist MCP
    todoist-cli
  ];

  xdg.configFile = {
    "fish/completions/backblaze-b2.fish".text = b2FishCompletion "backblaze-b2";
    # Same package also installs these names on PATH.
    "fish/completions/b2v4.fish".text = b2FishCompletion "b2v4";
    "fish/completions/b2v3.fish".text = b2FishCompletion "b2v3";
  };
}
