# Logitech receivers on both seats.
#
# programs.solaar orders the user service before graphical-session, so it
# starts in parallel with the compositor. Umbriel imports WAYLAND_DISPLAY
# and then notifies ready, so wait for that unit.
{
  # udev + ltunify. The GUI is the user service below.
  hardware.logitech.wireless.enable = true;

  programs.solaar = {
    enable = true;
    userService.enable = true; # window hidden, tray only
  };

  systemd.user.services.solaar.after = [ "umbriel.service" ];
}
