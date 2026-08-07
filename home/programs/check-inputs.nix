{ pkgs, ... }:

let
  # Scripts live in-repo so Python edits apply on next run without rebuilding
  # the wrapper — only runtimeInputs need a home switch when tools change.
  check-inputs = pkgs.writeShellApplication {
    name = "check-inputs";
    runtimeInputs = with pkgs; [
      python3
      nix
    ];
    text = ''
      exec python3 ${../../scripts/check-inputs} "$@"
    '';
  };

  # Replaces fish nupd: peek → update/switch stale flakes → commit flake.lock.
  nupd = pkgs.writeShellApplication {
    name = "nupd";
    runtimeInputs = with pkgs; [
      python3
      nix
      nh
      jujutsu
      check-inputs
    ];
    text = ''
      exec python3 ${../../scripts/nupd} "$@"
    '';
  };
in
{
  home.packages = [
    check-inputs
    nupd
  ];
}
