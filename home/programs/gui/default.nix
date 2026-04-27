{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default

    ./niri.nix
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
    app2unit
    satty
    slurp
    wayscriber
    wl-screenrec
    wl-clipboard-rs # needed for emoji picker and neovim
  ];
}
