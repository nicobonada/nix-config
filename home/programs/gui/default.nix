{ inputs, pkgs, ... }:
let
  custom = import ../../../pkgs { inherit pkgs; };
  braveDesktop =
    { name, class }:
    {
      inherit name;
      genericName = "Web Browser";
      exec = "${class} %U";
      icon = "brave-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      settings.StartupWMClass = class;
    };
in
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

  # Default browser: work Brave for xdg-open / handlers.
  # force: pre-existing ~/.config/mimeapps.list from manual/desktop use.
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-work.desktop";
      "x-scheme-handler/http" = "brave-work.desktop";
      "x-scheme-handler/https" = "brave-work.desktop";
      "x-scheme-handler/about" = "brave-work.desktop";
      "x-scheme-handler/unknown" = "brave-work.desktop";
    };
  };

  xdg.desktopEntries = {
    brave-work = braveDesktop {
      name = "Brave (work)";
      class = "brave-work";
    };
    brave-personal = braveDesktop {
      name = "Brave (personal)";
      class = "brave-personal";
    };
    brave-scratch = braveDesktop {
      name = "Brave (scratch)";
      class = "brave-scratch";
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
    custom.yaak
    custom.yaak-cli

    # Brave profiles (see pkgs/brave.nix). Work is the default browser.
    custom.brave-work
    custom.brave-personal
    custom.brave-scratch
    custom.satty-last-screenshot
  ];
}
