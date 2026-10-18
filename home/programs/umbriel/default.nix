{
  inputs,
  host,
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

  # Keybinds overlay Umbriel's built-ins. Unset chords stay.
  # One settings file per seat, so output sections live here. vrr is
  # oakhill only: seyruun's HDMI port blanks the VG258 if FreeSync is on.
  settings = lib.foldl' lib.recursiveUpdate { } [
    (import ./settings/general.nix { inherit host lib; })
    (import ./settings/input.nix)
    (import ./settings/layout.nix)
    (import ./settings/rules.nix)
    (import ./settings/keybinds.nix)
    (import ./settings/outputs.nix { vrr = host == "oakhill"; })
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
