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
      inputs.nixneovimplugins.overlays.default

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
    arandr
    aria2
    bandwhich
    beets-unstable
    bibata-cursors
    breeze-qt5
    calibre
    cowsay
    crawlTiles
    discord
    dua
    duc
    duf
    erdtree
    fd
    flameshot
    htop
    inxi
    ipcalc
    jamesdsp
    kdiff3
    kdePackages.gwenview
    kdePackages.kio-extras # for showing folder previews in gwenview
    keepassxc
    kid3
    kora-icon-theme
    lazygit
    libqalculate
    lsof
    lxappearance
    mate.mate-themes
    mediainfo
    mp3gain
    mp3splt
    mpc_cli
    networkmanagerapplet
    nix-prefetch-git
    nix-tree
    nixpkgs-fmt
    nmap
    numlockx #oakhill
    okular
    patool
    pavucontrol
    perlPackages.FileMimeInfo
    plasma5Packages.ffmpegthumbs
    plasma5Packages.kdegraphics-thumbnailers
    playerctl
    procs
    pulseaudio # needed for pactl
    pulsemixer
    qbittorrent
    qt5ct
    r128gain
    renameutils
    ripgrep # used mainly for telescope
    sgt-puzzles
    shellcheck
    soulseekqt
    xfce.thunar
    tree
    unrar # required by atool
    unzip # required by atool
    # (vivaldi.override { enableWidevine = true; proprietaryCodecs = true; })
    (vivaldi.override {
      commandLineArgs = ''
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
    yubikey-manager
    yubioath-flutter

    # fonts
    noto-fonts
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

  xdg.configFile."beets/config.yaml".source = ./configs/beets_config.yaml;

  xdg.configFile."i3/config".source  = ./configs/i3config;
  xdg.configFile."i3status".source   = ./configs/i3status;

  home.file.".crawl/init.txt".source = ./configs/crawlinit;
  home.file.".xprofile".source       = ./configs/xprofile;
  home.file.".Xresources".source     = ./configs/xresources;
  home.file.".bash_profile".source   = ./configs/bash_profile;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
