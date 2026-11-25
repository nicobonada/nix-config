{
  inputs,
  pkgs,
  ...
}:
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
    package = inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
