{ inputs, pkgs, ...}:
{
  home.file."wallpapers" = {
    source = inputs.everforest-wallpapers.packages."${pkgs.stdenv.hostPlatform.system}".default;
    recursive = true;
  };
}
