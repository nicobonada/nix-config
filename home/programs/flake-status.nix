{ pkgs, inputs, ... }:

{
  # Package from flake input flake-status (public: nicobonada/flake-status).
  home.packages = [
    inputs.flake-status.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
