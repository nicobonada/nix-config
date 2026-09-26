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
  };

  output.${monitors.lg} = {
    mode = "3440x1440@159.962";
    scale = 1.25;
    position = [
      0
      1080
    ];
  };

  # seyruun panel, 1920x1200 at scale 1.25 (1536 logical px wide).
  # The VG258 (1920 logical) is mounted above it. ASUS x stays 731 so the
  # oakhill ultrawide layout does not move. Center this panel under it:
  # 731 + (1920 - 1536) / 2, top edge on the ASUS bottom.
  output.${monitors.laptop} = {
    scale = 1.25;
    position = [
      923
      1080
    ];
  };
}
