{ lib, pkgs, ... }:
{
  imports = [
    ./abbrs-aliases.nix
    ./functions.nix
  ];

  programs.fish = {
    enable = true;

    shellInit = /* fish */ ''
      set BROWSER zen
      set -gx EDITOR nvim
    '';

    interactiveShellInit = /* fish */ ''
      set -gx LESS "-iRSX"
      set -gx LS_COLORS (${lib.getExe pkgs.vivid} generate tokyonight-storm-vivid-nobold)

      ${lib.getExe pkgs.any-nix-shell} fish --info-right | source

      source ~/.config/fish/tokyonight_storm.fish
    '';
  };

  xdg.configFile = {
    "fish/tokyonight_storm.fish".source = ./tokyonight_storm.fish;
    "vivid/themes/tokyonight-storm-vivid-nobold.yml".source = ./tokyonight-storm-vivid-nobold.yml;
  };
}
