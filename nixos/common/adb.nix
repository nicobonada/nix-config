{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.android-tools ];
  users.users.nico.extraGroups = ["adbusers"];
}
