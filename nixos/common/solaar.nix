# Logitech receivers on both seats. graphical-session.target covers
# start-umbriel, so one user service is enough.
{ pkgs, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
in
{
  # udev + ltunify. The GUI is the user service below.
  hardware.logitech.wireless.enable = true;

  programs.solaar = {
    enable = true;
    # Wrapper adds the libnotify typelib. pkgs.solaar stays the cached build.
    package = custom.solaar;
    userService.enable = true; # window hidden, tray only
  };
}
