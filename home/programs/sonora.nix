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
  # clap's fish output never disables default file completion, so every
  # position offers paths too. Silence files for the whole command,
  # then re-enable them for the only subcommands that take files or
  # links.
  fishCompletions = pkgs.runCommand "sonora-fish-completions" { } ''
    mkdir -p $out/share/fish/vendor_completions.d
    {
      echo 'complete -c sonora -f'
      ${lib.getExe sonora} completions fish
      echo "complete -c sonora -n '__fish_sonora_using_subcommand add' -F"
      echo "complete -c sonora -n '__fish_sonora_using_subcommand play' -F"
      echo "complete -c sonora -n '__fish_sonora_using_subcommand play-next' -F"
    } > $out/share/fish/vendor_completions.d/sonora.fish
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
