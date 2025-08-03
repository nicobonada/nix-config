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
    ./dconf.nix

    ./programs
    ./services

    inputs.catppuccin.homeModules.catppuccin
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
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nico";
  home.homeDirectory = "/home/nico";

  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    TERMINAL = "kitty";
    NH_FLAKE = "$HOME/nix-config";
  };

  home.packages = with pkgs; [
    android-file-transfer
    aria2
    bandwhich
    beets
    bemoji # emoji picker, needs rofi and wtype
    cavalier
    calibre
    cowsay
    crawlTiles
    dconf2nix
    dconf-editor
    dua
    duf
    erdtree
    fd
    gallery-dl
    htop
    inxi
    ipcalc
    jamesdsp
    kdiff3
    # keepassxc
    kid3
    libqalculate
    lsof
    lxqt.pcmanfm-qt
    mediainfo
    nicotine-plus
    nix-tree
    nmap
    kdePackages.okular
    papirus-icon-theme
    patool
    perlPackages.FileMimeInfo
    playerctl
    procs
    qbittorrent
    qimgv
    r128gain
    ripgrep
    sgt-puzzles
    shellcheck
    signal-desktop
    systemctl-tui
    sysz
    ticktick
    tree
    trilium-desktop
    wavemon
    zoom-us

    inputs.zen-browser.packages."${stdenv.hostPlatform.system}".default
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # this systemd unit is needed to get fumon from the uwsm package working
  # properly
  systemd.user.services.fumon = {
    Unit = {
      Description = "Failed unit monitor";
      Documentation = "man:fumon(1) man:busctl(1)";
      Requisite = "graphical-session.target";
      After = "graphical-session.target" ;
    };

    Service = {
      Type= "exec";
      ExecCondition = "/bin/sh -c 'command -v notify-send > /dev/null'";
      ExecStart = lib.getExe' pkgs.uwsm "fumon";
      Restart = "on-failure";
      Slice = "background-graphical.slice";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    hyprland.enable = false;
    waybar.enable = false;
  };

  xdg.configFile."beets/config.yaml".source = ./configs/beets_config.yaml;

  home.file.".crawl/init.txt".source = ./configs/crawlinit;
  home.file.".bash_profile".source   = ./configs/bash_profile;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
