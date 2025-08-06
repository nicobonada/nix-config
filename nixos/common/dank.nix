{ inputs, config, pkgs, lib, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    configHome = "/home/nico";

    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };

  programs.niri.enable = true;

  systemd.user.services.niri-flake-polkit.enable = false;
}
