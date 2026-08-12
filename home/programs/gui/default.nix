{ inputs, pkgs, ... }:
let
  # Brave with loopback CDP so Grok/Playwright MCP can attach to the *same*
  # session (read open tabs). Port is 127.0.0.1 only — full browser control
  # for anything that can hit that port on this machine.
  # Must fully quit Brave for flags to apply (second launch reuses the process).
  braveWithCdp = pkgs.symlinkJoin {
    name = "brave-with-cdp";
    paths = [ pkgs.brave ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/brave \
        --add-flags "--remote-debugging-port=9222" \
        --add-flags "--remote-debugging-address=127.0.0.1" \
        --add-flags "--disable-blink-features=AutomationControlled"
    '';
  };
in
{
  imports = [
    inputs.noctalia.homeModules.default

    ./niri.nix
    ./kitty.nix
    ./satty-last-screenshot.nix
    ./gamescope-ge-proton.nix
    ./smile.nix
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
    wl-clipboard-rs # Smile (wl-copy) + neovim clipboard

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

    # Default browser: Brave + local CDP (see braveWithCdp).
    braveWithCdp
  ];
}
