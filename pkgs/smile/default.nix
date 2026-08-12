{ smile }:
# Patch: --start-hidden must hold() or the process exits immediately (no
# Flatpak portal keep-alive on niri). Warm instance → instant Mod+E activate.
smile.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./hold-start-hidden.patch ];
})
