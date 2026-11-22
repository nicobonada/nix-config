{ custom, ... }:
{
  # Ad-hoc one-shot rsync. Music library is hub NFS
  # (nixos/common/music-nfs.nix).
  home.packages = [ custom.path-mirror ];
}
