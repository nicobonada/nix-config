{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  custom = import ../../pkgs { inherit pkgs; };
  braveDesktop =
    {
      name,
      class,
      newWindow ? false,
      noDisplay ? false,
    }:
    {
      inherit name noDisplay;
      genericName = "Web Browser";
      exec = "${class}${lib.optionalString newWindow " --new-window"} %U";
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

    ./fish
    ./git
  ];

  programs.discord.enable = true;

  # Default browser: work Brave for xdg-open / handlers.
  # force: pre-existing ~/.config/mimeapps.list from manual/desktop use.
  # brave-work-open is the handler. --new-window maps a toplevel on the
  # focused workspace. A plain launch would tab into a window elsewhere.
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-work-open.desktop";
      "x-scheme-handler/http" = "brave-work-open.desktop";
      "x-scheme-handler/https" = "brave-work-open.desktop";
      "x-scheme-handler/about" = "brave-work-open.desktop";
      "x-scheme-handler/unknown" = "brave-work-open.desktop";
    };
  };

  xdg.desktopEntries = {
    brave-work = braveDesktop {
      name = "Brave (work)";
      class = "brave-work";
    };
    brave-work-open = braveDesktop {
      name = "Brave (work)";
      class = "brave-work";
      newWindow = true;
      noDisplay = true;
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
    # YouTube on the Soundcore. Not the default browser.
    firefox
    kdiff3
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
    inputs.raiju-level.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Brave profiles (see pkgs/brave.nix). Work is the default browser.
    custom.brave-work
    custom.brave-personal
    custom.brave-scratch
  ];
}
