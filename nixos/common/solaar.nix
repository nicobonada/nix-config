# Logitech receivers on both seats. graphical-session.target covers niri
# (UWSM) and start-umbriel, so one user service is enough.
{
  # udev + ltunify. The GUI is the user service below.
  hardware.logitech.wireless.enable = true;

  programs.solaar = {
    enable = true;
    userService.enable = true; # window hidden, tray only
  };
}
