{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  custom = import ../../../pkgs { inherit pkgs; };
in
{
  wayland.windowManager.niri = {
    enable = true;

    # Repo-local KDL fragments pasted at build time. Only store paths stay in Nix.
    extraConfig = lib.concatStringsSep "\n" [
      (builtins.readFile ./niri-input.kdl)
      (builtins.readFile ./niri-outputs.kdl)
      (builtins.readFile ./niri-layout.kdl)
      (builtins.readFile ./niri-startup.kdl)
      (builtins.readFile ./niri-binds.kdl)
      (builtins.readFile ./niri-rules.kdl)
      (builtins.readFile ./niri-misc.kdl)
      /* kdl */ ''
        // Packages used only by the compositor — absolute paths, not home.packages
        spawn-at-startup "${lib.getExe pkgs.wayland-pipewire-idle-inhibit}"
        // oakhill only: no ultrawide on seyruun. Session niri is on PATH.
        spawn-sh-at-startup "[ $(hostname) = 'oakhill' ] && ${lib.getExe custom.niri-game-output}"
        xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }
      ''
    ];
  };
}
