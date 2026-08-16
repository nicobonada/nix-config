{
  config,
  lib,
  pkgs,
  ...
}:
let
  custom = import ../../pkgs { inherit pkgs; };
in
{
  # Pause/resume Syncthing while beets rewrites music + DB.
  # Used by: nix develop .#beets (shellHook + EXIT trap).
  home.packages = [
    custom.beets-syncthing-pause
    custom.beets-syncthing-resume
    custom.beets-state-migrate
  ];

  # One-shot on activation so first Syncthing scan has a real DB (idempotent).
  home.activation.beetsStateMigrate = config.lib.dag.entryAfter [ "beetsStateDir" ] ''
    ${lib.getExe custom.beets-state-migrate}
  '';
}
