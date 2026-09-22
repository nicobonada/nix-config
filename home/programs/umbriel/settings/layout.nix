{
  # niri's gap is 8 and center_focused "never" matches Umbriel's default.
  # 4 is sized for the 1920x1200 panel; the ultrawide shares it.
  layout.gap = 4;

  # Side inset leaves a sliver of the next column at the screen edge.
  # Half of the ultrawide's 8/10. A 1920-wide panel has less width to spare.
  layout.struts = {
    left = 4;
    right = 4;
    top = 4;
    bottom = 4;
  };

  layout.width_presets = [
    0.333333
    0.375
    0.5
    0.625
    0.666667
  ];

  appearance = {
    # Unmatched niri window rule set geometry-corner-radius 8 on every window.
    # Umbriel has no per-window radius, so games cannot force 0.
    corner_radius = 8;
    blur = {
      # niri: passes 2, offset 3, noise 0.03, saturation 1.
      # radius is Umbriel's sample distance.
      passes = 2;
      radius = 3;
      noise = 0.03;
      saturation = 1.0;
    };
  };
}
