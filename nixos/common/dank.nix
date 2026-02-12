{ inputs, config, pkgs, lib, ... }:
{
  imports = [ inputs.niri-nix.nixosModules.default ];

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
  programs.niri.withUWSM = true;

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      niri = {
        prettyName = "Niri";
        comment = "A scrollable-tiling Wayland compositor";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };
  };

}
