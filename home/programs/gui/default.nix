{ inputs, pkgs, ... }:
let
  custom = import ../../../pkgs { inherit pkgs; };
in
{
  imports = [
    inputs.noctalia.homeModules.default

    ./niri.nix
    ./kitty.nix
    ./gamescope-ge-proton.nix
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  programs.discord.enable = true;

  # Default browser: Brave for xdg-open / handlers.
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
    wl-clipboard-rs # neovim clipboard (providers.wl-copy)

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

    # Default browser: Brave + local CDP (see pkgs/brave-with-cdp).
    custom.brave-with-cdp
    # Recreation instance (ASUS on oakhill): distinct app-id, no CDP.
    custom.brave-docked
    custom.satty-last-screenshot
  ];
}
