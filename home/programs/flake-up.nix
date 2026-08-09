{ pkgs, inputs, ... }:

{
  # Package from ~/src/flake-up (path flake input). Rebuild home after Go changes.
  home.packages = [
    inputs.flake-up.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
