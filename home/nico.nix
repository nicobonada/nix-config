{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./style.nix
    ./programs
    ./services
  ];

  # Unfree for *installed* HM packages: flake.nix imports nixpkgs with allowUnfree
  # (legacyPackages ignores this module option). Ad-hoc nix-shell / nix shell stay
  # free-by-default so unfree needs an explicit NIXPKGS_ALLOW_UNFREE=1 (warning is intentional).
  nixpkgs.config.allowUnfree = true;

  home.username = "nico";
  home.homeDirectory = "/home/nico";

  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    TERMINAL = "kitty";
    NH_FLAKE = "$HOME/src/nix-config";
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg.configFile."uwsm/env".text = /* bash */ ''
    export APP2UNIT_TYPE=service
    export NIXOS_OZONE_WL=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
  '';

  home.file.".crawl/init.txt".source = ./configs/crawlinit;
  home.file.".bash_profile".source   = ./configs/bash_profile;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "21.05";
}
