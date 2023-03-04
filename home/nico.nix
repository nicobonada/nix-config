# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./programs
    ./services
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nico";
  home.homeDirectory = "/home/nico";

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    TERMINAL = "kitty";
  };

  home.packages = with pkgs; [
    android-file-transfer
    appimage-run
    arandr
    aria2
    atool
    bandwhich
    breeze-qt5
    calibre
    cowsay
    crawlTiles
    discord
    dolphin
    dua
    duc
    duf
    fd
    flameshot
    htop
    inxi
    ipcalc
    jamesdsp
    kdiff3
    kid3
    kora-icon-theme
    lazygit
    libqalculate
    libreoffice
    lsof
    lxappearance
    mate.mate-themes
    mediainfo
    mp3gain
    mpc_cli
    neofetch
    networkmanagerapplet
    nix-prefetch-git
    nix-tree
    nixpkgs-fmt
    nmap
    numlockx #oakhill
    okular
    perl534Packages.FileMimeInfo
    plasma5Packages.ffmpegthumbs
    plasma5Packages.kdegraphics-thumbnailers
    playerctl
    procs
    pulseaudio # needed for pactl
    pulsemixer
    qbittorrent
    qt5ct
    r128gain
    ranger
    renameutils
    ripgrep # used mainly for telescope
    sgtpuzzles
    shellcheck
    tree
    unrar # required by atool
    unzip # required by atool
    # (vivaldi.override { enableWidevine = true; proprietaryCodecs = true; })
    (vivaldi.override {
      commandLineArgs = ''
        --use-gl=desktop \
        --ignore-gpu-blocklist \
        --enable-gpu-rasterization \
        --enable-zero-copy \
        --enable-features=VaapiVideoDecoder
      '';
    })
    vivid
    wavemon
    xidlehook
    xorg.xkill
    xorg.xmessage
    xsel
    (gwenview.overrideAttrs (oldAttrs: {
      propagatedUserEnvPkgs = oldAttrs.propagatedUserEnvPkgs ++ [ libsForQt5.kio-extras ];
    }))

    # fonts
    noto-fonts
    corefonts
    comic-neue
    font-awesome_5
    inter
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    noto-fonts-emoji
  ];

  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile."i3/config".source  = ./configs/i3config;
  xdg.configFile."i3status".source   = ./configs/i3status;

  home.file.".crawl/init.txt".source = ./configs/crawlinit;
  home.file.".xprofile".source       = ./configs/xprofile;
  home.file.".Xresources".source     = ./configs/xresources;
  home.file.".bash_profile".source   = ./configs/bash_profile;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
