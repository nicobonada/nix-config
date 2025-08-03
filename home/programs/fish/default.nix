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
      ${lib.getExe pkgs.any-nix-shell} fish --info-right | source
    '';
  };
}
