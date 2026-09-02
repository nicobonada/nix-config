{
  inputs,
  pkgs,
  config,
  grokPkg,
  ...
}:
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
    ./niri.nix
    ./kitty.nix
  ];

  # Seat age key (same file as trilium). Needed here so the CalDAV secret
  # decrypts even if trilium bootstrap is off.
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets."noctalia/caldav_password" = {
    sopsFile = ../../../secrets/noctalia.yaml;
  };

  # home-manager ships programs.noctalia (since 03f4cd46); do not also import
  # inputs.noctalia.homeModules.default or enable is declared twice.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # Flake pin so the binary hits noctalia.cachix.org (HM defaults to pkgs.noctalia).
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      calendar = {
        enabled = true;
        refresh_minutes = 15;
        account.fastmail = {
          type = "caldav";
          name = "Fastmail";
          provider = "custom";
          # Fastmail's advertised host root 404s on PROPFIND; /dav/ is the
          # discovery root (current-user-principal lives under it).
          server_url = "https://caldav.fastmail.com/dav/";
          username = "nico@bonada.ca";
          calendars = [ ];
          credential_source = "file";
          password_file = config.sops.secrets."noctalia/caldav_password".path;
        };
      };
    };
  };

  # Calendar password_file is the sops-nix decrypt path; start after it exists.
  systemd.user.services.noctalia = {
    Unit = {
      After = [ "sops-nix.service" ];
      Wants = [ "sops-nix.service" ];
    };
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
    (custom.pinkcode.override { grok = grokPkg; })

    # Brave profiles (see pkgs/brave.nix). Work is the default browser.
    custom.brave-work
    custom.brave-personal
    custom.brave-scratch
    custom.satty-last-screenshot
  ];
}
