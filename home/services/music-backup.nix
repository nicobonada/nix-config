{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Hub owns restic (homelab/music-backup.nix). Seats only keep optional
  # restore tooling and a one-shot migrator for the beets-state path move.
  beetsLiveLegacy = "${config.home.homeDirectory}/.config/beets";
  beetsStateDir = "${config.xdg.dataHome}/beets-state";

  beets-state-migrate = pkgs.writeShellApplication {
    name = "beets-state-migrate";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      # Move legacy ~/.config/beets/{library.db,state.pickle} into the
      # Syncthing beets-state folder once. Safe to re-run.
      set -euo pipefail
      dest=${lib.escapeShellArg beetsStateDir}
      legacy=${lib.escapeShellArg beetsLiveLegacy}
      mkdir -p "$dest"
      for f in library.db state.pickle; do
        if [[ -f $legacy/$f && ! -e $dest/$f ]]; then
          mv -n "$legacy/$f" "$dest/$f"
          echo "beets-state-migrate: moved $f → $dest/"
        elif [[ -e $dest/$f ]]; then
          echo "beets-state-migrate: keep existing $dest/$f"
        else
          echo "beets-state-migrate: no $legacy/$f (ok)"
        fi
      done
    '';
  };
in
{
  home.packages = [
    beets-state-migrate
    # Manual restore / inspect against the B2 music repo if needed.
    pkgs.restic
  ];

  # One-shot on activation so the first Syncthing scan has a real DB.
  home.activation.beetsStateMigrate = config.lib.dag.entryAfter [ "beetsStateDir" ] ''
    ${lib.getExe beets-state-migrate}
  '';
}
