let
  monitors = import ../monitors.nix;
in
{
  # Missing displays are ignored. Not expressible per monitor here:
  # niri's ASUS gaps 0 / border off, and focus-at-startup.
  # Struts and gap are global in layout.nix, sized for 1920x1200.
  # Output VRR stays off (no on-demand mode). Game rules arm VRR while focused.
  output.${monitors.asus} = {
    mode = "1920x1080@60.000";
    scale = 1.0;
    position = [
      731
      0
    ];
    # niri fixed the column at 1920 on this 1920-wide panel.
    layout.scrolling.default_width_fraction = 1.0;
  };

  output.${monitors.lg} = {
    mode = "3440x1440@159.962";
    scale = 1.25;
    position = [
      0
      1080
    ];
  };
}
