{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  sonora = inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Sonora ships neither fish completions nor man pages (HM's man-page
  # generator emits an empty sidecar), but the binary's native
  # `completions fish` runs headless - generate at build time.
  fishCompletions = pkgs.runCommand "sonora-fish-completions" { } ''
    mkdir -p $out/share/fish/vendor_completions.d
    ${lib.getExe sonora} completions fish \
      > $out/share/fish/vendor_completions.d/sonora.fish
  '';
in
{
  # Author's module: wraps the package (ALSA plugin dir) and merges
  # programs.sonora.settings into ~/.config/sonora/settings.json on
  # switch and launch. Server connections stay in-app; passwords do not
  # belong in this repo.
  imports = [ inputs.sonora.homeModules.default ];

  programs.sonora = {
    enable = true;
    # Flake pin so the binary hits sonora.cachix.org (same pattern as
    # noctalia above).
    package = sonora;
  };

  home.packages = [ fishCompletions ];
}
