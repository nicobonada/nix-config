{ pkgs, inputs, ... }:

{
  # Package from flake input flake-up (private git). Bulk update skips determinate.
  home.packages = [
    inputs.flake-up.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
