{ config, lib, pkgs, ... }:
let
  cfg = config.container;
in {
  options.container = {
    enable = lib.mkEnableOption "support for containers";
  };

  config = lib.mkIf cfg.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };

      environment.systemPackages = [ pkgs.distrobox ];
  };
}
