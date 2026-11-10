{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./helium.nix
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
    crawlTiles
    dconf-editor
    # Package only. programs.discord.enable pins settings.json in the
    # store; Discord replaces that symlink (window bounds) and the next
    # home switch fails. nixpkgs injects SKIP_HOST_UPDATE on launch.
    discord
    # YouTube on the Soundcore. Not the default browser.
    firefox
    kdiff3
    kdePackages.kolourpaint
    thunar
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
