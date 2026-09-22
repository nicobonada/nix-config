{
  # niri preset-column-widths. Gap 8 and center_focused "never" already match
  # Umbriel's defaults, so they are left unset.
  # Niri only inset the ultrawide. These struts are global, and the side inset
  # is what leaves a sliver of the next column at the screen edge.
  layout.struts = {
    left = 8;
    right = 8;
    top = 10;
    bottom = 10;
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
