# vrr: oakhill's external monitors are DisplayPort. seyruun's only external
# port is HDMI, and FreeSync there blanks the VG258 for a couple of seconds.
# Fullscreen keeps the desktop at a fixed refresh. The laptop panel stays off.
{
  vrr ? false,
}:
let
  monitors = import ../monitors.nix;
  vrrAttr = if vrr then { vrr = "fullscreen"; } else { };
in
{
  # Missing displays are ignored.
  # Struts and gap are global in layout.nix, sized for 1920x1200.
  output.${monitors.asus} = {
    mode = "1920x1080@120.000";
    scale = 1.0;
    position = [
      731
      0
    ];
  }
  // vrrAttr;

  output.${monitors.lg} = {
    mode = "3440x1440@159.962";
    scale = 1.25;
    position = [
      0
      1080
    ];
  }
  // vrrAttr;

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
