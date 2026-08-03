{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default

    ./niri.nix
    ./kitty.nix
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  programs.discord.enable = true;

  home.packages = with pkgs; [
    # Wayland / session tooling
    qt6Packages.qt6ct
    # Temporary: scdoc 1.11.5 + broken manpage italics. Upstream fixed;
    # drop when nixpkgs has the fix.
    (app2unit.overrideAttrs {
      patches = [ ../../../patches/app2unit-scdoc-nesting.patch ];
    })
    satty
    slurp
    wayscriber
    wl-screenrec
    wl-clipboard-rs # needed for emoji picker and neovim

    # Desktop apps & themes
    android-file-transfer
    anydesk
    bibata-cursors
    calibre
    dconf-editor
    kdiff3
    # keepassxc
    kdePackages.kolourpaint
    kdePackages.okular
    lxqt.pcmanfm-qt
    papirus-icon-theme
    qview
    rustdesk-flutter
    sgt-puzzles
    ticktick
    trilium-desktop
    zoom-us

    inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default
  ];
}
