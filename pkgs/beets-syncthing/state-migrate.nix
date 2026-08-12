{ writeShellApplication, coreutils }:
# Move legacy ~/.config/beets/{library.db,state.pickle} into the
# Syncthing beets-state folder once. Safe to re-run.
# Paths resolved at runtime via $HOME / $XDG_DATA_HOME.
writeShellApplication {
  name = "beets-state-migrate";
  runtimeInputs = [ coreutils ];
  text = ''
    set -euo pipefail
    dest="''${XDG_DATA_HOME:-$HOME/.local/share}/beets-state"
    legacy="$HOME/.config/beets"
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
}
