{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellInit = /*fish*/ ''
      set BROWSER "vivaldi"
      set -gx EDITOR nvim
    '';

    interactiveShellInit = ''
      set -gx LS_COLORS (${pkgs.vivid}/bin/vivid generate tokyonight-storm-vivid-nobold)

      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '' + builtins.readFile ./interactive.fish;
  };

  xdg.configFile = {
    "fish/tokyonight_storm.fish".source = ./tokyonight_storm.fish;
    "fish/functions".source = ./functions;
    "vivid/themes/tokyonight-storm-vivid-nobold.yml".source = ./tokyonight-storm-vivid-nobold.yml;
  };
}
