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
  programs.niri.package = pkgs.niri;

  systemd.user.services.niri-flake-polkit.enable = false;

  programs.uwsm = {
    enable = true;

    waylandCompositors = { 
      niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = ''
          ${lib.getExe' config.programs.niri.package "niri-session"}
        '';
      };
    };
  };
}
