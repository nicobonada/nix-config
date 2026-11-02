{ pkgs, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
in
{
  # Ad-hoc one-shot rsync. Music library is hub NFS
  # (nixos/common/music-nfs.nix).
  home.packages = [ custom.path-mirror ];
}
