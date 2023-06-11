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
    # ./services
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
  home.username = "nobonada";
  home.homeDirectory = "/home/nobonada";

  home.sessionVariables = {
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    # TERMINAL = "kitty";
  };

  home.packages = with pkgs; [
    aria2
    atool
    cowsay
    dua
    duc
    duf
    erdtree
    fd
    flameshot
    htop
    inxi
    ipcalc
    kdiff3
    lazygit
    libqalculate
    lsof
    mediainfo
    neofetch
    nix-prefetch-git
    nix-tree
    nixpkgs-fmt
    nmap
    procs
    r128gain
    ranger
    renameutils
    ripgrep # used mainly for telescope
    shellcheck
    tree
    unrar # required by atool
    unzip # required by atool
    vivaldi
    vivid
    xsel

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
