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

  programs.fish = {
    enable = true;

    shellInit = /* fish */ ''
      # Default browser trial: Brave. Revert: set BROWSER zen
      set -gx BROWSER brave
      set -gx EDITOR nvim
    '';

    # Prompt: fish_prompt + fish_right_prompt (path / IN_NIX_SHELL).
    # direnv keeps flake shells in fish; bare `nix develop` may use bash.
    interactiveShellInit = /* fish */ ''
      set -gx LESS "-iRSX"
    '';
  };
}

