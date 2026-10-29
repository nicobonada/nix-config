{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./brave.nix
    ./cli.nix
    ./direnv.nix
    ./noctalia.nix
    ./umbriel
    ./kitty.nix
    ./grok.nix
    ./media.nix
    ./networking.nix
    ./nvim.nix
    ./service-clients.nix
    ./ssh.nix
    ./yubi.nix
    ./zathura.nix

    ./fish
    ./git
  ];

  programs.discord.enable = true;

  home.packages = with pkgs; [
    # Wayland / session tooling
    qt6Packages.qt6ct
    app2unit
    satty
    slurp
    wayscriber
    wl-screenrec
    wl-clipboard-rs # neovim clipboard (providers.wl-copy)

    # Desktop apps & themes
    android-file-transfer
    anydesk
    bibata-cursors
    # pyopenjtalk's test fails on nixpkgs 2026-10-20, which blocks
    # piper-tts and then this package. Put it back when that test passes.
    # calibre
    crawlTiles
    dconf-editor
    # YouTube on the Soundcore. Not the default browser.
    firefox
    kdiff3
    kdePackages.kolourpaint
    lxqt.pcmanfm-qt
    papirus-icon-theme
    qview
    rustdesk-flutter
    sgt-puzzles
    ticktick
    trilium-desktop
    zoom-us
    inputs.raiju-level.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
