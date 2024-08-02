# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./fonts.nix

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
    aria2
    bandwhich
    beets-unstable
    bemoji # emoji picker, needs rofi and wtype
    calibre
    cowsay
    crawlTiles
    dconf-editor
    dua
    duf
    erdtree
    fd
    htop
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
    mediainfo
    nix-tree
    nixpkgs-fmt
    nmap
    okular
    papirus-icon-theme
    patool
    perlPackages.FileMimeInfo
    playerctl
    procs
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
    vesktop
    (vivaldi.override {
      # don't use multiline string here: see https://github.com/NixOS/nixpkgs/issues/197243#issuecomment-1775803207
      commandLineArgs = "--ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy --enable-features=VaapiVideoDecoder";
    })
    wavemon
  ];

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
