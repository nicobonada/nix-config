{ pkgs, ... }:

let
  # python3 + nix on PATH; script lives in-repo so edits don't need a store rewrite
  # of the Python source until the next home build.
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
in
{
  home.packages = [ check-inputs ];
}
