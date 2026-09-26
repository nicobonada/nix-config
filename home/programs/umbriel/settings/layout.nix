{
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

  layout.extent_presets = [
    0.333333
    0.375
    0.5
    0.625
    0.666667
  ];

  appearance = {
    # No per-window radius, so games cannot force 0.
    corner_radius = 8;
    blur = {
      # radius is the sample distance.
      passes = 2;
      radius = 3;
      noise = 0.03;
      saturation = 1.0;
    };
  };
}
