{ pkgs, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
in
{
  # Ad-hoc one-shot rsync; music library replication is Syncthing.
  home.packages = [ custom.path-mirror ];
}
