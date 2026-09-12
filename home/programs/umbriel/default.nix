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
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  # Stock packaged config: leave settings unset so HM does not write
  # ~/.config/umbriel/config.toml.
  programs.umbriel.enable = true;

  home.packages = [ fishCompletions ];
}
