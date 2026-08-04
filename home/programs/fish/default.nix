{ lib, pkgs, ... }:
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
      set BROWSER zen
      set -gx EDITOR nvim
    '';

    interactiveShellInit = /* fish */ ''
      set -gx LESS "-iRSX"
      ${lib.getExe pkgs.any-nix-shell} fish --info-right | source
    '';
  };
}
