{ lib, pkgs, ... }:
{
  programs.bashmount = {
      enable = true;

      extraConfig = /*bash*/''
        filemanager() {
            ( cd "$1" && ${lib.getExe pkgs.fish} )
        }
      '';
  };
}
