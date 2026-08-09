{ inputs, pkgs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default

    ./niri.nix
    ./kitty.nix
    ./satty-last-screenshot.nix
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  programs.discord.enable = true;

  # Default browser trial: Brave for xdg-open / handlers. Revert: remove this
  # block (or point back at Zen's .desktop if one is registered).
  # force: pre-existing ~/.config/mimeapps.list from manual/desktop use.
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };

  home.packages = with pkgs; [
    # Wayland / session tooling
    qt6Packages.qt6ct
    app2unit
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

    # Default browser: Brave (niri Mod+O, startup, $BROWSER). Zen kept for easy
    # revert — flip niri-binds / niri-startup / fish BROWSER back to zen if needed.
    brave
    inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default
  ];
}
