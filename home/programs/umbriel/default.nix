{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  umbriel = inputs.umbriel.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Drop when upstream ships share/fish/vendor_completions.d/umbriel.fish:
  # the build-time check below then emits an empty sidecar.
  fishCompletions =
    pkgs.runCommand "umbriel-fish-completions"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        mkdir -p $out/share/fish/vendor_completions.d
        if [ -e ${umbriel}/share/fish/vendor_completions.d/umbriel.fish ]; then
          echo "upstream fish completions present; sidecar idle" > $out/README
          exit 0
        fi
        python3 ${./gen-fish-completions.py} ${lib.getExe umbriel} \
          > $out/share/fish/vendor_completions.d/umbriel.fish
      '';

  # Absent [keybinds] keeps Umbriel's built-in chords. That is not the packaged
  # example's extra binds (launcher, scratchpads, media). Niri KDL stays.
  settings = lib.foldl' lib.recursiveUpdate { } [
    (import ./settings/general.nix { inherit pkgs lib; })
    (import ./settings/input.nix)
    (import ./settings/layout.nix)
    (import ./settings/outputs.nix)
    (import ./settings/rules.nix)
  ];
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  programs.umbriel = {
    enable = true;
    inherit settings;
  };

  home.packages = [ fishCompletions ];
}
