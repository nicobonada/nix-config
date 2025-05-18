{ pkgs, ... }:
{
  programs.wireshark = { 
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.nico.extraGroups = ["adbusers"];
}
