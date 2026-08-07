{ pkgs, ... }:

let
  # Script lives in-repo: Python edits apply on next run without rebuilding
  # the wrapper. runtimeInputs need a home switch when tools change.
  flake-up = pkgs.writeShellApplication {
    name = "flake-up";
    runtimeInputs = with pkgs; [
      python3
      nix
      nh
      jujutsu
    ];
    text = ''
      exec python3 ${../../scripts/flake-up} "$@"
    '';
  };
in
{
  home.packages = [ flake-up ];
}
