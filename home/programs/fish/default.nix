{ ... }:
{
  imports = [
    ./abbrs-aliases.nix
  ];

  # Plain fish under functions/*.fish — easier to read/edit than
  # programs.fish.functions. Installs to ~/.config/fish/functions/.
  xdg.configFile."fish/functions" = {
    source = ./functions;
    recursive = true;
  };

  # Wrap `nix develop` / `nix shell` / `nix-shell` so they exec fish
  # instead of bash. direnv already keeps flake shells in this session.
  programs.nix-your-shell.enable = true;

  programs.fish = {
    enable = true;

    shellInit = /* fish */ ''
      set -gx BROWSER brave-work
      set -gx EDITOR nvim
    '';

    # Prompt: fish_prompt + fish_right_prompt (path / IN_NIX_SHELL).
    interactiveShellInit = /* fish */ ''
      set -gx LESS "-iRSX"
    '';
  };
}
