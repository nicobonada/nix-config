# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger

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
    QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    TERMINAL = "kitty";
    FLAKE = "$HOME/nix-config";
  };

  home.packages = with pkgs; [
    android-file-transfer
    arandr
    aria2
    bandwhich
    beets-unstable
    bemoji # emoji picker, needs rofi and wtype
    calibre
    cowsay
    crawlTiles
    discord
    dua
    duc
    duf
    erdtree
    fd
    htop
    gnome.dconf-editor
    inxi
    ipcalc
    jamesdsp
    kdiff3
    kdePackages.ffmpegthumbs # used by gwenview
    kdePackages.gwenview
    kdePackages.kdegraphics-thumbnailers # used by gwenview
    kdePackages.kio-extras # for showing folder previews in gwenview
    keepassxc
    kid3
    ksnip
    lazygit
    libqalculate
    lsof
    lxqt.pcmanfm-qt
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
    okular
    papirus-icon-theme
    patool
    pavucontrol
    perlPackages.FileMimeInfo
    phinger-cursors
    playerctl
    procs
    pulseaudio # needed for pactl
    pulsemixer
    qbittorrent
    qimgv
    r128gain
    renameutils
    ripgrep # used mainly for telescope
    sgt-puzzles
    shellcheck
    soulseekqt
    themechanger
    tree
    unrar # required by atool
    unzip # required by atool
    vesktop
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

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile."beets/config.yaml".source = ./configs/beets_config.yaml;

  home.file.".crawl/init.txt".source = ./configs/crawlinit;
  home.file.".bash_profile".source   = ./configs/bash_profile;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
